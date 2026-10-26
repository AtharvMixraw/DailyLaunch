import AppKit
import Carbon.HIToolbox

struct CapturedTab: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let url: String
}

@MainActor final class CaptureService: ObservableObject {
    static let capturedTabNotification = Notification.Name("DailyLaunchCapturedTab")
    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    func start() {
        var hotKeyID = EventHotKeyID(signature: OSType(0x444C4E43), id: 1) // DLNC
        RegisterEventHotKey(UInt32(kVK_ANSI_D), UInt32(optionKey | cmdKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, _ in
            guard let event else { return noErr }
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            Task { @MainActor in CaptureService.shared?.captureFrontmostTab() }
            return noErr
        }
        CaptureService.shared = self
        InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventSpec, nil, &handlerRef)
    }

    func stop() {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let handlerRef { RemoveEventHandler(handlerRef) }
        hotKeyRef = nil; handlerRef = nil
    }

    private func captureFrontmostTab() {
        let script = """
        tell application \"System Events\"
            set frontApp to name of first application process whose frontmost is true
        end tell
        if frontApp is \"Safari\" then
            tell application \"Safari\" to return {name of current tab of front window, URL of current tab of front window}
        else if frontApp is \"Google Chrome\" then
            tell application \"Google Chrome\" to return {title of active tab of front window, URL of active tab of front window}
        else
            return {\"\", \"\"}
        end if
        """
        var error: NSDictionary?
        guard let result = NSAppleScript(source: script)?.executeAndReturnError(&error), result.numberOfItems == 2,
              let title = result.atIndex(1)?.stringValue, let url = result.atIndex(2)?.stringValue,
              !url.isEmpty else { return }
        NSApp.activate(ignoringOtherApps: true)
        NotificationCenter.default.post(name: Self.capturedTabNotification, object: CapturedTab(title: title, url: url))
    }

    private static weak var shared: CaptureService?
}
