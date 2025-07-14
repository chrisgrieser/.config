#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
// ─────────────────────────────────────────────────────────────────────────────

let args = CommandLine.arguments
guard args.count != 1 else {
	print("❗ Please provide the list name as argument, and nothing else.\n")
	exit(1)
}

let listName = args[1]

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

	// Find the calendar (list) by name
	guard
		let calendarList = eventStore.calendars(for: .reminder).first(where: { $0.title == listName })
	else {
		print("❌ No calendar found with the name '\(listName)'.\n")
		semaphore.signal()
		return
	}

	// Get all reminders from that calendar
	let predicate = eventStore.predicateForReminders(in: [calendarList])

	eventStore.fetchReminders(matching: predicate) { reminders in
		guard let reminders = reminders else {
			print("❌ Failed to fetch reminders.\n")
			semaphore.signal()
			return
		}

		let remindersDueNow = reminders.filter { rem in
			if rem.isCompleted { return false }
			return (rem.dueDateComponents?.date ?? Date.distantFuture) <= Date.now
		}

		print(remindersDueNow.count)
		semaphore.signal()
	}
}

_ = semaphore.wait(timeout: .distantFuture)
