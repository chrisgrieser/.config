#!/usr/bin/swift
//
//  Access.swift
//  File, Please Alfred Workflow
//  v1.0.0
//
//  Get the file path to the currently opened document, or
//  Get the path to the currently viewed Finder window.
//
//
//  Created by Patrick Sy on 09/04/2025.
//  <https://github.com/zeitlings/alfred-workflows>
//

import AppKit
import ApplicationServices
import Carbon.HIToolbox

// MARK: Access struct
struct Access {
    static var frontmost: NSRunningApplication? = NSWorkspace.shared.frontmostApplication
    static var frontmostWindowTitle: String?
    static var frontmostName: String?
    static var applicationReference: AXUIElement?

    static func activeDocument() -> (success: Success?, workaround: Workaround?) {

        // React to Finder requests early to preempt funny behavior when no proper Finder window is focused, but the desktop.
        if let focusedapp = Workflow.focusedapp, let workaround = Workaround(rawValue: focusedapp),
            .finder == workaround
        {
            return (nil, workaround)
        }

        guard let frontmost, let bundleIdentifier: String = frontmost.bundleIdentifier else {
            Workflow.log("Could not get frontmost application")
            Workflow.write(.failure, title: "Something went wrong", info: "could not get frontmost application")
        }

        Self.frontmostName = frontmost.localizedName
        let appRef: AXUIElement = AXUIElementCreateApplication(frontmost.processIdentifier)
        guard let window: AXUIElement = appRef.getAttribute(named: kAXFocusedWindowAttribute) else {
            Workflow.write(.failure, title: "Something went wrong", info: "could not get focused window of '\(frontmostName ?? "n/A")'")
        }

        Self.applicationReference = appRef
        frontmostWindowTitle = window.getAttribute(named: kAXTitleAttribute)
        Workflow.log("Retrieving from '\(frontmostName ?? "n/A")' for window '\(frontmostWindowTitle ?? "n/A")'...")
        guard let document: String = window.getAttribute(named: kAXDocumentAttribute) else {
            return (nil, Workaround(bundleId: bundleIdentifier))
        }

        return ( Success(filePath: document), nil )
    }

    static func permitted() -> (UInt8?, `continue`: Bool) {
        let trustPrompt: NSString =  kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options: CFDictionary = [trustPrompt: true] as CFDictionary
  		let granted: Bool = AXIsProcessTrustedWithOptions(options)
  		if !granted { Workflow.log("Accessibility permissions are not enabled. Prompting for permissions...") }
        return (nil, continue: granted)
    }

    static func cleanup() {
        Workflow.log("Cleaning up...")
        Access.applicationReference = nil
        Access.frontmost = nil
    }
}

extension Access {
    // MARK: - Success struct
    struct Success {
        @Env(key: .fileOrFolderKey, is: "file") private static var expectingFile: Bool
        @Env(key: .openStrategyKey, is: "browser") static var expectingBrowser: Bool
        @Env(key: .openStrategyKey, is: "terminal") static var expectingTerminal: Bool
        private static let shouldTruncateTail: Bool = (expectingBrowser && !expectingFile) || expectingTerminal

        let file: URL

        init?(filePath: String, fm: FileManager = .default) {
            guard !filePath.isEmpty else { return nil }
            Workflow.log("⟩ Raw path:  '\(filePath.maskingUser())'")
            var processedPath: String = filePath
                .replacing("file://", with: "")
            processedPath = processedPath.removingPercentEncoding ?? processedPath
            Workflow.log("⟩ Processed: '\(processedPath.maskingUser())'")

            guard fm.fileExists(atPath: processedPath), let url: URL = .init(string: processedPath) else {
                Workflow.log("Not a file path: \(processedPath)")
                Workflow.write(.failure, title: "Not a file path (\(Access.frontmostName ?? "n/A"))", info: "\(processedPath)")
                return nil
            }
            self.file = url
        }

