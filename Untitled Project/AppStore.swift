import Foundation
import SwiftUI
import Combine
import Security

// A genuinely working, offline-first demo. Accounts are device-local; there is no remote auth server.
enum AuraPalette: String, CaseIterable, Identifiable {
    case electric = "Electric"
    case orchid = "Orchid"
    case sunset = "Sunset"

    var id: String { rawValue }
    var color: Color {
        switch self {
        case .electric: return Color(red: 0.33, green: 0.85, blue: 0.98)
        case .orchid: return Color(red: 0.75, green: 0.51, blue: 1)
        case .sunset: return Color(red: 1, green: 0.61, blue: 0.45)
        }
    }
    var secondary: Color {
        switch self {
        case .electric: return Color(red: 0.49, green: 0.39, blue: 0.99)
        case .orchid: return Color(red: 0.34, green: 0.83, blue: 0.92)
        case .sunset: return Color(red: 0.99, green: 0.34, blue: 0.72)
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable, Identifiable {
    case work = "Work", personal = "Personal", ideas = "Ideas"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "heart.fill"
        case .ideas: return "lightbulb.fill"
        }
    }
    var tint: Color {
        switch self {
        case .work: return .cyan
        case .personal: return .pink
        case .ideas: return .orange
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable, Identifiable {
    case low = "Low", medium = "Medium", high = "High"
    var id: String { rawValue }
    var tint: Color {
        switch self {
        case .low: return .mint
        case .medium: return .orange
        case .high: return .pink
        }
    }
}

struct WorkspaceTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var notes: String = ""
    var category: TaskCategory = .work
    var priority: TaskPriority = .medium
    var dueDate: Date? = nil
    var createdAt: Date = .now
    var completedAt: Date? = nil

    var isCompleted: Bool { completedAt != nil }
}

private struct LocalAccount: Codable {
    var email: String
    var name: String
}

private enum SecureCredentials {
    static let service = "com.aura.workspace.local-demo"

    static func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult static func save(_ key: String, value: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        guard let data = value.data(using: .utf8) else { return false }
        let updates: [String: Any] = [kSecValueData as String: data]
        let update = SecItemUpdate(query as CFDictionary, updates as CFDictionary)
        if update == errSecSuccess { return true }
        guard update == errSecItemNotFound else { return false }
        var insert = query
        insert[kSecValueData as String] = data
        return SecItemAdd(insert as CFDictionary, nil) == errSecSuccess
    }
}

@MainActor
final class AppStore: ObservableObject {
    static let demoEmail = "demo@aura.app"
    static let demoPassword = "Demo@123"

    @Published private(set) var sessionEmail: String?
    @Published private(set) var tasks: [WorkspaceTask] = []
    @Published var recoveryCodeToShow: String?
    @Published var palette: AuraPalette {
        didSet { UserDefaults.standard.set(palette.rawValue, forKey: "aura.palette") }
    }
    @Published var motionEnabled: Bool {
        didSet { UserDefaults.standard.set(motionEnabled, forKey: "aura.motion") }
    }

    private var accounts: [LocalAccount] = []
    private let defaults = UserDefaults.standard

    init() {
        palette = AuraPalette(rawValue: UserDefaults.standard.string(forKey: "aura.palette") ?? "") ?? .electric
        motionEnabled = UserDefaults.standard.object(forKey: "aura.motion") as? Bool ?? true
        accounts = Self.loadAccounts()
        if let saved = UserDefaults.standard.string(forKey: "aura.session"),
           saved == Self.demoEmail || accounts.contains(where: { $0.email == saved }) {
            sessionEmail = saved
            tasks = Self.loadTasks(email: saved)
        }
    }

    var currentName: String {
        if sessionEmail == Self.demoEmail { return "Alex Morgan" }
        return accounts.first(where: { $0.email == sessionEmail })?.name ?? "Member"
    }
    var firstName: String { currentName.split(separator: " ").first.map(String.init) ?? "there" }
    var completedCount: Int { tasks.filter(\.isCompleted).count }
    var pendingCount: Int { tasks.count - completedCount }
    var completionRatio: Double { tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count) }
    var dueToday: [WorkspaceTask] {
        tasks.filter { !$0.isCompleted && $0.dueDate.map { Calendar.current.isDateInToday($0) } == true }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    static func isValidEmail(_ email: String) -> Bool {
        let email = normalizedEmail(email)
        let chunks = email.split(separator: "@", omittingEmptySubsequences: false)
        return chunks.count == 2 && !chunks[0].isEmpty && chunks[1].contains(".") && !email.contains(" ")
    }
    static func isStrongPassword(_ value: String) -> Bool {
        value.count >= 8 && value.rangeOfCharacter(from: .letters) != nil && value.rangeOfCharacter(from: .decimalDigits) != nil
    }

    @discardableResult func signIn(email: String, password: String) -> String? {
        let email = Self.normalizedEmail(email)
        guard Self.isValidEmail(email) else { return "Enter a valid email address." }
        if email == Self.demoEmail {
            guard password == Self.demoPassword else { return "Incorrect demo password. Try Demo@123." }
        } else {
            guard accounts.contains(where: { $0.email == email }),
                  SecureCredentials.read("password.\(email)") == password else {
                return "Email or password is incorrect."
            }
        }
        openSession(email: email)
        return nil
    }

    func createAccount(name: String, email: String, password: String) -> (error: String?, recovery: String?) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = Self.normalizedEmail(email)
        guard name.count >= 2 else { return ("Enter your name (at least 2 characters).", nil) }
        guard Self.isValidEmail(email) else { return ("Enter a valid email address.", nil) }
        guard Self.isStrongPassword(password) else { return ("Use 8+ characters with at least one letter and one number.", nil) }
        guard email != Self.demoEmail && !accounts.contains(where: { $0.email == email }) else {
            return ("That email already has an account on this device.", nil)
        }
        let token = String(format: "%08X", UInt32.random(in: 0...UInt32.max))
        guard SecureCredentials.save("password.\(email)", value: password),
              SecureCredentials.save("recovery.\(email)", value: token) else {
            return ("Unable to save account securely on this device.", nil)
        }
        accounts.append(LocalAccount(email: email, name: name))
        persistAccounts()
        openSession(email: email)
        recoveryCodeToShow = token
        return (nil, token)
    }

    @discardableResult func resetPassword(email: String, recovery: String, newPassword: String) -> String? {
        let email = Self.normalizedEmail(email)
        guard email != Self.demoEmail else { return "The demo account password cannot be changed." }
        guard accounts.contains(where: { $0.email == email }) else { return "No local account exists for that email." }
        let code = recovery.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty && code == SecureCredentials.read("recovery.\(email)") else {
            return "Recovery code is incorrect."
        }
        guard Self.isStrongPassword(newPassword) else { return "Password needs 8+ characters, a letter and a number." }
        return SecureCredentials.save("password.\(email)", value: newPassword) ? nil : "Could not update password."
    }

    func signOut() {
        sessionEmail = nil
        tasks = []
        defaults.removeObject(forKey: "aura.session")
    }

    private func openSession(email: String) {
        sessionEmail = email
        defaults.set(email, forKey: "aura.session")
        tasks = Self.loadTasks(email: email)
    }

    func addTask(_ item: WorkspaceTask) {
        tasks.insert(item, at: 0)
        persistTasks()
    }
    func updateTask(_ item: WorkspaceTask) {
        guard let index = tasks.firstIndex(where: { $0.id == item.id }) else { return }
        tasks[index] = item
        persistTasks()
    }
    func toggleTask(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].completedAt = tasks[index].isCompleted ? nil : .now
        persistTasks()
    }
    func deleteTask(_ id: UUID) {
        tasks.removeAll(where: { $0.id == id })
        persistTasks()
    }
    func resetWorkspace() {
        guard let email = sessionEmail else { return }
        tasks = Self.seedTasks()
        defaults.set(true, forKey: "aura.initialized.\(email)")
        persistTasks()
    }

    private func persistAccounts() {
        if let data = try? JSONEncoder().encode(accounts) { defaults.set(data, forKey: "aura.accounts") }
    }
    private static func loadAccounts() -> [LocalAccount] {
        guard let data = UserDefaults.standard.data(forKey: "aura.accounts") else { return [] }
        return (try? JSONDecoder().decode([LocalAccount].self, from: data)) ?? []
    }
    private static func loadTasks(email: String) -> [WorkspaceTask] {
        let defaults = UserDefaults.standard
        let key = "aura.tasks.\(email)"
        if let data = defaults.data(forKey: key), let decoded = try? JSONDecoder().decode([WorkspaceTask].self, from: data) {
            return decoded
        }
        // Seed exactly once; deleting the final task should remain an empty workspace.
        if defaults.bool(forKey: "aura.initialized.\(email)") { return [] }
        let seeded = seedTasks()
        if let data = try? JSONEncoder().encode(seeded) { defaults.set(data, forKey: key) }
        defaults.set(true, forKey: "aura.initialized.\(email)")
        return seeded
    }
    private func persistTasks() {
        guard let email = sessionEmail, let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: "aura.tasks.\(email)")
    }
    private static func seedTasks() -> [WorkspaceTask] {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        return [
            WorkspaceTask(title: "Design a beautiful new experience", notes: "Explore the premium glass interface and interactions.", category: .work, priority: .high, dueDate: today),
            WorkspaceTask(title: "Plan this week's priorities", notes: "Write down the three most important outcomes.", category: .personal, priority: .medium, dueDate: today),
            WorkspaceTask(title: "Capture a big idea", notes: "Great ideas deserve a space to grow.", category: .ideas, priority: .low, dueDate: tomorrow),
            WorkspaceTask(title: "Explore the dashboard", notes: "Welcome to your new workspace.", category: .work, priority: .low, dueDate: yesterday, createdAt: yesterday, completedAt: yesterday),
            WorkspaceTask(title: "Set up your workspace", notes: "Your progress is saved on this device.", category: .personal, priority: .medium, dueDate: yesterday, createdAt: yesterday, completedAt: yesterday)
        ]
    }
}
