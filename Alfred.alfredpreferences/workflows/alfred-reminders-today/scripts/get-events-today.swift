#!/usr/bin/env swift

import EventKit
import Foundation

struct EventOutput: Codable {
	let title: String
	let startTime: String
	let endTime: String
	let isAllDay: Bool
	let calendar: String
	let location: String?
	let hasRecurrenceRules: Bool
}

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	if let error = error {
		print("Error requesting access to Calendar events: \(error.localizedDescription)")
		semaphore.signal()
		return
	}
	guard granted else {
		print("Access to Calendar events not granted.")
		semaphore.signal()
		return
	}
	// ──────────────────────────────────────────────────────────────────────────

	let calendars = eventStore.calendars(for: .event)
	let now = Date()
	let startOfDay = Calendar.current.startOfDay(for: now)
	let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

	let predicate = eventStore.predicateForEvents(
		withStart: startOfDay, end: endOfDay, calendars: calendars)
	let events = eventStore.events(matching: predicate)

	// Include events that start after now or are ongoing
	let filteredEvents = events.filter { event in
		return event.endDate > now
	}

	let formatter = ISO8601DateFormatter()
	formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

	let outputEvents = filteredEvents.sorted(by: { $0.startDate < $1.startDate }).map { event in
		EventOutput(
			title: event.title,
			startTime: formatter.string(from: event.startDate),
			endTime: formatter.string(from: event.endDate),
			isAllDay: event.isAllDay,
			calendar: event.calendar.title,
			location: event.location ?? event.url?.absoluteString, // fallback to URL
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
