import SwiftUI

private enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All", active = "Active", done = "Completed"
    var id: String { rawValue }
}

struct TasksView: View {
    @EnvironmentObject private var store: AppStore
    var onNewTask: () -> Void
    @State private var query = ""
    @State private var filter: TaskFilter = .all
    @State private var editingTask: WorkspaceTask?

    private var shownTasks: [WorkspaceTask] {
        store.tasks.filter { task in
            let matchesText = query.isEmpty || task.title.localizedCaseInsensitiveContains(query) ||
                              task.notes.localizedCaseInsensitiveContains(query) ||
                              task.category.rawValue.localizedCaseInsensitiveContains(query)
            let matchesFilter: Bool
            switch filter {
            case .all: matchesFilter = true
            case .active: matchesFilter = !task.isCompleted
            case .done: matchesFilter = task.isCompleted
            }
            return matchesText && matchesFilter
        }.sorted {
            if $0.isCompleted != $1.isCompleted { return !$0.isCompleted }
            return ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .bottom) {
                    AuraHeading(eyebrow: "YOUR COMMAND CENTER", title: "My tasks", subtitle: "Organize the chaos. Own your day.")
                    Button(action: onNewTask) {
                        Image(systemName: "plus")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 47, height: 47)
                            .background(store.palette.color, in: RoundedRectangle(cornerRadius: 15))
                    }
                    .accessibilityLabel("Add a task")
                }

                GlassPanel {
                    HStack(spacing: 11) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.52))
                        TextField("Search tasks, notes, categories…", text: $query)
                            .font(.system(size: 14))
                            .tint(store.palette.color)
                            .autocorrectionDisabled()
                        if !query.isEmpty {
                            Button { query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.white.opacity(0.5)) }
                                .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(17)
                }

                HStack(spacing: 8) {
                    ForEach(TaskFilter.allCases) { option in
                        Button {
                            withAnimation(store.motionEnabled ? .easeInOut(duration: 0.2) : nil) { filter = option }
                        } label: {
                            Text(option.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(filter == option ? .black : .white.opacity(0.7))
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(filter == option ? store.palette.color : Color.white.opacity(0.08), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    Text("\(shownTasks.count) TASK\(shownTasks.count == 1 ? "" : "S")")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2).foregroundStyle(.white.opacity(0.54))
                    Spacer()
                    Text("Hold or use trash to delete")
                        .font(.system(size: 10)).foregroundStyle(.white.opacity(0.35))
                }

                if shownTasks.isEmpty {
                    GlassPanel {
                        VStack(spacing: 12) {
                            Image(systemName: query.isEmpty ? "tray" : "magnifyingglass")
                                .font(.system(size: 32)).foregroundStyle(store.palette.color)
                            Text(query.isEmpty ? "Nothing here yet" : "No matching tasks")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                            Text(query.isEmpty ? "Add a task to start creating momentum." : "Try a different search or filter.")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.53))
                                .multilineTextAlignment(.center)
                            if query.isEmpty && filter != .done {
                                Button("Create a task") { onNewTask() }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(store.palette.color)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 44)
                        .padding(.horizontal, 20)
                    }
                } else {
                    LazyVStack(spacing: 11) {
                        ForEach(shownTasks) { item in
                            HStack(spacing: 8) {
                                TaskListCard(item: item, onToggle: { withAnimation { store.toggleTask(item.id) } }, onOpen: { editingTask = item })
                                    .contextMenu {
                                        Button("Edit", systemImage: "pencil") { editingTask = item }
                                        Button("Delete", systemImage: "trash", role: .destructive) { store.deleteTask(item.id) }
                                    }
                                Button(role: .destructive) { store.deleteTask(item.id) } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.pink.opacity(0.8))
                                        .frame(width: 37, height: 37)
                                        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 11))
                                }
                                .accessibilityLabel("Delete \(item.title)")
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 30)
            .frame(maxWidth: 740)
            .frame(maxWidth: .infinity)
        }
        .sheet(item: $editingTask) { TaskEditorView(existingTask: $0) }
    }
}

