#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
let reminderID = ProcessInfo.processInfo.environment["id"]
if reminderID == nil {
	exit(1)
}
// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	if let reminder = eventStore.calendarItem(withIdentifier: reminderID) as? EKReminder {
		reminder.isCompleted = !reminder.isCompleted

		do {
			try eventStore.save(reminder, commit: true)
			print("✅ Successfully toggled the completion status")
		} catch {
			print("❌ Failed to save updated reminder: \(error.localizedDescription)")
		}
	} else {
		print("⚠️ Reminder not found with ID: \(reminderID)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
