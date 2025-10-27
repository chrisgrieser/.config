#!/usr/bin/env swift
import EventKit
import Foundation
import WidgetKit

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let input = CommandLine.arguments[1]
let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!

// ─────────────────────────────────────────────────────────────────────────────

struct ParsedResult {
	let hour: Int?
	let minute: Int?
	let message: String
	let bangs: String  // string with the number of exclamation marks
	let amPm: String
}

func parseTimeAndPriorityAndMessage(from input: String) -> ParsedResult? {
	var msg = input.trimmingCharacters(in: .whitespacesAndNewlines)
	guard !msg.isEmpty else { return nil }

	// parse leading/trailing bangs for priority
	var bangs = ""  // default: no priority
	let bangRegex = try! Regex(#"^!{1,3}|!{1,3}$"#)
	if let match = try? bangRegex.firstMatch(in: msg) {
		bangs = String(msg[match.range])
		msg.removeSubrange(match.range)
	}

	// parse HH:MM(am|pm) for due time, if at start or end of input
	var hour: Int?
	var minute: Int?
	var amPm = ""
	let timePattern = #"(\d{1,2}):(\d{2})(?: ?(am|pm|AM|PM))?"#
	let timeRegex = try! Regex("^\(timePattern) | \(timePattern)$")

	if let match = try? timeRegex.firstMatch(in: msg) {
		let h1 = match.output[1].substring ?? ""
		let m1 = match.output[2].substring ?? ""
		let amPm1 = match.output[3].substring ?? ""
		let h2 = match.output[4].substring ?? ""
		let m2 = match.output[5].substring ?? ""
		let amPm2 = match.output[6].substring ?? ""
		let hourStr = !h1.isEmpty ? h1 : h2
		let minuteStr = !m1.isEmpty ? m1 : m2
		let hasAmPm = !amPm1.isEmpty || !amPm2.isEmpty

		if let hourVal = Int(hourStr),
			let minuteVal = Int(minuteStr),
			(0..<60).contains(minuteVal),
			(!hasAmPm && (0..<24).contains(hourVal)) || (hasAmPm && (1..<13).contains(hourVal))
		{
			amPm = String(!amPm1.isEmpty ? amPm1 : amPm2).lowercased()
			hour = hourVal
			if (amPm == "pm" && hour != 12) || (amPm == "am" && hour == 12) {
				hour = (hour! + 12) % 24
			}
			minute = minuteVal
			msg.removeSubrange(match.range)
		} else {
			return nil
		}
	}
	msg = msg.trimmingCharacters(in: .whitespacesAndNewlines)
	return ParsedResult(hour: hour, minute: minute, message: msg, bangs: bangs, amPm: amPm)
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
	let (title, hh, mm, bangs, amPm) = (
		parsed!.message, parsed!.hour, parsed!.minute, parsed!.bangs, parsed!.amPm
	)
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
	let targetDay = ProcessInfo.processInfo.environment["target_day"]!
	let dateOffset = Int(targetDay)
	var dayToUse: Date

	if dateOffset != nil {
		dayToUse = calendar.date(byAdding: .day, value: dateOffset!, to: today)!
	} else {
		let weekdayName: String = targetDay
		let weekdays: [String: Int] = [
			"sunday": 1, "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5, "friday": 6,
			"saturday": 7,
		]
		let weekday = weekdays[weekdayName.lowercased()]

		dayToUse = calendar.nextDate(
			after: today,
			matching: DateComponents(weekday: weekday),
			matchingPolicy: .nextTime  // `.nextTime` ensures it's not today, if today is Monday
		)!
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
	// * Whether all-day reminders do get a notification or not is determined by
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
		var msg: [String] = []
		if !bangs.isEmpty {
			msg.append(bangs)
		}
		if !isAllDayReminder {
			let minutesPadded = String(format: "%02d", mm!)
			var hourDisplay = hh!
			if amPm == "am" && hh! == 0 { hourDisplay = 12 }
			if amPm == "pm" && hh! != 12 { hourDisplay = hh! - 12 }
			let timeStr = String(hourDisplay) + ":" + minutesPadded + amPm
			msg.append(timeStr)
		}
		msg.append("\"\(title)\"")

		let alfredNotif = msg.joined(separator: "     ")
		print(alfredNotif)
	} catch {
		print("❌ Failed to create reminder: \(error.localizedDescription)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