        func finalize(fm: FileManager = .default) /*-> Never?*/ {
            if Self.shouldTruncateTail {
                let folder: URL = fm.isDirectory(at: file) // case: finder workaround
                    ? file : file.deletingLastPathComponent()
                if Self.expectingTerminal {
                    let fileName: String = file.lastPathComponent.replacing("\"", with: "\\\"")
                    Workflow.log("Writing: folder.escapedPath")
                    Workflow.write(folder.escapedPath, variables: [
                        "filename": fileName,
                        "fullpath": file.escapedPath.replacing("\"", with: "\\\"")
                    ])
                }
                Workflow.log("Writing: folder.folder")
                Workflow.write(folder.path(percentEncoded: false))
            }
            Workflow.log("Writing: file.path")
            Workflow.write(file.path(percentEncoded: false))
        }
    }
}

extension Access {
    // MARK: Workaround enum
    enum Workaround: String {
        case zed = "dev.zed.Zed"
        case finder = "com.apple.finder"

        init(bundleId: String ) {
            Workflow.log("Trying Workaround for bundle identifier: \(bundleId)")
            guard let workaround = Workaround(rawValue: bundleId) else {
                Workflow.write(.failure, title: "\(Access.frontmostName ?? "n/A"): \(Access.frontmostWindowTitle ?? "n/A")", info: "no file or workaround available")
            }
            self = workaround
        }

        func handle() {

            let path: String
            switch self {
            case .zed: // For Zed editor: ⌘K P
                let originalClipboard: Optional<String> = NSPasteboard.general.string(forType: .string)
                NSPasteboard.general.clearContents()

                KeyboardEmulator.press(key: .k, with: [.maskCommand], wait: 0.1)
                KeyboardEmulator.press(key: .p, wait: 0.2)

                // Get the path from clipboard
                path = NSPasteboard.general.string(forType: .string) ?? ""

                if let originalClipboard {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(originalClipboard, forType: .string)
                }
            case .finder:
                path = getFinderLocation()
            }

            guard let success = Access.Success(filePath: path) else {
                Workflow.log("Unsuccessful with path: '\(path)'")
                Workflow.write(.failure,  title: "Workaround failed", info: "no file from '\(Access.frontmostName ?? "n/A")' for window '\(Access.frontmostWindowTitle ?? "n/A")'")
            }
            success.finalize()
        }
    }
}

extension Access.Workaround {
    // MARK: - KeyboardEmulator struct
    struct KeyboardEmulator {
        enum KeyCode: Int {
            case k, p
            var rawValue: Int {
                switch self {
                case .k: return kVK_ANSI_K
                case .p: return kVK_ANSI_P
                }
            }
        }

        private enum Finger {
            case up, down
            var keyDown: Bool {
                switch self {
                case .up: return false
                case .down: return true
                }
            }
        }

        static func press(key: KeyCode, with flags: CGEventFlags? = nil, wait timeInterval: TimeInterval? = nil) {
            let keyDownEvent: CGEvent? = event(for: key, with: flags, .down)
            let keyUpEvent: CGEvent? = event(for: key, .up)
            keyDownEvent?.post(tap: .cghidEventTap)
            keyUpEvent?.post(tap: .cghidEventTap)
            if let timeInterval {
                Thread.sleep(forTimeInterval: timeInterval)
            }
        }

        static private func event(for key: KeyCode, with flags: CGEventFlags? = nil,  _ finger: Finger) -> CGEvent? {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(key.rawValue), keyDown: finger.keyDown)
            if let flags { event?.flags = flags }
            return event
        }
    }
}

extension Access.Workaround {
    private func getFinderLocation(fm: FileManager = .default) -> String {

        let finderApp = NSAppleScript(source: """
            tell application "Finder"
                if (count of windows) > 0 then
                    return POSIX path of (target of front window as alias)
                else
                    return POSIX path of (desktop as alias)
                end if
            end tell
            """)

        var error: NSDictionary?
        if let result = finderApp?.executeAndReturnError(&error).stringValue {
            Workflow.log("Got Finder path...")
            return result
        } else if let error = error {
            Workflow.log("Error getting Finder path: \(error)")
        }

        return fm.homeDirectoryForCurrentUser.appending(component: "Desktop").path(percentEncoded: false)
    }
}


struct Workflow {
    @Env(key: .debugKey) private static var debug: Bool
    @Env(key: .focusedappKey) static var focusedapp: String?
    private static let formatter: DateFormatter = .timestampFormatter
    private static let stamp: () -> (String) = {
        formatter.string(from: .now)
    }

