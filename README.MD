# DailyLaunch

**A focused macOS workspace for turning tomorrow’s intentions into today’s actions.**

DailyLaunch is a private, native Mac utility for planning daily work, attaching the exact pages you intend to use, and opening those pages without friction.

## What it does

- Separate plans for each calendar date.
- Today dashboard with completion and progress.
- One-click task launch and “Open All” browser launch.
- Tomorrow planning without modifying today’s work.
- Local macOS reminders for tomorrow’s plan.
- Global `⌘⌥D` capture shortcut for Safari and Chrome tabs.
- Local JSON persistence with atomic writes.
- No backend, account, analytics, subscription, or third-party service.

## Install the release build

```sh
xcodebuild -project DailyLaunch.xcodeproj -scheme DailyLaunch \
  -configuration Release -derivedDataPath /tmp/DailyLaunchRelease build
rm -rf /Applications/DailyLaunch.app
cp -R /tmp/DailyLaunchRelease/Build/Products/Release/DailyLaunch.app /Applications/DailyLaunch.app
open /Applications/DailyLaunch.app
```

The installed product is a normal macOS application and does not require Xcode to remain open.

## Development

```sh
open DailyLaunch.xcodeproj
xcodebuild -project DailyLaunch.xcodeproj -scheme DailyLaunch \
  -configuration Debug -derivedDataPath /tmp/DailyLaunchDebug build
```

The project targets macOS 13 or newer.

## Save the active browser tab

With DailyLaunch running, press **⌘⌥D** from Safari or Google Chrome. DailyLaunch reads the frontmost tab’s title and URL, activates its save window, and pre-fills the task for tomorrow. Review the title, optionally add a description, then click **Save**.

The first capture may prompt for macOS permissions. Allow DailyLaunch to control **System Events**, **Safari**, and/or **Google Chrome** in **System Settings → Privacy & Security → Automation**. The shortcut is registered while the app is running; V1 does not install a background login agent.

## Release management

DailyLaunch follows Semantic Versioning (`MAJOR.MINOR.PATCH`). The current release is **v1.0.0**.

```sh
git add .
git commit -m "Release v1.0.0"
git tag -a v1.0.0 -m "DailyLaunch v1.0.0"
```

For future releases, update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the Xcode project, update this README, then create the matching annotated tag.

## Architecture

| Area | Responsibility |
| --- | --- |
| `Models.swift` | Date-keyed plans, action items, URL validation |
| `DailyStore.swift` | Local persistence and plan mutation |
| `NotificationService.swift` | Permission, scheduling, cancellation, URL opening |
| `ContentView.swift` | Today dashboard |
| `PlannerView.swift` | Tomorrow planning and task editing |
| `SettingsView.swift` | Notification status and product information |

## Data and privacy

Plans are stored locally at `~/Library/Application Support/DailyLaunch/plans.json`. No task data leaves the Mac.

## Known macOS boundaries

- Notifications require permission in System Settings.
- macOS cannot execute app code while powered off; missed reminders require a later app launch.
- V1 does not install a privileged launch agent or configure launch-at-login automatically.
- Distribution outside the local Mac requires signing and notarization configuration.
