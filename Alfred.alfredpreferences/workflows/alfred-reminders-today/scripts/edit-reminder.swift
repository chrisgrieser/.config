#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let reminderId = ProcessInfo.processInfo.environment["id"]!
let mode = ProcessInfo.processInfo.environment["mode"]!
// ─────────────────────────────────────────────────────────────────────────────

func snoozeToTomorrow(reminder: EKReminder) {
	let calendar = Calendar.current
	let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
	let tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)

	// reminders with no due date need to a due date component first
	if reminder.dueDateComponents == nil { reminder.dueDateComponents = tomorrowComponents }

	// Only change the YYYY-MM-DD, since the HH:MM should be preserved.
	reminder.dueDateComponents!.year = tomorrowComponents.year
	reminder.dueDateComponents!.month = tomorrowComponents.month
	reminder.dueDateComponents!.day = tomorrowComponents.day

	// Adjust alarm as well
	if let alarms = reminder.alarms {
		for (index, alarm) in alarms.enumerated() {
			// Apple Reminders use absolute dates as alarm, not relative offset; we mimic that
			if let absoluteDate = alarm.absoluteDate {
				let tomorrowAlarm = calendar.date(byAdding: .day, value: 1, to: absoluteDate)!
				alarms[index].absoluteDate = tomorrowAlarm
			}
		}
	}
}

func editReminderFromStdin(reminder: EKReminder) -> Bool {
	let input = CommandLine.arguments[1]
	let lines = input.components(separatedBy: "\n")

	let newTitle = lines.first ?? ""
	if newTitle == "" {
		print("❌ No title.")
		return false
	}
	let newBody = lines.dropFirst()
		.joined(separator: "\n")
		.trimmingCharacters(in: .whitespaces)

	reminder.notes = newBody == "" ? nil : newBody

	reminder.title = newTitle
	print(newTitle)  // for Alfred notification
	return true
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

	if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {

		// MODIFY
		if mode == "toggle-completed" {
			reminder.isCompleted = !reminder.isCompleted
		} else if mode == "snooze" {
			snoozeToTomorrow(reminder: reminder)
		} else if mode == "edit-reminder" {
			let success = editReminderFromStdin(reminder: reminder)
			if !success { return }
		} else {
			print("❌ Unknown mode: ", mode)
			return
		}

		// SAVE
		do {
			try eventStore.save(reminder, commit: true)
		} catch {
			print("❌ Failed to save updated reminder: \(error.localizedDescription)")
		}
	} else {
		print("⚠️ No reminder found with ID: \(reminderId)\n")
	}
	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
