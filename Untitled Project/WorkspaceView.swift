import SwiftUI
import UIKit

private enum WorkspaceTab: String, CaseIterable, Identifiable {
    case home = "Home", tasks = "Tasks", insights = "Insights", profile = "Profile"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .home: return "square.grid.2x2.fill"
        case .tasks: return "checklist"
        case .insights: return "chart.bar.xaxis"
        case .profile: return "person.crop.circle"
        }
    }
}

struct WorkspaceView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab: WorkspaceTab = .home
    @State private var addTask = false

    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .home: DashboardView(onNewTask: { addTask = true }, onTasks: { select(.tasks) }, onProfile: { select(.profile) })
                case .tasks: TasksView(onNewTask: { addTask = true })
                case .insights: InsightsView()
                case .profile: ProfileView()
                }
            }
            .id(selectedTab)
            .transition(.opacity.combined(with: .offset(y: 9)))
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(WorkspaceTab.allCases) { tab in
                    Button { select(tab) } label: {
                        VStack(spacing: 5) {
                            Image(systemName: tab.symbol)
                                .font(.system(size: 19, weight: selectedTab == tab ? .bold : .medium))
                                .symbolEffect(.bounce, value: selectedTab == tab)
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium, design: .rounded))
                        }
                        .foregroundStyle(selectedTab == tab ? store.palette.color : .white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .frame(height: 59)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 9)
            .padding(.bottom, 6)
            .background {
                UnevenRoundedRectangle(topLeadingRadius: 23, topTrailingRadius: 23)
                    .fill(.ultraThinMaterial)
                    .overlay(alignment: .top) { Rectangle().fill(.white.opacity(0.10)).frame(height: 1) }
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $addTask) { TaskEditorView() }
        .sheet(isPresented: Binding(get: { store.recoveryCodeToShow != nil },
                                    set: { if !$0 { store.recoveryCodeToShow = nil } })) {
            if let code = store.recoveryCodeToShow {
                RecoveryCodeView(code: code)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func select(_ tab: WorkspaceTab) {
        if store.motionEnabled {
            withAnimation(.easeInOut(duration: 0.22)) { selectedTab = tab }
        } else { selectedTab = tab }
    }
}

private struct RecoveryCodeView: View {
    let code: String
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        ZStack {
            AuraBackground()
            VStack(spacing: 19) {
                Image(systemName: "key.fill")
                    .font(.system(size: 34)).foregroundStyle(store.palette.color)
                Text("Save your recovery code")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("This is your only way to reset a local account password. Store it somewhere safe. It won't be emailed.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.66))
                Text(code)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .tracking(5)
                    .textSelection(.enabled)
                    .padding(19)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 16))
                GradientAction(title: copied ? "Copied" : "Copy recovery code", icon: copied ? "checkmark" : "doc.on.doc") {
                    UIPasteboard.general.string = code
                    copied = true
                }
                Button("I've saved my code") { dismiss() }
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(.white.opacity(0.75))
            }
            .padding(28)
        }
    }
}
