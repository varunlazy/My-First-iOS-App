# Hands-on acceptance test

## Login
1. Launch on an iOS 17+ simulator.
2. Choose **Explore with a demo account** and verify the dashboard loads.
3. Go to Profile → Sign out. Log back in with `demo@aura.app` / `Demo@123`.
4. Try an incorrect password and verify an inline validation error appears.

## Local account creation + recovery
1. Sign out and switch to **Create account**.
2. Enter a name, unique email, and strong password of at least 8 characters with a letter and a digit.
3. Copy the one-time displayed recovery code to a safe location.
4. Sign out; use **Forgot password?** with the same email, recovery code and a new password.
5. Sign in with the new password. Note that **no email is sent**.

## Tasks + persistence
1. Add tasks from the Home new-task button and Tasks + button; fill category, priority, notes and due date.
2. Edit a task by tapping it.
3. Toggle complete; check the Home progress percentage and Insights chart.
4. Test task search, status filters and the trash/delete action.
5. Force-close and relaunch; tasks should persist for that account.

## Themes and comfort
1. In Profile, select a different palette and turn ambient motion off.
2. Relaunch; settings should stay selected.
3. Test small and large iPhone simulators; verify that buttons are readable and accessible.

## What is not tested here
Full Xcode compilation, simulator rendering and physical-device behavior require macOS + Xcode; this workspace does not provide Apple's build or simulator tools. Code and project format were checked with `swiftc -frontend -parse` and `plutil -lint`.
