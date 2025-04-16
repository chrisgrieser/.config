// DOCS https://developer.apple.com/documentation/eventkit/ekreminder/
// ─────────────────────────────────────────────────────────────────────────────

import EventKit
import Foundation

struct ReminderOutput: Codable {
	// CAVEAT Reminders.app itself does not store URLs in the `url` field, so
	// retrieving that is pointless
	let id: String
	let title: String
	let notes: String?
	let list: String
	let dueDate: String?
	let creationDate: String?
	let isAllDay: Bool
	let isCompleted: Bool
	let hasRecurrenceRules: Bool
	let priority: Int
}

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// Alfred environment variables
let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!
let includeAllLists = ProcessInfo.processInfo.environment["include_all_lists"]! == "1"
let showCompleted = ProcessInfo.processInfo.environment["showCompleted"] == "true"
// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToReminders { granted, error in
	if let error = error {
		print("Error requesting access: \(error.localizedDescription)")
		semaphore.signal()
		return
	}
	guard granted else {
		print("Access to Reminders not granted.")
		semaphore.signal()
		return
	}
	// ──────────────────────────────────────────────────────────────────────────

	// Get list specified or use all lists
	let calendars = eventStore.calendars(for: .reminder)
	let selectedCalendars: [EKCalendar]
	if includeAllLists {
		selectedCalendars = calendars
	} else if let target = calendars.first(where: { $0.title == reminderList }) {
		selectedCalendars = [target]
	} else {
		print("No list found with name \"\(reminderList)\"")
		semaphore.signal()
		return
	}

	// Get reminders from the list and format them. https://developer.apple.com/documentation/eventkit/retrieving-events-and-reminders#Fetch-Reminders
	// PERF using `predicateForIncompleteReminders` has no noticeable performance
	// benefit, however, it does reduce the number of items the JXA script later
	// has to process, resulting in ~0.1s speedup.
	let predicate =
		showCompleted
		? eventStore.predicateForReminders(in: selectedCalendars)
		: eventStore.predicateForIncompleteReminders(
			withDueDateStarting: nil, ending: nil, calendars: selectedCalendars)

	eventStore.fetchReminders(matching: predicate) { reminders in
		guard let reminders = reminders else {
			print("[]")
			semaphore.signal()
			return
		}

		let formatter = ISO8601DateFormatter()
		let reminderData = reminders.map { reminder in
			let components = reminder.dueDateComponents
			let isAllDay = components?.hour == nil && components?.minute == nil

			// normalize priority based on RFC 5545, which Apple uses https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.9
			var prioNormalized = 0
			if reminder.priority > 5 {
				prioNormalized = 1
			} else if reminder.priority == 5 {
				prioNormalized = 2
			} else if reminder.priority < 5 && reminder.priority > 0 {
				prioNormalized = 3
			}

			return ReminderOutput(
				id: reminder.calendarItemIdentifier,
				title: reminder.title ?? "(No Title)",
				notes: reminder.notes,
				list: reminder.calendar.title,
				dueDate: components?.date.flatMap { formatter.string(from: $0) },
				creationDate: reminder.creationDate.flatMap { formatter.string(from: $0) },
				isAllDay: isAllDay,
				isCompleted: reminder.isCompleted,
				hasRecurrenceRules: reminder.hasRecurrenceRules,
				priority: prioNormalized
			)
		}

		// output as stringified JSON
		do {
			let jsonData = try JSONEncoder().encode(reminderData)
			if let jsonString = String(data: jsonData, encoding: .utf8) {
				print(jsonString)
			}
		} catch {
			print("Failed to encode reminders as JSON: \(error.localizedDescription)")
		}
		semaphore.signal()
	}
}

_ = semaphore.wait(timeout: .distantFuture)
