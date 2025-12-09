#!/usr/bin/env swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// Alfred environment variables
let input = CommandLine.arguments[1].trimmingCharacters(in: .whitespacesAndNewlines)
let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!
let targetDay = ProcessInfo.processInfo.environment["target_day"]!

// ─────────────────────────────────────────────────────────────────────────────

struct ParsedResult {
	let hour: Int?  // nil if no time (= all-day reminder)
	let minute: Int?
	let msg: String
	let bangs: String  // string with the number of exclamation marks
	let amPm: String
	let error: String?  // non-nil if error
}

func parseTimeAndPriorityAndMessage(input: String, targetDay: String) -> ParsedResult {
	func parseError(_ msg: String) -> ParsedResult {
		return ParsedResult(hour: nil, minute: nil, msg: "", bangs: "", amPm: "", error: msg)
	}
	var msg = input
	var hour: Int?
	var minute: Int?
	var amPm = ""

	// PARSE BANGS (PRIORITY)
	var bangs = ""  // default: no priority
	let bangRegex = try! Regex("^!{1,3}|!{1,3}$")
	if let bangMatch = try? bangRegex.firstMatch(in: msg) {
		bangs = String(msg[bangMatch.range])
		msg.removeSubrange(bangMatch.range)
	}

	// DUE TIME PATTERNS
	let hhmmPattern = #"(\d{1,2})[:.](\d{2}) ?(am|pm|AM|PM)?"#
	let hhPattern = #"(\d{1,2}) ?()(am|pm|AM|PM)"#  // empty 2nd capture group so index is consistent
	let relativePattern = #"in (\d+) ?(minutes?|hours?|min|m|h)"#
	let patterns = [  // only match pattern if it is at start or end of input
		try! Regex("^\(hhmmPattern) "),
		try! Regex("^\(hhPattern) "),
		try! Regex("^\(relativePattern) "),
		try! Regex(" \(hhmmPattern)$"),
		try! Regex(" \(hhPattern)$"),
		try! Regex(" \(relativePattern)$"),
	]
	let timeMatch = patterns.compactMap { try? $0.firstMatch(in: msg) }.first
	if timeMatch != nil && targetDay == "none" {
		return parseError("Cannot set a due time for a reminder without due date.")
	}
	if timeMatch == nil {  // no time found
		return ParsedResult(hour: nil, minute: nil, msg: msg, bangs: bangs, amPm: "", error: nil)
	}

	// PARSE DUE TIME
	let capture = timeMatch!.output.map { $0.substring }
	let timeString = capture[0]!.trimmingCharacters(in: .whitespacesAndNewlines)
	let isRelativeTime = timeString.starts(with: "in ")

	if isRelativeTime {
		guard targetDay == "0" else {
			return parseError("Relative times are only supported for today.")
		}
		var inXmins = Int(capture[1]!)!
		let unit = capture[2]!.starts(with: "m") ? "minutes" : "hours"
		if unit == "hours" { inXmins *= 60 }

		let now = Date()
		let dueTime = Calendar.current.date(byAdding: .minute, value: inXmins, to: now)!
		let dueTimeComps = Calendar.current.dateComponents([.day, .hour, .minute], from: dueTime)
		let today = Calendar.current.dateComponents([.day], from: now).day
		guard dueTimeComps.day == today else {
			return parseError("Can't set a relative time that goes beyond today.")
		}
		hour = dueTimeComps.hour
		minute = dueTimeComps.minute
		amPm = ""
	} else {
		// absolute time
		hour = Int(capture[1]!)
		minute = capture[2]!.isEmpty ? 0 : Int(capture[2]!)  // empty capture group in `hhPattern`
		amPm = (capture[3] ?? "").lowercased()

		let hasAmPm = !amPm.isEmpty
		guard
			(0..<60).contains(minute!)
				&& ((!hasAmPm && (0..<24).contains(hour!)) || (hasAmPm && (1..<13).contains(hour!)))
		else { return parseError("Invalid time: \"\(timeString)\"") }

		if amPm == "pm" && hour != 12 { hour! += 12 }
		if amPm == "am" && hour == 12 { hour = 0 }
	}

	msg.removeSubrange(timeMatch!.range)
	msg = msg.trimmingCharacters(in: .whitespacesAndNewlines)
	return ParsedResult(hour: hour, minute: minute, msg: msg, bangs: bangs, amPm: amPm, error: nil)
}

