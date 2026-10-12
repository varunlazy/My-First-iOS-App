import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: AppStore
    var onNewTask: () -> Void
    var onTasks: () -> Void
    var onProfile: () -> Void
    @State private var editingTask: WorkspaceTask?

    private var upcoming: [WorkspaceTask] {
        Array(store.tasks.filter { !$0.isCompleted }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }.prefix(3))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Circle().fill(.mint).frame(width: 7, height: 7)
                            Text("YOUR PERSONAL SPACE")
                                .tracking(2).font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Text("Hello, \(store.firstName) ✦")
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Text(Date.now.auraDay)
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.53))
                    }
                    Spacer(minLength: 12)
                    Button(action: onProfile) {
                        Text(String(store.firstName.prefix(1)).uppercased())
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(store.palette.color)
                            .frame(width: 49, height: 49)
                            .background(store.palette.color.opacity(0.15), in: Circle())
                            .overlay(Circle().strokeBorder(store.palette.color.opacity(0.33)))
                    }
                    .accessibilityLabel("Open profile")
                }

                spotlight

                HStack(spacing: 12) {
                    metric(label: "ACTIVE TASKS", value: "\(store.pendingCount)", icon: "bolt.fill", color: store.palette.color)
                    metric(label: "COMPLETED", value: "\(store.completedCount)", icon: "checkmark.seal.fill", color: .mint)
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("UP NEXT").font(.system(size: 10, weight: .bold, design: .rounded)).tracking(2.2).foregroundStyle(store.palette.color)
                            Text("Stay in your flow")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Button("See all") { onTasks() }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(store.palette.color)
                    }
                    if upcoming.isEmpty {
                        GlassPanel {
                            VStack(spacing: 9) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 29)).foregroundStyle(.mint)
                                Text("All caught up!").font(.system(size: 17, weight: .bold))
                                Text("Add a task whenever inspiration strikes.")
                                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.55))
                            }
                            .frame(maxWidth: .infinity).padding(24)
                        }
                    } else {
                        VStack(spacing: 11) {
                            ForEach(upcoming) { item in
                                TaskListCard(item: item, onToggle: { store.toggleTask(item.id) }, onOpen: { editingTask = item })
                            }
                        }
                    }
                }

                GlassPanel {
                    HStack(spacing: 16) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 27))
                            .foregroundStyle(store.palette.color)
                            .frame(width: 55, height: 55)
                            .background(store.palette.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 17))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Make room for your next idea").font(.system(size: 15, weight: .bold))
                            Text("Every big thing starts with one small step.")
                                .font(.system(size: 12)).foregroundStyle(.white.opacity(0.52))
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(19)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 28)
            .frame(maxWidth: 740)
            .frame(maxWidth: .infinity)
        }
        .sheet(item: $editingTask) { TaskEditorView(existingTask: $0) }
    }

    private var spotlight: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 29, style: .continuous)
                .fill(LinearGradient(colors: [store.palette.secondary.opacity(0.70), Color(red: 0.14, green: 0.16, blue: 0.36), Color(red: 0.075, green: 0.14, blue: 0.26)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().strokeBorder(.white.opacity(0.10), lineWidth: 1).frame(width: 240).offset(x: 220, y: -130)
            Circle().strokeBorder(.white.opacity(0.10), lineWidth: 1).frame(width: 170).offset(x: 255, y: -95)
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 12) {
                    Label("TODAY'S MOMENTUM", systemImage: "sparkles")
                        .font(.system(size: 10, weight: .bold, design: .rounded)).tracking(1.25)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Build your\nbest day.")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .lineSpacing(1)
                        .foregroundStyle(.white)
                    Text("\(store.completedCount) of \(store.tasks.count) tasks accomplished")
                        .font(.system(size: 12)).foregroundStyle(.white.opacity(0.72))
                    Button(action: onNewTask) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("New task")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.9))
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(.white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
                ZStack {
                    Circle().stroke(.white.opacity(0.14), lineWidth: 11)
                    Circle().trim(from: 0, to: store.completionRatio)
                        .stroke(AngularGradient(colors: [store.palette.color, .white, store.palette.color], center: .center), style: StrokeStyle(lineWidth: 11, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(store.motionEnabled ? .spring(response: 0.7, dampingFraction: 0.8) : nil, value: store.completionRatio)
                    VStack(spacing: 0) {
                        Text("\(Int(store.completionRatio * 100))%")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                        Text("DONE").font(.system(size: 9, weight: .bold)).tracking(1)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
                .frame(width: 84, height: 84)
                .padding(2)
            }
            .padding(23)
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 29, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 29).strokeBorder(.white.opacity(0.18)))
        .shadow(color: store.palette.secondary.opacity(0.16), radius: 30, y: 12)
    }

    private func metric(label: String, value: String, icon: String, color: Color) -> some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 15) {
                Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color)
                    .frame(width: 38, height: 38)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                Text(value).font(.system(size: 31, weight: .bold, design: .rounded))
                Text(label).font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.0).foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(18)
        }
    }
}

struct TaskListCard: View {
    let item: WorkspaceTask
    let onToggle: () -> Void
    let onOpen: () -> Void
    @EnvironmentObject private var store: AppStore

    var body: some View {
        GlassPanel(cornerRadius: 19) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(item.isCompleted ? .mint : store.palette.color)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isCompleted ? "Mark \(item.title) incomplete" : "Mark \(item.title) complete")

                Button(action: onOpen) {
                    VStack(alignment: .leading, spacing: 9) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(item.isCompleted ? .white.opacity(0.55) : .white)
                            .strikethrough(item.isCompleted)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 8) {
                            CategoryPill(category: item.category)
                            if let due = item.dueDate {
                                Label(due.formatted(.dateTime.month(.abbreviated).day()), systemImage: "calendar")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(.white.opacity(0.3))
            }
            .padding(16)
        }
    }
}
