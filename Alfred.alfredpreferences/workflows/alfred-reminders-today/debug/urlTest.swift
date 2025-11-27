#!/usr/bin/env swift
import Foundation

func fetchWebsiteTitle(from string: String) async throws -> String? {
	guard
		let url = URL(string: string),
		url.scheme != nil && url.host != nil
	else { return nil }

	let (data, _) = try await URLSession.shared.data(from: url)
	guard let html = String(data: data, encoding: .utf8) else { return nil }

	let regex = try! Regex(#"<title>(.*?)</title>"#)

	if let match = try? regex.firstMatch(in: html) {
		return String(html[match.range])
	}
	return nil
}

let title = try? await fetchWebsiteTitle(from: "https://www.apple.com")
print(title ?? "nil")

