#!/usr/bin/swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)
// ─────────────────────────────────────────────────────────────────────────────

let args = CommandLine.arguments
guard args.count > 1 else {
	print("❗ Please provide both the list name as argument.\n")
	exit(1)
}

private(set) var foo: Bool = false

let listName = args[1]  // First argument is the name of the list (calendar)

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

		// Filter reminders: Not completed, due today or past
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())

		let filteredReminders = reminders.filter { reminder in
			guard !reminder.isCompleted else { return false }

			if let dueDate = reminder.dueDateComponents?.date {
				// Compare only the date part (ignoring time)
				let dueDateStartOfDay = calendar.startOfDay(for: dueDate)
				return dueDateStartOfDay <= today
			}
			return false
		}

		print(filteredReminders.count)
		semaphore.signal()
	}
}

_ = semaphore.wait(timeout: .distantFuture)
