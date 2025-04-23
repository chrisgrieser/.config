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

func mapCGColorToEmoji(_ cgColor: CGColor) -> String {
	let components = cgColor.components!
	let (r, g, b) = (components[0], components[1], components[2])

	// Simple thresholds for mapping RGB to base colors
	let redDiff = abs(r - 1.0) + g + b
	let greenDiff = r + abs(g - 1.0) + b
	let blueDiff = r + g + abs(b - 1.0)
	let yellowDiff = abs(r - 1.0) + abs(g - 1.0) + b
	let purpleDiff = abs(r - 1.0) + g + abs(b - 1.0)
	let orangeDiff = abs(r - 1.0) + abs(g - 0.6) + b

	// Adjust the ranges by reducing weights for differences
	let brownDiff = 2.0 * (abs(r - 0.6) + abs(g - 0.4) + abs(b - 0.2))  // less range
	let whiteDiff = 0.7 * (abs(r - 1.0) + abs(g - 1.0) + abs(b - 1.0))  // more range
	let blackDiff = 0.7 * (r + g + b)  // more range

	let diffs = [
		(redDiff, "🔴"),
		(greenDiff, "🟢"),
		(blueDiff, "🔵"),
		(yellowDiff, "🟡"),
		(purpleDiff, "🟣"),
		(orangeDiff, "🟠"),
		(brownDiff, "🟤"),
		(whiteDiff, "⚪"),
		(blackDiff, "⚫"),
	]

	let closest = diffs.min { $0.0 < $1.0 }
	return closest?.1 ?? "?"
}

// ─────────────────────────────────────────────────────────────────────────────

eventStore.requestFullAccessToEvents { granted, error in
	guard error == nil && granted else {
		let msg =
			error != nil
			? "Error requesting access: \(error!.localizedDescription)"
			: "Access to Calendar events not granted."
		print("❌ " + msg)
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
		.filter { event in event.endDate > now }  // only future or ongoing events
		.sorted(by: { $0.startDate < $1.startDate })
		.map { event in
			EventOutput(
				title: event.title,
				startTime: formatter.string(from: event.startDate),
				endTime: formatter.string(from: event.endDate),
				isAllDay: event.isAllDay,
				calendar: event.calendar.title,
				calendarColor: mapCGColorToEmoji(event.calendar.cgColor),
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
		print("❌ Failed to encode JSON: \(error.localizedDescription)")
	}

	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
