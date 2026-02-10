#!/usr/bin/env swift
// -----------------------------------------------------------------------------
// CONFIG
let backupFolder = "~/Library/Mobile Documents/com~apple~CloudDocs/Tech/backups/Calendar & Reminders/"


// -----------------------------------------------------------------------------

import EventKit
import Foundation

let store = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

// -----------------------------------------------------------------------------

func requestRemindersAccess() async -> Bool {
	await withCheckedContinuation { continuation in
		store.requestFullAccessToReminders { granted, error in
			continuation.resume(returning: granted)
		}
	}
}

func requestEventsAccess() async -> Bool {
	await withCheckedContinuation { continuation in
		store.requestFullAccessToEvents { granted, error in
			continuation.resume(returning: granted)
		}
	}
}

func fetchFutureReminders() async -> [EKReminder] {
	await withCheckedContinuation { continuation in
		let predicate = store.predicateForIncompleteReminders(
			withDueDateStarting: Date(),
			ending: nil,
			calendars: nil
		)

		store.fetchReminders(matching: predicate) { reminders in
			continuation.resume(returning: reminders ?? [])
		}
	}
}

func fetchFutureEvents() -> [EKEvent] {
	let start = Date()
	let end = Calendar.current.date(byAdding: .year, value: 5, to: start)!  // adjustable
	let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
	return store.events(matching: predicate)
}

func markdownDate(_ date: Date?) -> String {
	guard let date else { return "No date" }
	let formatter = DateFormatter()
	formatter.locale = Locale.current
	formatter.timeZone = .current
	formatter.dateFormat = "d. MMM. yyyy, HH:mm"
	return formatter.string(from: date)
}

func buildMarkdown(reminders: [EKReminder], events: [EKEvent]) -> String {
	var md = "# Backup\n\n"

	md += "## Future reminders\n\n"
	if reminders.isEmpty {
		md += "- (none)\n"
	} else {
		for r in reminders.sorted(by: {
			($0.dueDateComponents?.date ?? .distantFuture)
				< ($1.dueDateComponents?.date ?? .distantFuture)
		}) {
			let due = markdownDate(r.dueDateComponents?.date)
			let list = r.calendar?.title ?? "Unknown list"
			md += "- \(r.title ?? "(no title)") — due: \(due) — list: \(list)\n"
		}
	}

	md += "\n## Future calendar events\n\n"
	if events.isEmpty {
		md += "- (none)\n"
	} else {
		for e in events.sorted(by: { $0.startDate < $1.startDate }) {
			let start = markdownDate(e.startDate)
			let end = markdownDate(e.endDate)
			let calendar = e.calendar.title
			md += "- \(e.title ?? "(no title)") — \(start) → \(end) — calendar: \(calendar)\n"
		}
	}

	return md
}

func fail(_ msg: String) {
	fputs(msg, stderr)
	semaphore.signal()
}

// -----------------------------------------------------------------------------

Task {  // wrapping in `Task` because `await` is not allowed in `main`
	guard await requestRemindersAccess() else {
		fail("Access to Reminder.app not granted.")
		return
	}
	guard await requestEventsAccess() else {
		fail("Access to Calender.app not granted.")
		return
	}

	let reminders = await fetchFutureReminders()
	let events = fetchFutureEvents()
	let md = buildMarkdown(reminders: reminders, events: events)

	let outputFile = (backupFolder as NSString).expandingTildeInPath + "/Reminders & Events.md"
	let outputURL = URL(fileURLWithPath: outputFile)
	try md.write(to: outputURL, atomically: true, encoding: .utf8)

	print("✅ Backup written to \(outputURL.path)")
	semaphore.signal()
}

_ = semaphore.wait(timeout: .distantFuture)
