#!/usr/bin/env swift
import EventKit
import Foundation

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let listName = "Tasks"  // CONFIG

// -----------------------------------------------------------------------------

eventStore.requestFullAccessToReminders { granted, error in
	if let error = error {
		print("❌ Error requesting access: \(error.localizedDescription)\n")
		exit(1)
	}
	guard granted else {
		print("❌ Access to Reminders not granted.\n")
		exit(1)
	}

	guard let list = eventStore.calendars(for: .reminder).first(where: { $0.title == listName })
	else {
		print("❌ No list found with the name '\(listName)'.\n")
		exit(1)
	}

	let predicate = eventStore.predicateForReminders(in: [list])
	eventStore.fetchReminders(matching: predicate) { reminders in
		guard let allReminders = reminders else {
			print("❌ Failed to fetch reminders.\n")
			exit(1)
		}

		// include open reminders yesterday for reminders carrying over
		let remindersDueNow = allReminders.filter { rem in
			if rem.isCompleted { return false }
			return (rem.dueDateComponents?.date ?? Date.distantFuture) <= Date.now
		}

		print(remindersDueNow.count)
		semaphore.signal()
	}
}

_ = semaphore.wait(timeout: .distantFuture)
