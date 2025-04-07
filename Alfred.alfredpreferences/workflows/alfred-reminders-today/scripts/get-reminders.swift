import EventKit
import Foundation

struct ReminderOutput: Codable {
	let id: String
	let title: String
	let notes: String?
	let dueDate: String?
	let creationDate: String?
	let isAllDay: Bool
	let isCompleted: Bool
}

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

let reminderList = ProcessInfo.processInfo.environment["reminder_list"]!
// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	if let error = error {
		print("❌ Error requesting access: \(error.localizedDescription)")
		semaphore.signal()
		return
	}
	guard granted else {
		print("❌ Access to Reminders not granted.")
		semaphore.signal()
		return
	}

	let calendars = eventStore.calendars(for: .reminder)

	guard let targetCalendar = calendars.first(where: { $0.title == reminderList }) else {
		print("⚠️ No list found with name '\(reminderList)'")
		semaphore.signal()
		return
	}

	let predicate = eventStore.predicateForReminders(in: [targetCalendar])
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

			return ReminderOutput(
				id: reminder.calendarItemIdentifier,
				title: reminder.title ?? "(No Title)",
				notes: reminder.notes,
				dueDate: components?.date.flatMap { formatter.string(from: $0) },
				creationDate: reminder.creationDate.flatMap { formatter.string(from: $0) },
				isAllDay: isAllDay,
				isCompleted: reminder.isCompleted
			)
		}

		do {
			let jsonData = try JSONEncoder().encode(reminderData)
			if let jsonString = String(data: jsonData, encoding: .utf8) {
				print(jsonString)
			}
		} catch {
			print("❌ Failed to encode reminders as JSON: \(error.localizedDescription)")
		}

		semaphore.signal()
	}
}

_ = semaphore.wait(timeout: .distantFuture)
