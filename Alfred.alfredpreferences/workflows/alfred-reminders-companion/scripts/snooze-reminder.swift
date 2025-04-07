#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
let reminderId = ProcessInfo.processInfo.environment["id"]!

eventStore.requestFullAccessToEvents { granted, error in
	if let reminder = eventStore.calendarItem(withIdentifier: reminderId) as? EKReminder {

		// ─────────────────────────────────────────────────────────────────────────────
		// Get tomorrow's date
		let calendar = Calendar.current
		let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
		var tomorrowComponents = calendar.dateComponents(
			[.year, .month, .day, .hour, .minute], from: tomorrow)

		// Check if the reminder was an all-day reminder
		let isAllDay =
			reminder.dueDateComponents?.hour == nil && reminder.dueDateComponents?.minute == nil

		// If it's an all-day reminder, preserve it as all-day
		if isAllDay {
			tomorrowComponents.hour = nil
			tomorrowComponents.minute = nil
		}
		// ─────────────────────────────────────────────────────────────────────────────

		// Set the new due date (tomorrow), while preserving all-day status if applicable
		reminder.dueDateComponents = tomorrowComponents

		do {
			try eventStore.save(reminder, commit: true)
		} catch {
			print("❌ Failed to save updated reminder: \(error.localizedDescription)\n")
		}
	} else {
		print("⚠️ Reminder not found with ID: \(reminderId)\n")
	}
	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
