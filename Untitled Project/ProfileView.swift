import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @State private var confirmReset = false
    @State private var confirmSignOut = false
    @State private var copiedEmail = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 23) {
                AuraHeading(eyebrow: "MAKE IT YOURS", title: "Your space", subtitle: "A few details. A world of possibilities.")

                GlassPanel(cornerRadius: 25) {
                    HStack(spacing: 15) {
                        Text(String(store.firstName.prefix(1)).uppercased())
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(store.palette.color)
                            .frame(width: 66, height: 66)
                            .background(store.palette.color.opacity(0.17), in: RoundedRectangle(cornerRadius: 19))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(store.currentName).font(.system(size: 21, weight: .bold, design: .rounded))
                            Text(store.sessionEmail ?? "").font(.system(size: 12)).foregroundStyle(.white.opacity(0.54))
                                .lineLimit(1).minimumScaleFactor(0.75)
                            Label("LOCAL ACCOUNT", systemImage: "lock.shield.fill")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .tracking(1.2).foregroundStyle(.mint)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(20)
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel("PERSONALIZE")
                    GlassPanel {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Label("Accent color", systemImage: "paintpalette")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text(store.palette.rawValue)
                                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                            }
                            HStack(spacing: 14) {
                                ForEach(AuraPalette.allCases) { choice in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.28)) { store.palette = choice }
                                    } label: {
                                        Circle()
                                            .fill(LinearGradient(colors: [choice.color, choice.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 43, height: 43)
                                            .overlay {
                                                if store.palette == choice {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 15, weight: .heavy)).foregroundStyle(.black)
                                                }
                                            }
                                            .overlay(Circle().strokeBorder(.white.opacity(store.palette == choice ? 0.85 : 0.05), lineWidth: 2))
                                    }
                                    .accessibilityLabel("Select \(choice.rawValue) color")
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                            Divider().overlay(.white.opacity(0.08))
                            Toggle(isOn: $store.motionEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ambient animations").font(.system(size: 14, weight: .semibold))
                                    Text("Floating glow, transitions and motion")
                                        .font(.system(size: 12)).foregroundStyle(.white.opacity(0.5))
                                }
                            }
                            .tint(store.palette.color)
                        }
                        .padding(19)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionLabel("ACCOUNT & DATA")
                    GlassPanel {
                        VStack(spacing: 0) {
                            Button {
                                UIPasteboard.general.string = store.sessionEmail
                                copiedEmail = true
                            } label: {
                                settingRow(icon: copiedEmail ? "checkmark" : "doc.on.doc", title: copiedEmail ? "Email copied" : "Copy account email", color: store.palette.color)
                            }
                            Divider().overlay(.white.opacity(0.08))
                            Button { confirmReset = true } label: {
                                settingRow(icon: "arrow.counterclockwise", title: "Restore sample tasks", color: .orange)
                            }
                            Divider().overlay(.white.opacity(0.08))
                            Button { confirmSignOut = true } label: {
                                settingRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign out", color: .pink)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Your data stays on this device", systemImage: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Aura is an offline demonstration. Local account passwords and recovery codes are stored in iOS Keychain; task data is stored locally. No cloud sync, email delivery or server authentication is connected.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.50))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(store.palette.color.opacity(0.075), in: RoundedRectangle(cornerRadius: 18))

                Text("AURA WORKSPACE  •  VERSION 1.0 DEMO")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.5).foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 5)
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 30)
            .frame(maxWidth: 740)
            .frame(maxWidth: .infinity)
        }
        .confirmationDialog("Restore demo tasks?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Replace my tasks", role: .destructive) { store.resetWorkspace() }
        } message: {
            Text("This replaces all tasks in the current account with sample tasks. This can't be undone.")
        }
        .confirmationDialog("Sign out of Aura?", isPresented: $confirmSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { store.signOut() }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(2).foregroundStyle(.white.opacity(0.53))
    }

    private func settingRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 15))
                .foregroundStyle(color)
                .frame(width: 37, height: 37)
                .background(color.opacity(0.13), in: RoundedRectangle(cornerRadius: 11))
            Text(title).font(.system(size: 14, weight: .medium)).foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(minHeight: 61)
        .contentShape(Rectangle())
    }
}
