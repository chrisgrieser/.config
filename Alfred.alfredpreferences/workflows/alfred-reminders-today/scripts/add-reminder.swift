#!/usr/bin/env swift
import EventKit
import Foundation
import WidgetKit

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let input = CommandLine.arguments[1]
let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!
let when = ProcessInfo.processInfo.environment["when_to_add"]!

// ─────────────────────────────────────────────────────────────────────────────

struct ParsedResult {
	let hour: Int?
	let minute: Int?
	let message: String
	let bangs: String  // string with the number of exclamation marks
}

func parseTimeAndPriorityAndMessage(from input: String) -> ParsedResult? {
	var msg = input.trimmingCharacters(in: .whitespacesAndNewlines)
	guard !msg.isEmpty else { return nil }

	// parse leading/trailing bangs for priority
	var bangs = ""  // default: no priority
	let bangPattern = #"^!+|!+$"#
	let bangRegex = try! NSRegularExpression(pattern: bangPattern)

	if let match = bangRegex.firstMatch(in: msg, range: NSRange(msg.startIndex..., in: msg)),
		let matchRange = Range(match.range, in: msg)
	{
		bangs = String(msg[matchRange])
		msg.removeSubrange(matchRange)
	}

	// parse HH:MM for due time
	var hour: Int? = nil
	var minute: Int? = nil
	let timePattern = #"(?<!\d)(\d{1,2}):(\d{2})(?!\d)"#
	let timeRegex = try! NSRegularExpression(pattern: timePattern)

	if let match = timeRegex.firstMatch(in: msg, range: NSRange(msg.startIndex..., in: msg)) {
		if let hrRange = Range(match.range(at: 1), in: msg),
			let minRange = Range(match.range(at: 2), in: msg),
			let timeRange = Range(match.range, in: msg),
			let parsedHour = Int(msg[hrRange]),
			let parsedMinute = Int(msg[minRange]),
			(0..<24).contains(parsedHour),
			(0..<60).contains(parsedMinute)
		{
			hour = parsedHour
			minute = parsedMinute
			msg.removeSubrange(timeRange)
		} else {
			return nil  // invalid time
		}
	}

	msg = msg.trimmingCharacters(in: .whitespacesAndNewlines)
	return ParsedResult(hour: hour, minute: minute, message: msg, bangs: bangs)
}

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToReminders { granted, error in
	guard error == nil && granted else {
		let msg =
			error != nil
			? "Error requesting access: \(error!.localizedDescription)"
			: "Access to Calendar events not granted."
		print("❌ " + msg)
		semaphore.signal()
		return
	}
	// ──────────────────────────────────────────────────────────────────────────

	// Create a new reminder
	let parsed = parseTimeAndPriorityAndMessage(from: input)
	guard parsed != nil else {
		print("❌ Invalid time: \"\(input)\"")
		semaphore.signal()
		return
	}
	let (title, hh, mm, bangs) = (parsed!.message, parsed!.hour, parsed!.minute, parsed!.bangs)
	let isAllDayReminder = (hh == nil && hh == nil)
	let reminder = EKReminder(eventStore: eventStore)
	reminder.title = title
	reminder.isCompleted = false

	// priority
	switch bangs.count {  // values based on RFC 5545, which Apple uses https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.9
	case 1: reminder.priority = 9
	case 2: reminder.priority = 5
	case 3: reminder.priority = 1
	default: reminder.priority = 0
	}

	// determine day when to add
	let calendar = Calendar.current
	let today = Date()
	var dayToUse: Date
	if when == "today" {
		dayToUse = today
	} else if when == "tomorrow" {
		let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
		dayToUse = tomorrow
	} else {
		print("❌ Invalid value for 'when_to_add' environment variable.")
		semaphore.signal()
		return
	}

	// Set due date
	var dateComponents = calendar.dateComponents([.year, .month, .day], from: dayToUse)
	if !isAllDayReminder {
		dateComponents.hour = hh
		dateComponents.minute = mm
	}
	reminder.dueDateComponents = dateComponents
	reminder.startDateComponents = nil  // reminders created regularly have no start date, we mimic that

	// * Add an alarm to trigger a notification. Even though the reminder created
	//   without an alarm looks the same as one with an alarm, an alarm is needed
	//   to trigger the notification (see #2).
	// * Whether all-day remidners do get a notification or not is determined by
	//   by the user's reminder settings; adding an alarm to all-day reminders
	//   would enforce a notification, regardless of the setting, so we add the
	//   alarm only if the reminder is not all-day.
	if !isAllDayReminder {
		// Apple Reminders use absolute dates as alarm, not relative offset; we mimic that
		let dueDate = calendar.date(from: dateComponents)!
		reminder.addAlarm(EKAlarm(absoluteDate: dueDate))
	}

	// Find the calendar (list) by name
	let listToUse = eventStore.calendars(for: .reminder).first(where: { $0.title == reminderList })
	if listToUse != nil {
		reminder.calendar = listToUse
	} else {
		print("❌ No calendar found with the name \"\(reminderList)\".")
		semaphore.signal()
		return
	}

	// Save
	do {
		try eventStore.save(reminder, commit: true)

		// notification for Alfred
		var msgComponents: [String] = []
		if !bangs.isEmpty {
			let shortBangs = String(bangs.prefix(3))  // max 3 is valid as priority
			msgComponents.append(shortBangs)
		}
		if !isAllDayReminder {
			let minutesPadded = String(format: "%02d", mm!)
			msgComponents.append("\(hh!):\(minutesPadded)")
		}
		msgComponents.append("\"\(title)\"")

		let alfredNotif = msgComponents.joined(separator: "     ")
		print(alfredNotif)
	} catch {
		print("❌ Failed to create reminder: \(error.localizedDescription)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
