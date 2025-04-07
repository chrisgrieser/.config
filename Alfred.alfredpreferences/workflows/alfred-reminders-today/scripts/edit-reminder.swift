#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
// ─────────────────────────────────────────────────────────────────────────────

let reminderId = ProcessInfo.processInfo.environment["id"]!
let mode = ProcessInfo.processInfo.environment["mode"]!

// ─────────────────────────────────────────────────────────────────────────────

func toggleCompleted(reminder: EKReminder) {
	reminder.isCompleted = !reminder.isCompleted
}

func snoozeToTomorrow(reminder: EKReminder) {
	// Get tomorrow's date
	let calendar = Calendar.current
	let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
	var tomorrowComponents = calendar.dateComponents(
		[.year, .month, .day, .hour, .minute], from: tomorrow)

	// If an all-day reminder, preserve it as all-day
	let isAllDay =
		reminder.dueDateComponents?.hour == nil && reminder.dueDateComponents?.minute == nil
	if isAllDay {
		tomorrowComponents.hour = nil
		tomorrowComponents.minute = nil
	}

	reminder.dueDateComponents = tomorrowComponents
}

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {

		// modify
		if mode == "toggle-completed" {
			toggleCompleted(reminder: reminder)
		} else if mode == "snooze" {
			snoozeToTomorrow(reminder: reminder)
		}

		// save
		do {
			try eventStore.save(reminder, commit: true)
		} catch {
			print("❌ Failed to save updated reminder: \(error.localizedDescription)")
		}
	} else {
		print("⚠️ Reminder not found with ID: \(reminderId)\n")
	}
	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
