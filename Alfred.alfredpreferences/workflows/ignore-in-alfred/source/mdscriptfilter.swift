import Foundation

// Prepare query
let query = CommandLine.arguments[1]
let searchQuery = MDQueryCreate(kCFAllocatorDefault, query as CFString, nil, nil)

// Run query
MDQueryExecute(searchQuery, CFOptionFlags(kMDQuerySynchronous.rawValue))
let resultCount = MDQueryGetResultCount(searchQuery)

// No results
if resultCount == 0 {
  print(
    """
    {\"items\":[{\"title\":\"No Results\",
    \"subtitle\":\"No paths found with 'alfred:ignore' tag\",
    \"valid\":false}]}
    """
  )

  exit(0)
}

// Prepare items
let sfItems: [[String: Any]] = (0..<resultCount).compactMap { resultIndex in
  let rawPointer = MDQueryGetResultAtIndex(searchQuery, resultIndex)
  let resultItem = Unmanaged<MDItem>.fromOpaque(rawPointer!).takeUnretainedValue()

  guard let resultPath = MDItemCopyAttribute(resultItem, kMDItemPath) as? String else { return nil }

  return [
    "uid": resultPath,
    "type": "file",
    "title": URL(fileURLWithPath: resultPath).lastPathComponent,
    "subtitle": (resultPath as NSString).abbreviatingWithTildeInPath,
    "icon": ["path": resultPath, "type": "fileicon"],
    "arg": resultPath,
  ]
}

// Output JSON
let jsonData: Data = try! JSONSerialization.data(withJSONObject: ["items": sfItems])
let jsonString: String = String(data: jsonData, encoding: .utf8)!
print(jsonString)
