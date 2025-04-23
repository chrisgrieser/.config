#!/usr/bin/env swift

import EventKit
import Foundation

struct EventOutput: Codable {
	let title: String
	let startTime: String
	let endTime: String
	let isAllDay: Bool
	let calendar: String
	let calendarColor: String
	let location: String?
	let hasRecurrenceRules: Bool
}

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// ─────────────────────────────────────────────────────────────────────────────

func mapCGColorToBaseColor(_ cgColor: CGColor) -> String {
	guard let components = cgColor.components else { return "⚫" }
	let r = components[0]
	let g = components.count >= 3 ? components[1] : r
	let b = components.count >= 3 ? components[2] : r

	// Simple thresholds for mapping RGB to base colors
	if r > 0.8 && g < 0.2 && b < 0.2 {
		return "🔴"
	} else if r < 0.2 && g > 0.8 && b < 0.2 {
		return "🟢"
	} else if r < 0.2 && g < 0.2 && b > 0.8 {
		return "🔵"
	} else if r > 0.8 && g > 0.8 && b < 0.2 {
		return "🟡"
	} else if r > 0.5 && g < 0.2 && b > 0.5 {
		return "🟣"
	} else if r > 0.8 && g > 0.4 && b < 0.2 {
		return "🟠"
	} else if r > 0.9 && g > 0.9 && b > 0.9 {
		return "⚪"
	} else if r < 0.2 && g < 0.2 && b < 0.2 {
		return "⚫"
	} else {
		return "⚫"
	}
}

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

	let formatter = ISO8601DateFormatter()

	let outputEvents =
		eventStore.events(matching: predicate)
		.filter { event in return event.endDate > now }  // only future or ongoing events
		.sorted(by: { $0.startDate < $1.startDate })
		.map { event in
			// let baseColor = mapCGColorToBaseColor(event.calendar.cgColor)
			let baseColor = 
			return EventOutput(
				title: event.title,
				startTime: formatter.string(from: event.startDate),
				endTime: formatter.string(from: event.endDate),
				isAllDay: event.isAllDay,
				calendar: event.calendar.title,
				calendarColor: baseColor,
				location: event.location ?? event.url?.absoluteString,  // fallback to URL
				hasRecurrenceRules: event.hasRecurrenceRules
			)
		}

	do {
		let jsonData = try JSONEncoder().encode(outputEvents)
		if let jsonString = String(data: jsonData, encoding: .utf8) {
			print(jsonString)
		}
	} catch {
		print("Failed to encode JSON: \(error.localizedDescription)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
