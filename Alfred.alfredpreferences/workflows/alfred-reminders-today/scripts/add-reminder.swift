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

enum Priority: Int {
	case none = 0
	case low = 1
	case medium = 2
	case high = 3
}

struct ParsedResult {
	let hour: Int?
	let minute: Int?
	let message: String
	let priority: Priority
}

func parseTimeAndPriorityAndMessage(from input: String) -> ParsedResult? {
	var msg = input.trimmingCharacters(in: .whitespacesAndNewlines)

	if 2 == 2 {
		print(msg)
	}

	guard !msg.isEmpty else { return nil }

	// parse trailing exclamations for priority
	var priority: Priority = .none
	let exclamationPattern = #"!+$"#
	let exclamationRegex = try! NSRegularExpression(pattern: exclamationPattern)

	if let match = exclamationRegex.firstMatch(in: msg, range: NSRange(msg.startIndex..., in: msg)),
		let matchRange = Range(match.range, in: msg)
	{
		let bangs = msg[matchRange]
		let bangCount = bangs.count

		switch bangCount {
		case 1: priority = .low
		case 2: priority = .medium
		default: priority = .high
		}

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
			return nil  // Invalid time
		}
	}

	msg = msg.trimmingCharacters(in: .whitespacesAndNewlines)
	return ParsedResult(hour: hour, minute: minute, message: msg, priority: priority)
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
	let (title, hh, mm) = (parsed!.message, parsed!.hour, parsed!.minute)
	let isAllDayReminder = (hh == nil && hh == nil)
	let reminder = EKReminder(eventStore: eventStore)
	reminder.title = title
	reminder.isCompleted = false

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
		var alfredNotif = title
		if !isAllDayReminder {
			let minutePadded = String(format: "%02d", mm!)
			alfredNotif = "\(hh!):\(minutePadded) — \(title)"
		}
		print(alfredNotif)
	} catch {
		print("❌ Failed to create reminder: \(error.localizedDescription)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
