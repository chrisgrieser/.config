#!/usr/bin/env swift
import Foundation

func fetchWebsiteTitle(from string: String) async throws -> String? {
	guard
		let url = URL(string: string),
		url.scheme != nil && url.host != nil
	else { return nil }
	fputs("🪚 url: \(url)\n", stderr)

	let (data, _) = try await URLSession.shared.data(from: url)
	guard let html = String(data: data, encoding: .utf8) else { return nil }

	let regex = try! Regex(#"<title>(.*?)</title>"#)

	if let match = try? regex.firstMatch(in: html) {
		return String(match.output[1].substring!)
	}
	return nil
}

let title = try? await fetchWebsiteTitle(from: "http://www.stackoverflow.com")
print(title ?? "nil")

