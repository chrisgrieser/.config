#!/usr/bin/env swift
import EventKit
import Foundation
import WidgetKit

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let input = CommandLine.arguments[1].trimmingCharacters(in: .whitespacesAndNewlines)
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
	var msg = input

	// parse bangs for priority
	var bangs = ""  // default: no priority
	let bangRegex = try! Regex(#"^!{1,3}|!{1,3}$"#)
	if let match = try? bangRegex.firstMatch(in: msg) {
		bangs = String(msg[match.range])
		msg.removeSubrange(match.range)
	}

	var hour: Int?
	var minute: Int?
	var amPm = ""

	// parse due time
	let hhmmPattern = #"(\d{1,2}):(\d{2}) ?(am|pm|AM|PM)?"#
	let hhPattern = #"(\d{1,2}) ?()(am|pm|AM|PM)"#  // empty capture group, so later code is the same
	let patterns = [
		try! Regex("^\(hhmmPattern) "),  // only if at start/end of input
		try! Regex("^\(hhPattern) "),
		try! Regex(" \(hhmmPattern)$"),
		try! Regex(" \(hhPattern)$"),
	]
	let match = patterns.compactMap { try? $0.firstMatch(in: msg) }.first

	if match != nil {
		let hourStr = match!.output[1].substring!
		var minuteStr = match!.output[2].substring!
		if minuteStr.isEmpty { minuteStr = "00" }  // empty capture group in `hhPattern`
		let amPmStr = match!.output[3].substring
		let hasAmPm = amPmStr != nil

		if let hourVal = Int(hourStr),
			let minuteVal = Int(minuteStr),
			(0..<60).contains(minuteVal),
			(!hasAmPm && (0..<24).contains(hourVal)) || (hasAmPm && (1..<13).contains(hourVal))
		{
			hour = hourVal
			amPm = (amPmStr ?? "").lowercased()
			if amPm == "pm" && hour != 12 { hour! += 12 }
			if amPm == "am" && hour == 12 { hour = 0 }
			minute = minuteVal
			msg.removeSubrange(match!.range)
		} else {
			return nil  // invalid time
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
			? "Error requesting access: " + error!.localizedDescription
			: "Access to Reminder.app not granted."
		print("❌ " + msg)
		semaphore.signal()
		return
	}
	guard !input.isEmpty else {
		print("❌ Input is empty.")
		semaphore.signal()
		return
	}

	// PARSE INPUT
	let parsed = parseTimeAndPriorityAndMessage(from: input)
	guard parsed != nil else {
		print("❌ Invalid time: \"\(input)\"")
		semaphore.signal()
		return
	}
	let (title, hh, mm, bangs, amPm) = (
		parsed!.message, parsed!.hour, parsed!.minute, parsed!.bangs, parsed!.amPm
	)

	// CREATE REMINDER
	let isAllDayReminder = (hh == nil && hh == nil)
	let reminder = EKReminder(eventStore: eventStore)
	reminder.title = title
	reminder.isCompleted = false

	// PRIORITY
	switch bangs.count {  // values based on RFC 5545, which Apple uses https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.9
	case 1: reminder.priority = 9
	case 2: reminder.priority = 5
	case 3: reminder.priority = 1
	default: reminder.priority = 0
	}

	// DETERMINE DAY WHEN TO ADD
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

	// SET DUE DATE
	var dateComponents = calendar.dateComponents([.year, .month, .day], from: dayToUse)
	if !isAllDayReminder {
		dateComponents.hour = hh
		dateComponents.minute = mm
	}
	reminder.dueDateComponents = dateComponents
	reminder.startDateComponents = nil  // reminders created regularly have no start date, we mimic that

	// ADD ALARM
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

	// SET LIST (= CALENDAR)
	let listToUse = eventStore.calendars(for: .reminder).first(where: { $0.title == reminderList })
	if listToUse != nil {
		reminder.calendar = listToUse
	} else {
		print("❌ No calendar found with the name \"\(reminderList)\".")
		semaphore.signal()
		return
	}

	// SAVE
	do {
		try eventStore.save(reminder, commit: true)
	} catch {
		print("❌ Failed to create reminder: \(error.localizedDescription)")
		semaphore.signal()
		return
	}

	// NOTIFICATION FOR ALFRED
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

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
