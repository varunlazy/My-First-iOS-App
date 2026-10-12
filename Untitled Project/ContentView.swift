import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            AuraBackground()
            if store.sessionEmail == nil {
                LoginView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                WorkspaceView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: store.sessionEmail != nil)
    }
}

#Preview {
    ContentView().environmentObject(AppStore())
}
