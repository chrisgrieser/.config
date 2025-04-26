#!/usr/bin/env swift

import EventKit
import Foundation

let titleToFind = CommandLine.arguments.dropFirst().joined(separator: " ")
guard !titleToFind.isEmpty else {
	print("Usage: FindReminder.swift \"Reminder Title\"")
	exit(1)
}

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	guard granted else {
		print("Access to reminders not granted: \(error?.localizedDescription ?? "Unknown error")")
		semaphore.signal()
		return
	}

	let predicate = eventStore.predicateForReminders(in: nil)
	eventStore.fetchReminders(matching: predicate) { reminders in
		defer { semaphore.signal() }

		guard let reminders = reminders else {
			print("No reminders found or error occurred")
			return
		}

		guard let reminder = reminders.first(where: { $0.title == titleToFind }) else {
			print("Reminder with title \"\(titleToFind)\" not found.")
			return
		}

		prettyPrintReminder(reminder)
	}
}

func prettyPrintReminder(_ reminder: EKReminder) {
	print("=== Reminder Details ===")
	print("Title: \(reminder.title ?? "nil")")
	print("Notes: \(reminder.notes ?? "nil")")
	print("List: \(reminder.calendar.title)")
	print("Completed: \(reminder.isCompleted)")
	print("Completion Date: \(reminder.completionDate?.description ?? "nil")")
	print("Due Date: \(reminder.dueDateComponents?.date?.description ?? "nil")")
	print("Start Date: \(reminder.startDateComponents?.date?.description ?? "nil")")
	print("Priority: \(reminder.priority)")
	print("Has Alarms: \(reminder.hasAlarms)")
	if let alarms = reminder.alarms {
		for (index, alarm) in alarms.enumerated() {
			print("Alarm \(index + 1):")
			if let absoluteDate = alarm.absoluteDate {
				print("  - Absolute Date: \(absoluteDate)")
			}
			if let relativeOffset = alarm.relativeOffset as TimeInterval? {
				print("  - Relative Offset: \(relativeOffset) seconds")
			}
		}
	}
	print("========================")
}

_ = semaphore.wait(timeout: .distantFuture)
