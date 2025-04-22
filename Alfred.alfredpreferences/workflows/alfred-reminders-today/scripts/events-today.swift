#!/usr/bin/env swift

import EventKit
import Foundation

struct EventOutput: Codable {
	let title: String
	let startTime: String
	let endTime: String
	let isAllDay: Bool
	let calendar: String
	let location: String
	let hasRecurrenceRules: Bool
}

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	guard granted, error == nil else {
		print("❌ Access denied or error: \(error?.localizedDescription ?? "Unknown error")")
		semaphore.signal()
		return
	}

	let calendars = eventStore.calendars(for: .event)
	let startOfDay = Calendar.current.startOfDay(for: Date())
	let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

	let predicate = eventStore.predicateForEvents(
		withStart: startOfDay, end: endOfDay, calendars: calendars)
	let events = eventStore.events(matching: predicate)

	let formatter = ISO8601DateFormatter()
	formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

	let outputEvents = events.sorted(by: { $0.startDate < $1.startDate }).map { event in
		EventOutput(
			title: event.title ?? "No Title",
			startTime: formatter.string(from: event.startDate),
			endTime: formatter.string(from: event.endDate),
			isAllDay: event.isAllDay,
			calendar: event.calendar.title,
			location: event.location ?? "",
			hasRecurrenceRules: event.hasRecurrenceRules
		)
	}

	do {
		let jsonData = try JSONEncoder().encode(outputEvents)
		if let jsonString = String(data: jsonData, encoding: .utf8) {
			print(jsonString)
		}
	} catch {
		print("❌ Failed to encode JSON: \(error.localizedDescription)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