    private struct Continuation: Encodable {
        let alfredworkflow: AlfredWorkflow
        init(arg: String, vars: [String:String]) {
            self.alfredworkflow = .init(arg: arg, variables: vars)
        }
        struct AlfredWorkflow: Encodable {
            let arg: String
            let variables: [String:String]
        }
        func encoded() -> Data { try! JSONEncoder().encode(self) }
    }

    static func log(_ message: @autoclosure () -> String, label: String = " [Access]", stdErr: FileHandle = .standardError) {
        if debug { stdErr.write(Data("[\(stamp())]\(label) \(message())\n".utf8)) }
    }

    static func write(_ output: String, variables: [String:String]? = nil, stdOut: FileHandle = .standardOutput) -> Never {
        if let variables {
            let continuation: Continuation = .init(arg: output, vars: variables)
            Access.cleanup()
            stdOut.write(continuation.encoded())
            exit(0)
        }
        Access.cleanup()
        stdOut.write(Data(output.utf8))
        exit(0)
    }

    static func write(_ output: String, title: String, info: String) -> Never {
        write(output, variables: ["title": title, "info": info])
    }

    @discardableResult
    static func validate() -> Never? {
        if let focusedapp, let workaround = Access.Workaround(rawValue: focusedapp),
            .finder == workaround
        {
            guard Access.Success.expectingBrowser || Access.Success.expectingTerminal else {
                write(.failure, title: "Incompatible Strategy", info: "Press ⌘↑ instead")
            }
        }
        return nil
    }
}


// MARK: Env wrapper struct
@propertyWrapper
struct Env<T> {
	let key: EnvironmentKey
	let defaultValue: T
	let transform: (String) -> T?

    enum EnvironmentKey: String {
        case debugKey = "alfred_debug"
        case focusedappKey = "focusedapp"
        case openStrategyKey = "open_in"
        case fileOrFolderKey = "browser_file_or_folder"
    }

    var wrappedValue: T {
		guard let value = ProcessInfo.processInfo.environment[key.rawValue] else {
			return defaultValue
		}
		return transform(value) ?? defaultValue
	}

	init(key: EnvironmentKey, default: T, transform: @escaping (String) -> T?) {
		self.key = key
		self.defaultValue = `default`
		self.transform = transform
	}
}

// MARK: - Extensions
extension Env where T == Bool {
	init(key: EnvironmentKey, default: Bool = false, is value: String = "1") {
		self.init(key: key, default: `default`) { $0 == value }
	}
}

extension Env where T == String? {
	init(key: EnvironmentKey) {
		self.init(key: key, default: nil) { $0 }
	}
}

extension DateFormatter {
    static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

extension FileManager {
    func isDirectory(at url: URL) -> Bool {
  		var isDirectoryObjC: ObjCBool = false
  		return fileExists(atPath: url.path, isDirectory: &isDirectoryObjC) && isDirectoryObjC.boolValue
   	}
}

extension String {
    static let failure: String = "failure"
    func maskingUser(fm: FileManager = .default) -> String {
        let home: String = fm.homeDirectoryForCurrentUser.path(percentEncoded: false)
        return self.replacing(home, with: "/Users/masked/")
    }
}

extension URL {
    var escapedPath: String {
        self.path(percentEncoded: false).replacing(" ", with: "\\ ")
    }
}

extension AXUIElement {
    var name: String? { getAttribute(named: kAXTitleAttribute) }

    func getAttribute<T>(named axAttributeName: String) -> T? {
    	var value: CFTypeRef?
    	let state: AXError = AXUIElementCopyAttributeValue(self, axAttributeName as CFString, &value)
    	guard state == .success else {
            Workflow.log("Could not get attribute with name '\(axAttributeName)' from AXUIElement named '\(name ?? "n/A")'")
    		return nil
    	}
    	return value as? T
    }
}

// MARK: - Main

Workflow.validate()

if Access.permitted().continue {
    let given = Access.activeDocument()

    given.workaround.map({ $0.handle() })
    given.success.map({ $0.finalize() })

    Workflow.write(.failure, title: "Something went wrong...", info: "no success or workaround")
}