func fetchWebsiteTitle(from string: String) async throws -> String? {
	guard
		let url = URL(string: string),
		(url.scheme == "http" || url.scheme == "https") && url.host != nil
	else { return nil }

	let (data, _) = try await URLSession.shared.data(from: url)
	guard let html = String(data: data, encoding: .utf8) else { return nil }

	let regex = try! Regex("<title>(.*?)</title>")
	if let match = try? regex.firstMatch(in: html) {
		return String(match.output[1].substring!)
	}
	return nil
}

func requestRemindersAccess() async -> Bool {
	await withCheckedContinuation { continuation in
		eventStore.requestFullAccessToReminders { granted, error in
			continuation.resume(returning: granted)
		}
	}
}

func fail(_ msg: String) {
	print("❌;" + msg)  // `;` used as separator in Alfred
	semaphore.signal()
}

// ─────────────────────────────────────────────────────────────────────────────

Task {  // wrapping in `Task` because `await` is not allowed in `main`
	guard !input.isEmpty else {
		fail("Input is empty.")
		return
	}
	guard await requestRemindersAccess() else {
		fail("Access to Reminder.app not granted.")
		return
	}
	// ──────────────────────────────────────────────────────────────────────────

	// PARSE INPUT
	let parsed = parseTimeAndPriorityAndMessage(input: input, targetDay: targetDay)
	if let errorMsg = parsed.error {
		fail(errorMsg)
		return
	}
	let (hh, mm, bangs, amPm) = (parsed.hour, parsed.minute, parsed.bangs, parsed.amPm)
	var title = parsed.msg
	var body = ""

	// if input is a URL, fetch title and use URL as body
	var msgIsUrl = false
	if let urlTitle = try await fetchWebsiteTitle(from: parsed.msg) {
		title = urlTitle
		body = parsed.msg
		msgIsUrl = true
	}

	// CREATE REMINDER
	let isAllDayReminder = (hh == nil && hh == nil)
	let reminder = EKReminder(eventStore: eventStore)
	reminder.title = title
	reminder.isCompleted = false
	reminder.notes = body

	switch bangs.count {  // values based on RFC 5545, which Apple uses https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.9
	case 1: reminder.priority = 9
	case 2: reminder.priority = 5
	case 3: reminder.priority = 1
	default: reminder.priority = 0
	}

	// DETERMINE DAY WHEN TO ADD
	let calendar = Calendar.current
	let today = Date()

	var dayToUse: Date?
	if targetDay == "none" {
		dayToUse = nil
	} else if let dateOffset = Int(targetDay) {
		dayToUse = calendar.date(byAdding: .day, value: dateOffset, to: today)!
	} else {
		let weekdayName: String = targetDay.lowercased()
		let weekdays: [String: Int] = [
			"sunday": 1, "monday": 2, "tuesday": 3, "wednesday": 4, "thursday": 5, "friday": 6,
			"saturday": 7,
		]
		guard let weekday = weekdays[weekdayName] else {
			fail("Unknown value for target day: " + targetDay)
			return
		}
		dayToUse = calendar.nextDate(
			after: today,
			matching: DateComponents(weekday: weekday),
			matchingPolicy: .nextTime  // `.nextTime` ensures it's not today, if today is Monday
		)!
	}

	// SET DUE DATE
	if let dayToUse {
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
	}

	// SET LIST (= CALENDAR)
	let listToUse = eventStore.calendars(for: .reminder).first(where: { $0.title == reminderList })
	guard listToUse != nil else {
		fail("No reminder list found with the name \"\(reminderList)\".")
		return
	}
	reminder.calendar = listToUse

	// SAVE
	do {
		try eventStore.save(reminder, commit: true)
	} catch {
		fail("Failed to create reminder: " + error.localizedDescription)
		return
	}

	// NOTIFICATION FOR ALFRED
	var notif: [String] = []
	if !bangs.isEmpty { notif.append(bangs) }
	if !isAllDayReminder {
		let minutesPadded = String(format: "%02d", mm!)
		var hourDisplay = hh!
		if amPm == "am" && hh! == 0 { hourDisplay = 12 }
		if amPm == "pm" && hh! != 12 { hourDisplay = hh! - 12 }
		let timeStr = String(hourDisplay) + ":" + minutesPadded + amPm
		notif.append(timeStr)
	}
	notif.append("\"\(title)\"")
	if msgIsUrl { notif.append("🔗") }
	let alfredNotif = notif.joined(separator: "   ")
	print("✅;" + alfredNotif)  // `;` used as separator in Alfred

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
