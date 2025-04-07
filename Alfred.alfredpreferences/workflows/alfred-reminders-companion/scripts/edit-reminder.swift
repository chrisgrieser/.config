#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
let reminderId = ProcessInfo.processInfo.environment["id"]!
let modification = ProcessInfo.processInfo.environment["modification"]!
// ─────────────────────────────────────────────────────────────────────────────

func toggleCompleted(reminder: EKReminder) {
	reminder.isCompleted = !reminder.isCompleted
}

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {
		// ─────────────────────────────────────────────────────────────────────────────
		if modification == "toggle-completed" {
			toggleCompleted(reminder: reminder)
		} else if modification == "snooze" {
		} else {

		}
		// ─────────────────────────────────────────────────────────────────────────────

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
