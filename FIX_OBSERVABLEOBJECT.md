# Xcode build fix — ObservableObject

## Issue

`MyApp.swift:5:30 Type AppStore does not conform to protocol ObservableObject`

## Fix included in this updated project

`Untitled Project/AppStore.swift` now explicitly imports `Combine`, which provides
`ObservableObject` and the `@Published` property wrapper used by `AppStore`.

You do not need to change `MyApp.swift`, or to remove `@MainActor`.

## Testing

1. Quit Xcode if it is running.
2. Extract the ZIP into a fresh folder. Do not mix with the old project files.
3. Open `Untitled Project.xcodeproj` from the newly extracted folder.
4. Select an iPhone simulator as the run destination.
5. In Xcode, choose Product > Clean Build Folder (`Shift + Command + K`).
6. Build & Run (`Command + R`).
7. Sign in with demo@aura.app / Demo@123, or use the demo shortcut.

**Note:** Local Swift parsing and project structure checks passed, but an actual iOS
build requires Xcode on macOS and was not possible in the Linux environment.
If Xcode now displays another compiler diagnostic, copy the complete message.
