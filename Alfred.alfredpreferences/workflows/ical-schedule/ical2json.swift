#!/usr/bin/swift
import EventKit
import Foundation

func formatEventDetails(event: EKEvent) -> String {
	let now = Date()
	let calendar = Calendar.current
	let startDate = event.startDate!
	let endDate = event.endDate!

	// Formatters
	let timeFormatter = DateFormatter()
	timeFormatter.timeStyle = .short
	timeFormatter.dateStyle = .none

	let dateFormatter = DateFormatter()
	dateFormatter.dateStyle = .medium
	dateFormatter.timeStyle = .none

	let relativeFormatter = RelativeDateTimeFormatter()
	relativeFormatter.unitsStyle = .short

	let durationFormatter = DateComponentsFormatter()
	durationFormatter.allowedUnits = [.hour, .minute]
	durationFormatter.unitsStyle = .abbreviated
	durationFormatter.maximumUnitCount = 2

	// Start/end time string
	var timeString = ""
	let sameDay = calendar.isDate(startDate, inSameDayAs: endDate)

	if event.isAllDay {
		if calendar.isDateInToday(startDate) {
			timeString = "All day today"
		} else if calendar.isDateInTomorrow(startDate) {
			timeString = "All day tomorrow"
		} else {
			timeString = "All day \(dateFormatter.string(from: startDate))"
		}
	} else if sameDay {
		let dayString: String
		if calendar.isDateInToday(startDate) {
			dayString = "Today"
		} else if calendar.isDateInTomorrow(startDate) {
			dayString = "Tomorrow"
		} else {
			dayString = dateFormatter.string(from: startDate)
		}
		timeString =
			"\(dayString), \(timeFormatter.string(from: startDate)) - \(timeFormatter.string(from: endDate))"
	} else {
		timeString =
			"\(dateFormatter.string(from: startDate)) \(timeFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate)) \(timeFormatter.string(from: endDate))"
	}

	// Time until event
	let timeUntil: String
	if startDate < now {
		timeUntil = "\(relativeFormatter.localizedString(for: startDate, relativeTo: now))"
	} else {
		timeUntil = "\(relativeFormatter.localizedString(for: startDate, relativeTo: now))"
	}

	// Combine information - skip duration for all-day events
	if event.isAllDay {
		return "\(timeString) • \(timeUntil)"
	} else {
		let duration = durationFormatter.string(from: startDate, to: endDate) ?? ""
		return "\(timeString) • \(duration) • \(timeUntil)"
	}
}

struct CalendarEvent: Codable {
	let uid: String
	let title: String
	let startDate: Date
	let endDate: Date
	let isAllDay: Bool
	let location: String?
	let notes: String?
	let arg: URL?
	let calendar: String
	let subtitle: String

	// Create from EKEvent
	init(from event: EKEvent) {
		self.uid = event.eventIdentifier ?? UUID().uuidString
		self.title = event.title ?? "Untitled"
		self.startDate = event.startDate
		self.endDate = event.endDate
		self.isAllDay = event.isAllDay
		self.location = event.location
		self.notes = event.notes
		self.arg = event.url
		self.calendar = event.calendar.title
		self.subtitle = formatEventDetails(event: event)
	}
}

struct AlfredItems: Codable {
	let items: [CalendarEvent]
	init(from events: [CalendarEvent]) {
		self.items = events
	}
}

extension Array where Element == EKEvent {
	func toJSON() -> String? {
		// Convert EKEvents to our Codable struct
		let events = self.map { CalendarEvent(from: $0) }
		let items = AlfredItems(from: events)

		// Create JSON encoder with formatting
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

		// Encode to JSON data then to string
		guard let jsonData = try? encoder.encode(items) else {
			return nil
		}

		return String(data: jsonData, encoding: .utf8)
	}
}

class CalendarManager {
	let eventStore = EKEventStore()
	func requestAccess(completion: @escaping (Bool) -> Void) {
		if #available(macOS 14, *) {
			self.eventStore.requestFullAccessToEvents { granted, error in
				if let error {
					print(error)
					completion(false)
					return
				}
				completion(granted)
			}
		} else {
			self.eventStore.requestAccess(to: .event) { granted, error in
				if let error {
					print(error)
					completion(false)
					return
				}
				completion(granted)
			}
		}
	}

	func fetchEvents(days: Int) -> [EKEvent] {
		let startDate = Date()
		let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!
		let predicate = self.eventStore.predicateForEvents(
			withStart: startDate, end: endDate, calendars: nil)

		return self.eventStore.events(matching: predicate)
	}

}

func main() {
	let manager = CalendarManager()
	let defaultDays = 3
	let days =
		CommandLine.arguments.count > 1 && Int(CommandLine.arguments[1]) != nil
		? Int(CommandLine.arguments[1])! : defaultDays
	// Create semaphore to wait for async completion
	let semaphore = DispatchSemaphore(value: 0)

	var accessGranted = false
	manager.requestAccess { granted in
		accessGranted = granted
		semaphore.signal()
	}

	// Wait for calendar access request to complete
	semaphore.wait()

	if accessGranted {
		print(manager.fetchEvents(days: days).toJSON() ?? "failed to fetch events")
	} else {
		print("access denied")
	}

}

main()
