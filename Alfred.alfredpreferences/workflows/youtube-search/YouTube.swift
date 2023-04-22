#!/usr/bin/env swift

import Foundation

/// Builds a URL with the specified endpoint and query parameters.
///
/// - Parameters:
///   - endpoint: The API endpoint as a string.
///   - queryParams: A dictionary of query parameters where the key is the parameter name and the
///     value is the parameter value.
/// - Returns: An optional `URL` constructed using the given endpoint and query parameters.
func buildURL(with endpoint: String, using queryParams: [String: String]) -> URL? {
  guard var components = URLComponents(string: endpoint) else { return nil }
  components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
  return components.url
}

/// Decodes HTML entities in the given string.
///
/// - Parameter rawEntity: A string containing HTML entities.
/// - Returns: A new string with HTML entities replaced with their corresponding characters.
func decodeHTMLEntities(_ rawEntity: String) -> String {
  guard let processedEntity: CFString = CFXMLCreateStringByUnescapingEntities(
    nil,
    rawEntity as CFString,
    nil
  ) else {
    return rawEntity as String
  }
  return processedEntity as String
}

/// Serializes the provided `alfredItems` dictionary into JSON data.
///
/// - Parameter alfredItems: A dictionary containing items in the format expected by Alfred.
/// - Throws: If the provided dictionary cannot be serialized into JSON data.
/// - Returns: The JSON data representation of `alfredItems`.
func serializeJSON(_ alfredItems: [String: [[String: Any]]]) throws -> Data {
  try JSONSerialization.data(withJSONObject: alfredItems, options: .prettyPrinted)
}

/// Handles API error responses by extracting the relevant error information and displaying it.
///
/// - Parameter errorInfo: A dictionary containing error information.
func handleAPIError(_ errorInfo: [String: Any]) {
  if let code: Int = errorInfo["code"] as? Int,
     let rawMessage: String = errorInfo["message"] as? String,
     let errors: [[String: Any]] = errorInfo["errors"] as? [[String: Any]],
     let firstError: [String: Any] = errors.first {
    let message: String = rawMessage.replacingOccurrences(
      of: "<[^>]+>",
      with: "",
      options: .regularExpression
    )
    let reason: String = firstError["reason"] as? String ?? "Unknown reason"
    let extendedHelp: String = firstError["extendedHelp"] as? String ?? "No extended help available"
    fputs(
      ".\nError Code: \(code)\nMessage: \(message)\nReason: \(reason)\nExtended Help: \(extendedHelp)",
      stderr
    )
  } else {
    fputs(".\nAPI Error: Unable to parse error information.", stderr)
  }

  exit(1)
}

/// Parses the elapsed time since a video was published into a human-readable string.
///
/// - Parameter publishedAt: The video's published date in ISO 8601 format.
/// - Returns: An optional string representing the elapsed time since the video was published, or
///   `nil` if the input is not valid.
func parseElapsedTime(from publishedAt: String) -> String? {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
  dateFormatter.locale = Locale(identifier: "en_US_POSIX")

  guard let date: Date = dateFormatter.date(from: publishedAt) else { return nil }

  let calendar = Calendar.current
  let dateComponents: DateComponents = calendar.dateComponents(
    [.year, .month, .day, .hour, .minute],
    from: date,
    to: Date()
  )

  if let years: Int = dateComponents.year, years > 0 {
    return "\(years) year\(years > 1 ? "s" : "") ago"
  } else if let months: Int = dateComponents.month, months > 0 {
    return "\(months) month\(months > 1 ? "s" : "") ago"
  } else if let days: Int = dateComponents.day, days > 0 {
    if days >= 14, days <= 31 {
      let weeks: Int = days / 7
      return "\(weeks) week\(weeks > 1 ? "s" : "") ago"
    }
    return "\(days) day\(days > 1 ? "s" : "") ago"
  } else if let hours: Int = dateComponents.hour, hours > 0 {
    return "\(hours) hour\(hours > 1 ? "s" : "") ago"
  } else if let minutes: Int = dateComponents.minute, minutes > 0 {
    return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
  }

  return "Just now"
}

