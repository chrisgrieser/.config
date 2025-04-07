#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
// ─────────────────────────────────────────────────────────────────────────────

let args = CommandLine.arguments
guard args.count > 1 else {
	print("❗ Please provide the title of the reminder as an argument.\n")
	exit(1)
}

let reminderTitle = args[1]

let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!
// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
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

	// Set the reminder as an all-day reminder (no hour or minute)
	let calendar = Calendar.current
	let today = Date()
	var todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
	todayComponents.hour = nil
	todayComponents.minute = nil
	reminder.dueDateComponents = todayComponents

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
		print(reminderTitle) // for Alfred notification
	} catch {
		print("❌ Failed to create reminder: \(error.localizedDescription)\n")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
