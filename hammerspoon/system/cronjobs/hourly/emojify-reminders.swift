#!/usr/bin/env swift
import EventKit

// -----------------------------------------------------------------------------

let config = [
	"reminderList": "Tasks",
	"openaiApiKey": ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
	"apiKeyFilepath":  // fallback if no OPENAI_API_KEY provided
		"~/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt",
	"openaiModel": "gpt-5-nano",
	"reasoningEffort": "minimal",
	"systemPrompt": """
		Replace item in the following text with exactly one emoji that thematically
		fits the item. Respond with one emoji per line. Try to use different emojis
		for different items.

		Example input:
		- buy milk
		- clean kitchen

		Example output:
		- 🍼
		- 🧼

		The text is:
	""",
]

// -----------------------------------------------------------------------------

let eventStore = EKEventStore()
let semaphore = DispatchSemaphore(value: 0)

func requestRemindersAccess() async -> Bool {
	await withCheckedContinuation { continuation in
		eventStore.requestFullAccessToReminders { granted, error in
			continuation.resume(returning: granted)
		}
	}
}

func fetchReminders(_ store: EKEventStore, _ predicate: NSPredicate) async -> [EKReminder] {
	await withCheckedContinuation { continuation in
		store.fetchReminders(matching: predicate) { reminders in
			continuation.resume(returning: reminders ?? [])
		}
	}
}

extension Character {
	var isEmoji: Bool {
		unicodeScalars.contains { $0.properties.isEmojiPresentation }
			|| unicodeScalars.contains { $0.properties.isEmoji && $0.value > 0x238C }
	}
}

func openaiRequest(_ input: String) async throws -> String? {
	var openaiApiKey = (config["openaiApiKey"] ?? "") ?? ""
	if openaiApiKey.isEmpty {
		let path = config["apiKeyFilepath"]!! as NSString
		let fileUrl = URL(fileURLWithPath: path.expandingTildeInPath)
		let contents = try String(contentsOf: fileUrl, encoding: .utf8)
		openaiApiKey = contents.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	let url = URL(string: "https://api.openai.com/v1/responses")!
	var req = URLRequest(url: url)
	req.httpMethod = "POST"
	req.addValue("Bearer \(openaiApiKey)", forHTTPHeaderField: "Authorization")
	req.addValue("application/json", forHTTPHeaderField: "Content-Type")

	let body: [String: Any] = [
		"model": config["openaiModel"]!!,
		"reasoning": ["effort": config["reasoningEffort"]],
		"input": [
			["role": "system", "content": config["systemPrompt"]],
			["role": "user", "content": input],
		],
	]
	req.httpBody = try JSONSerialization.data(withJSONObject: body)

	let (data, _) = try await URLSession.shared.data(for: req)
	let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
	if !(json["error"] is NSNull) {
		let message = (json["error"] as! [String: Any])["message"] as! String
		print("❌ OpenAI Error: \(message)")
		exit(1)
	}

	let output = json["output"] as! [[String: Any]]
	let content = output[1]["content"] as! [[String: Any]]
	let text = (content[0]["text"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
	return text
}

// -----------------------------------------------------------------------------

Task {  // wrapping in `Task` because top-level `await` is not allowed

	// Get open reminders without emoji
	guard await requestRemindersAccess() else {
		print("❌ Access to Reminder.app not granted.")
		exit(1)
	}
	let calendars = eventStore.calendars(for: .reminder)
	guard let reminderList = calendars.first(where: { $0.title == config["reminderList"] }) else {
		print("❌ No list found with name \"\(config["reminderList"]!!)\"")
		exit(1)
	}
	let predicate = eventStore.predicateForIncompleteReminders(
		withDueDateStarting: nil, ending: nil, calendars: [reminderList])
	let remWithNoEmoji = await fetchReminders(eventStore, predicate)
		.filter { $0.title.first?.isEmoji == false }
	let titles =
		remWithNoEmoji
		.map { "- " + $0.title.replacingOccurrences(of: "\n", with: " ") }  // using bullet list helps AI
		.joined(separator: "\n")
	if titles.isEmpty {
		print("✅ No reminders to update.")
		exit(0)
	}

	// AI request
	guard let response = try await openaiRequest(titles) else { exit(1) }
	let emojis = response.split(separator: "\n")
		.map { $0.replacingOccurrences(of: "- ", with: "") }  // AI tends to respond in kind with bullet list
	if emojis.count != remWithNoEmoji.count {
		print("⚠️ \(remWithNoEmoji.count) reminders, but AI provided \(emojis.count). ")
	}

	// Update reminders
	for (i, emoji) in emojis.enumerated() {
		if i >= remWithNoEmoji.count { break }
		let rem = remWithNoEmoji[i]
		rem.title = String(emoji) + " " + rem.title
		do {
			try eventStore.save(rem, commit: true)
		} catch {
			print("❌ Failed to save updated reminder: \(error.localizedDescription)")
			exit(1)
		}
	}

	let s = remWithNoEmoji.count == 1 ? "" : "s"
	print("✅ Added emoji to \(remWithNoEmoji.count) reminder\(s).")
	semaphore.signal()
}
_ = semaphore.wait(timeout: .distantFuture)