struct TaskEditorView: View {
    var existingTask: WorkspaceTask? = nil
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var category: TaskCategory = .work
    @State private var priority: TaskPriority = .medium
    @State private var hasDueDate = true
    @State private var dueDate = Date()
    @State private var showDeleteConfirmation = false

    private var editing: Bool { existingTask != nil }

    var body: some View {
        ZStack {
            AuraBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 23) {
                    HStack {
                        AuraHeading(eyebrow: editing ? "REFINE YOUR PLAN" : "CAPTURE YOUR THOUGHT", title: editing ? "Edit task" : "New task")
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 37, height: 37)
                                .background(.white.opacity(0.09), in: Circle())
                        }
                        .accessibilityLabel("Close editor")
                    }

                    VStack(alignment: .leading, spacing: 9) {
                        fieldTitle("TASK NAME")
                        TextField("What do you want to accomplish?", text: $title, axis: .vertical)
                            .lineLimit(1...3)
                            .font(.system(size: 16))
                            .padding(17)
                            .background(.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 15))
                    }
                    VStack(alignment: .leading, spacing: 9) {
                        fieldTitle("NOTES")
                        TextField("Add details or reminders…", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(size: 14))
                            .padding(17)
                            .background(.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 15))
                    }

                    VStack(alignment: .leading, spacing: 11) {
                        fieldTitle("CATEGORY")
                        HStack(spacing: 9) {
                            ForEach(TaskCategory.allCases) { value in
                                Button { category = value } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: value.icon).font(.system(size: 17))
                                        Text(value.rawValue).font(.system(size: 11, weight: .semibold))
                                    }
                                    .foregroundStyle(category == value ? value.tint : .white.opacity(0.55))
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .background(category == value ? value.tint.opacity(0.16) : Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(category == value ? value.tint.opacity(0.6) : .white.opacity(0.07)))
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 11) {
                        fieldTitle("PRIORITY")
                        HStack(spacing: 9) {
                            ForEach(TaskPriority.allCases) { value in
                                Button { priority = value } label: {
                                    HStack(spacing: 6) {
                                        Circle().fill(value.tint).frame(width: 6, height: 6)
                                        Text(value.rawValue).font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundStyle(.white.opacity(priority == value ? 1 : 0.6))
                                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                                    .background(priority == value ? .white.opacity(0.15) : .white.opacity(0.055), in: RoundedRectangle(cornerRadius: 13))
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    GlassPanel(cornerRadius: 18) {
                        VStack(spacing: 9) {
                            Toggle(isOn: $hasDueDate) {
                                Label("Set a due date", systemImage: "calendar")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .tint(store.palette.color)
                            if hasDueDate {
                                DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .font(.system(size: 13))
                                    .tint(store.palette.color)
                            }
                        }
                        .padding(17)
                    }

                    GradientAction(title: editing ? "Save changes" : "Create task", icon: "checkmark", disabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) { save() }
                    if editing {
                        Button(role: .destructive) { showDeleteConfirmation = true } label: {
                            Label("Delete task", systemImage: "trash")
                                .frame(maxWidth: .infinity).font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.pink).padding(.vertical, 10)
                    }
                }
                .padding(22)
                .padding(.top, 13)
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .presentationDragIndicator(.visible)
        .onAppear { populate() }
        .confirmationDialog("Delete this task?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete task", role: .destructive) {
                if let existingTask { store.deleteTask(existingTask.id) }
                dismiss()
            }
        }
    }

    private func fieldTitle(_ text: String) -> some View {
        Text(text).font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(2).foregroundStyle(.white.opacity(0.53))
    }
    private func populate() {
        guard let item = existingTask else { return }
        title = item.title
        notes = item.notes
        category = item.category
        priority = item.priority
        hasDueDate = item.dueDate != nil
        dueDate = item.dueDate ?? Date()
    }
    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var item = existingTask ?? WorkspaceTask(title: trimmed)
        item.title = trimmed
        item.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        item.category = category
        item.priority = priority
        item.dueDate = hasDueDate ? dueDate : nil
        if editing { store.updateTask(item) } else { store.addTask(item) }
        dismiss()
    }
}
