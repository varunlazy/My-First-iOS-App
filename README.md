# Aura Workspace — Native SwiftUI Demo

A polished offline-first iOS example rebuilt from your original `Untitled Project` Xcode starter.

<img src="WhatsApp Image 2026-10-13 at 03.53.04.jpeg" width="500" alt="Dashboard">

## Get started (Mac required)

1. Unzip this folder on your Mac.
2. Open **`Untitled Project.xcodeproj`** in **Xcode 26.x** (matching the newer project format used in the uploaded ZIP).
3. Select the **Untitled Project** scheme and an **iPhone Simulator** (iOS 17 or later).
4. Press **⌘R** to build and launch.
5. On the welcome screen select **Explore with a demo account**, or sign in manually with:
   - Email: `demo@aura.app`
   - Password: `Demo@123`
6. To try account creation, choose **Create account**. Save the recovery code displayed after sign-up.

## What works

- Persistent device-local sign in, account creation, sign out and recovery-code password reset.
- Password and recovery secrets kept in **iOS Keychain**. This is not a remote identity system.
- A sample workspace with task completion metrics, personalized welcome and progress ring.
- Task creation, editing, completion, deletion, search, filtering, due dates, priority and categories.
- Seven-day completion chart and category totals calculated from saved tasks.
- Three live accent palettes and a motion toggle; state persists between launches.
- Responsive layouts, dark glass panels, soft orbital motion, animated screen transitions.
- Device-local task persistence per account via UserDefaults; each account has separate tasks.

## Test checklist

- [ ] Launch app and use demo sign in.
- [ ] Check seeded tasks and change one to completed; observe dashboard and Insights changes.
- [ ] Add a task, edit it, search for it, delete it; relaunch and confirm saved state.
- [ ] Switch between All / Active / Completed tasks.
- [ ] Create a new local account, **copy and save the recovery code**, sign out, then sign back in.
- [ ] Test recovery by entering email, recovery code and a new strong password.
- [ ] Switch accent colors and animations in Profile; relaunch to verify settings persist.
- [ ] Test different screen sizes (iPhone SE-like compact and iPhone Pro Max) and Dynamic Type.

## Important boundaries

- **No backend or online signup** is included because the uploaded starter project supplied no server, API or production authentication credentials.
- Forgot-password recovery uses the code saved during sign-up; **no real recovery emails** are sent.
- The demo login is intentionally public for testing, and must not be used for real user accounts.
- No push notifications, cloud synchronization or server-side security are implemented.
- Passwords are stored via Keychain; task records are stored locally in UserDefaults (not encrypted separately).
- Xcode / Apple simulator cannot run in this Linux build environment, so this package has syntax and file-structure checks but **has not been verified by a real Xcode build or iOS simulator run**.

## Xcode troubleshoot

- Choose **Signing & Capabilities → Team** (your personal team) for physical iPhone testing.
- If your machine reports an unavailable bundle ID, replace `com.example.auraworkspace` under **Signing & Capabilities** with your own unique ID.
- If your simulator is older than iOS 17, update the simulator runtime in **Xcode → Settings → Platforms**.
- Files inside `Untitled Project/` are picked up automatically by the Xcode project's synchronized folder group.

## Source layout

- `LoginView.swift` — animated welcome, login, signup, code recovery.
- `Untitled Project/MyApp.swift` — app entry point.
- `Untitled Project/ContentView.swift` — authenticated router.
- `Untitled Project/AppStore.swift` — local account credentials, state and persistence.
- `Untitled Project/DesignSystem.swift` — glass visuals, buttons, reusable UI and animation.
- `Untitled Project/WorkspaceView.swift` — tab navigation and recovery sheet.
- `Untitled Project/DashboardView.swift` — animated landing and progress.
- `Untitled Project/TasksView.swift` — working task management.
- `Untitled Project/InsightsView.swift` — live statistics and activity chart.
- `Untitled Project/ProfileView.swift` — settings, reset and logout.

This is a functional, test-oriented **native iOS prototype**, not a production authentication service.
# My-First-iOS-App