/// Parses and processes video information from the YouTube API's JSON response.
///
/// - Parameter json: A dictionary representing the JSON response from the YouTube API containing
///   video snippets.
/// - Returns: An array of dictionaries containing formatted video information compatible with
///   Alfred.
func parseSnippetJSON(_ json: [String: Any]) -> [[String: Any]] {
  guard let items: [[String: Any]] = json["items"] as? [[String: Any]] else {
    fputs("Error: Unable to get items from JSON.", stderr)
    exit(1)
  }

  var alfredItems: [[String: Any]] = []

  for item: [String: Any] in items {
    if let id: [String: Any] = item["id"] as? [String: Any],
       let videoId: String = id["videoId"] as? String,
       let snippet: [String: Any] = item["snippet"] as? [String: Any],
       let rawTitle: String = snippet["title"] as? String,
       let rawChannelTitle: String = snippet["channelTitle"] as? String,
       let publishedAt: String = snippet["publishedAt"] as? String {
      let title: String = decodeHTMLEntities(rawTitle)
      let channelTitle: String = decodeHTMLEntities(rawChannelTitle)
      let elapsedTime: String = parseElapsedTime(from: publishedAt) ?? "Unknown time"

      // Create a result item with video and channel information
      let alfredItem: [String: Any] = [
        "uid": videoId,
        "title": title,
        "channelTitle": channelTitle,
        "elapsedTime": elapsedTime,
        "arg": "https://www.youtube.com/watch?v=\(videoId)",
      ]
      alfredItems.append(alfredItem)
    }
  }

  return alfredItems
}

/// Parses the JSON response from the YouTube API containing video statistics and extracts view counts.
///
/// - Parameter json: A dictionary representing the JSON response from the YouTube API containing
///   video statistics.
/// - Returns: A dictionary with video IDs as keys and view counts as values.
func parseStatisticsJSON(_ json: [String: Any]) -> [String: Int] {
  guard let items: [[String: Any]] = json["items"] as? [[String: Any]] else { return [:] }

  var viewCounts: [String: Int] = [:]

  for item: [String: Any] in items {
    if let id: String = item["id"] as? String,
       let statistics: [String: Any] = item["statistics"] as? [String: Any],
       let viewCount = Int(statistics["viewCount"] as? String ?? "0") {
      viewCounts[id] = viewCount
    }
  }

  return viewCounts
}

/// Formats a given view count for display in the Alfred item subtitle.
///
/// - Parameter count: The number of views to format.
/// - Returns: A formatted view count string with a unit (e.g., "K" or "M") if appropriate.
func formatViewCount(_ count: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = 1
  formatter.locale = Locale(identifier: "en_US")

  if count >= 1_000_000 {
    let millions = Double(count) / 1_000_000.0
    let formatted: String = formatter.string(from: NSNumber(value: millions)) ?? String(millions)
    return "\(formatted)M views"
  } else if count >= 1000 {
    let thousands = Double(count) / 1000.0
    let formatted: String = formatter.string(from: NSNumber(value: thousands)) ?? String(thousands)
    return "\(formatted)K views"
  } else {
    return "\(count) views"
  }
}

/// Combines the results of `parseSnippetJSON` and `parseStatisticsJSON` to create an array of
/// dictionaries in Alfred's feedback format.
///
/// - Parameters:
/// - items: An array of dictionaries in the format returned by `parseSnippetJSON`.
/// - viewCounts: A dictionary with video IDs as keys and view counts as values returned by
///   `parseStatisticsJSON`.
/// - Returns: A dictionary containing an `items` key with an array of dictionaries in the format
///   expected by Alfred.
func createAlfredItems(
  from items: [[String: Any]],
  with viewCounts: [String: Int]
) -> [String: [[String: Any]]] {
  var alfredItems: [[String: Any]] = []

  for item: [String: Any] in items {
    guard let videoId: String = item["uid"] as? String,
          let channelTitle: String = item["channelTitle"] as? String,
          let elapsedTime: String = item["elapsedTime"] as? String,
          let title: Any = item["title"],
          let arg: Any = item["arg"]
    else {
      continue
    }

    let rawViewCount: Int = viewCounts[videoId] ?? 0
    let viewCount: String = formatViewCount(rawViewCount)
    let subtitle = "\(channelTitle) • \(viewCount) • \(elapsedTime)"

    let alfredItem: [String: Any] = [
      "uid": videoId,
      "title": title,
      "subtitle": subtitle,
      "arg": arg,
      "type": "default",
    ]
    alfredItems.append(alfredItem)
  }

  return ["items": alfredItems]
}

