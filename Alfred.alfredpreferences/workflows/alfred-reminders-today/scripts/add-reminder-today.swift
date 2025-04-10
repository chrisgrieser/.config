#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
// ─────────────────────────────────────────────────────────────────────────────

let reminderTitle = CommandLine.arguments[1]
let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!
let when = ProcessInfo.processInfo.environment["when_to_add"]!

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToReminders { granted, error in
	if let error = error {
		print("❌ Error requesting access: \(error.localizedDescription)\n")
		semaphore.signal()
		return
	}
	guard granted else {
		print("❌ Access to Reminders not granted.\n")
		semaphore.signal()
		return
	}

	// Create a new reminder
	let reminder = EKReminder(eventStore: eventStore)
	reminder.title = reminderTitle
	reminder.isCompleted = false

	// determine when to add
	let calendar = Calendar.current
	let today = Date()
	var dayToUse: Date
	if when == "today" {
		dayToUse = today
	} else if when == "tomorrow" {
		let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
		dayToUse = tomorrow
	} else {
		print("❌ Invalid value for 'when_to_add' environment variable.\n")
		semaphore.signal()
		return
	}

	// Set the reminder as an all-day reminder (no hour or minute)
	var dateComponents = calendar.dateComponents([.year, .month, .day], from: dayToUse)
	dateComponents.hour = nil
	dateComponents.minute = nil
	reminder.dueDateComponents = dateComponents

	// Find the calendar (list) by name
	if let calendarList = eventStore.calendars(for: .reminder).first(where: {
		$0.title == reminderList
	}) {
		reminder.calendar = calendarList
	} else {
		print("❌ No calendar found with the name '\(reminderList)'.\n")
		semaphore.signal()
		return
	}

	// Save
	do {
		try eventStore.save(reminder, commit: true)
		print(reminderTitle)  // for Alfred notification
	} catch {
		print("❌ Failed to create reminder: \(error.localizedDescription)\n")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
