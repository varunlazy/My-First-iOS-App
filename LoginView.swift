import SwiftUI

struct LoginView: View {
    private enum Mode: String { case signIn, signUp, recover }

    @EnvironmentObject private var store: AppStore
    @State private var mode: Mode = .signIn
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var recovery = ""
    @State private var busy = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false

    private var actionEnabled: Bool {
        switch mode {
        case .signIn: return !email.isEmpty && !password.isEmpty
        case .signUp: return !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirm.isEmpty
        case .recover: return !email.isEmpty && !recovery.isEmpty && !password.isEmpty
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 7) {
                    Image(systemName: "circle.hexagongrid.fill").foregroundStyle(store.palette.color)
                    Text("AURA").tracking(4).foregroundStyle(.white)
                    Spacer()
                    Text("WORKSPACE / 01")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1).foregroundStyle(.white.opacity(0.4))
                }
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .padding(.top, 15)

                AuraLogo(size: 118)
                    .padding(.top, 45)
                    .padding(.bottom, 27)

                VStack(spacing: 9) {
                    Text(mode == .signIn ? "Welcome back." : mode == .signUp ? "Begin something great." : "Recover your space.")
                        .font(.system(size: 33, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                    Text(mode == .signIn ? "Your ideas, your focus, your universe." :
                            mode == .signUp ? "Create a space that's entirely yours." :
                            "Use the recovery code saved at sign up.")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 28)

                GlassPanel(cornerRadius: 28) {
                    VStack(spacing: 19) {
                        if mode != .recover {
                            HStack(spacing: 4) {
                                modeButton("Sign in", mode: .signIn)
                                modeButton("Create account", mode: .signUp)
                            }
                            .padding(5)
                            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 15))
                        }

                        VStack(spacing: 17) {
                            if mode == .signUp {
                                AuraField(label: "Your name", icon: "person", placeholder: "Alex Morgan", text: $name)
                                    .textContentType(.name)
                            }
                            AuraField(label: "Email address", icon: "envelope", placeholder: "you@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                            if mode == .recover {
                                AuraField(label: "Recovery code", icon: "key.horizontal", placeholder: "8-digit recovery code", text: $recovery)
                                    .textInputAutocapitalization(.characters)
                            }
                            AuraField(label: mode == .recover ? "New password" : "Password", icon: "lock", placeholder: "At least 8 characters", text: $password, secure: true)
                            if mode == .signUp {
                                AuraField(label: "Confirm password", icon: "checkmark.shield", placeholder: "Repeat your password", text: $confirm, secure: true)
                            }
                        }

                        if mode == .signIn {
                            HStack {
                                Label("Private • On-device", systemImage: "lock.shield")
                                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.45))
                                Spacer()
                                Button("Forgot password?") { changeMode(.recover) }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(store.palette.color)
                            }
                        }

                        if let errorMessage {
                            Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.pink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityAddTraits(.updatesFrequently)
                        }
                        if let successMessage {
                            Label(successMessage, systemImage: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.mint)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        GradientAction(title: mode == .signIn ? "Enter workspace" : mode == .signUp ? "Create my workspace" : "Update password",
                                       icon: mode == .recover ? "key.fill" : "arrow.right", loading: busy,
                                       disabled: !actionEnabled, action: submit)

                        if mode == .recover {
                            Button { changeMode(.signIn) } label: {
                                Label("Back to sign in", systemImage: "arrow.left")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(22)
                }

                if mode == .signIn {
                    VStack(spacing: 12) {
                        HStack(spacing: 11) {
                            Rectangle().fill(.white.opacity(0.12)).frame(height: 1)
                            Text("OR TRY THE LIVE DEMO")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1.2).foregroundStyle(.white.opacity(0.45))
                                .fixedSize()
                            Rectangle().fill(.white.opacity(0.12)).frame(height: 1)
                        }
                        Button {
                            email = AppStore.demoEmail
                            password = AppStore.demoPassword
                            submit()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(store.palette.color)
                                Text("Explore with a demo account")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .foregroundStyle(.white)
                            .padding(18)
                            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 17))
                            .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(.white.opacity(0.10)))
                        }
                        .disabled(busy)
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 26)
                }

                Text("NATIVE SWIFTUI  •  PRIVATE OFFLINE EXPERIENCE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .padding(.top, 34)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
            .opacity(entered ? 1 : 0)
            .offset(y: entered ? 0 : 14)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            if reduceMotion || !store.motionEnabled { entered = true }
            else { withAnimation(.easeOut(duration: 0.65)) { entered = true } }
        }
    }

    private func modeButton(_ text: String, mode value: Mode) -> some View {
        Button { changeMode(value) } label: {
            Text(text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(mode == value ? .white : .white.opacity(0.48))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(mode == value ? .white.opacity(0.11) : .clear, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func changeMode(_ next: Mode) {
        errorMessage = nil
        successMessage = nil
        password = ""
        confirm = ""
        recovery = ""
        withAnimation(.easeInOut(duration: 0.25)) { mode = next }
    }

    private func submit() {
        guard !busy else { return }
        errorMessage = nil
        successMessage = nil
        if mode == .signUp && password != confirm {
            errorMessage = "The two passwords don't match."
            return
        }
        busy = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 380_000_000)
            defer { busy = false }
            switch mode {
            case .signIn:
                errorMessage = store.signIn(email: email, password: password)
            case .signUp:
                let result = store.createAccount(name: name, email: email, password: password)
                errorMessage = result.error
            case .recover:
                errorMessage = store.resetPassword(email: email, recovery: recovery, newPassword: password)
                if errorMessage == nil {
                    changeMode(.signIn)
                    successMessage = "Password updated. You can now sign in."
                }
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AppStore())
}