/// Handles the response from the YouTube API's search endpoint, sends a request to the videos
/// endpoint, and prints the resulting Alfred feedback.
///
/// - Parameter apiKey: The YouTube API key used to authenticate the request.
/// - Returns: A closure that takes `Data?`, `URLResponse?`, and `Error?` as arguments.
func handleResponse(apiKey: String) -> (Data?, URLResponse?, Error?) -> Void {
  { data, _, error in
    // Check for network errors.
    guard let data: Data = data, error == nil else {
      fputs(".\nError: \(error?.localizedDescription ?? "Unknown error.")", stderr)
      exit(1)
    }

    // Parse the JSON object into a dictionary, or display an error message if unsuccessful.
    guard let json: [String: Any] = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      fputs(".\nError: Unable to parse JSON.", stderr)
      exit(1)
    }

    // Check if there's an error in the API response.
    if let apiError: [String: Any] = json["error"] as? [String: Any] {
      handleAPIError(apiError)
    } else {
      let items: [[String: Any]] = parseSnippetJSON(json)
      let videoIds: String = items.compactMap { $0["uid"] as? String }.joined(separator: ",")

      let endpoint = "https://www.googleapis.com/youtube/v3/videos"
      let queryParams: [String: String] = ["part": "statistics", "id": videoIds, "key": apiKey]

      guard let url: URL = buildURL(with: endpoint, using: queryParams) else {
        fputs("Error: Unable to build URL.", stderr)
        exit(1)
      }

      URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data: Data = data, error == nil else {
          fputs(".\nError: \(error?.localizedDescription ?? "Unknown error")", stderr)
          exit(1)
        }

        guard let json: [String: Any] = try? JSONSerialization
          .jsonObject(with: data) as? [String: Any] else {
          fputs(".\nError: Unable to parse JSON.", stderr)
          exit(1)
        }

        let viewCounts: [String: Int] = parseStatisticsJSON(json)

        let alfredItems: [String: [[String: Any]]] = createAlfredItems(
          from: items,
          with: viewCounts
        )

        do {
          let alfredFeedback: Data = try serializeJSON(alfredItems)
          print(String(data: alfredFeedback, encoding: .utf8)!)
          exit(0)
        } catch {
          fputs(".\nError: Unable to serialize JSON.", stderr)
          exit(1)
        }
      }.resume()
    }
  }
}

/// Main entry point of the script that sends a request to the YouTube API.
func main() {
  // Retrieve search query from command line arguments.
  let searchQuery: String = CommandLine.arguments[1]

  // Access API key, max results and sort criteria from environment variables.
  let apiKey: String = ProcessInfo.processInfo.environment["api_key"]!
  let maxResults: String = ProcessInfo.processInfo.environment["max_results"]!
  let order: String = ProcessInfo.processInfo.environment["order"]!

  // Define YouTube API endpoint and query parameters.
  let endpoint = "https://www.googleapis.com/youtube/v3/search"
  let queryParams: [String: String] = [
    "part": "snippet",
    "maxResults": maxResults,
    "order": order,
    "q": searchQuery,
    "type": "video",
    "key": apiKey,
  ]

  // Build the YouTube API request URL.
  guard let url: URL = buildURL(with: endpoint, using: queryParams) else {
    fputs("Error: Unable to build URL.", stderr)
    exit(1)
  }

  // Make an HTTP request to the YouTube API and process the response.
  let task: URLSessionDataTask = URLSession.shared.dataTask(
    with: url,
    completionHandler: handleResponse(apiKey: apiKey)
  )
  task.resume()

  // Keep the script running until all the asynchronous tasks are completed.
  RunLoop.main.run()
}

main()
