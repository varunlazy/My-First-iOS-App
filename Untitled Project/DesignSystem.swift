import SwiftUI

struct AuraBackground: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.035, green: 0.043, blue: 0.085)
                RadialGradient(colors: [store.palette.secondary.opacity(0.17), .clear], center: .topLeading, startRadius: 0, endRadius: 430)
                Circle()
                    .fill(store.palette.color.opacity(0.22))
                    .frame(width: 350, height: 350)
                    .blur(radius: 110)
                    .position(x: floating ? geometry.size.width * 0.9 : geometry.size.width * 0.65,
                              y: floating ? 100 : 230)
                Circle()
                    .fill(store.palette.secondary.opacity(0.17))
                    .frame(width: 360, height: 360)
                    .blur(radius: 120)
                    .position(x: floating ? 40 : 120, y: geometry.size.height * 0.8)
            }
            .ignoresSafeArea()
            .onAppear { updateMotion() }
            .onChange(of: store.motionEnabled) { _, _ in updateMotion() }
            .onChange(of: reduceMotion) { _, _ in updateMotion() }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func updateMotion() {
        if store.motionEnabled && !reduceMotion {
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) { floating = true }
        } else {
            withAnimation(.none) { floating = false }
        }
    }
}

struct AuraLogo: View {
    var size: CGFloat = 90
    @EnvironmentObject private var store: AppStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotated = false

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [store.palette.color.opacity(0.20), store.palette.secondary.opacity(0.23)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size, height: size)
                .overlay(Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1))
                .shadow(color: store.palette.color.opacity(0.22), radius: 28)

            Circle()
                .trim(from: 0.07, to: 0.76)
                .stroke(LinearGradient(colors: [store.palette.color, store.palette.secondary, .clear], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: max(2, size * 0.026), lineCap: .round))
                .frame(width: size * 0.68, height: size * 0.68)
                .rotationEffect(.degrees(rotated ? 360 : 0))

            Image(systemName: "sparkle")
                .font(.system(size: size * 0.31, weight: .medium))
                .foregroundStyle(.white)
                .shadow(color: store.palette.color, radius: 14)
        }
        .onAppear { updateMotion() }
        .onChange(of: store.motionEnabled) { _, _ in updateMotion() }
        .onChange(of: reduceMotion) { _, _ in updateMotion() }
        .accessibilityLabel("Aura workspace logo")
    }

    private func updateMotion() {
        if store.motionEnabled && !reduceMotion {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) { rotated = true }
        } else {
            withAnimation(.none) { rotated = false }
        }
    }
}

struct GlassPanel<Content: View>: View {
    var cornerRadius: CGFloat = 24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(LinearGradient(colors: [.white.opacity(0.22), .white.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    }
            }
    }
}

struct GradientAction: View {
    let title: String
    var icon: String = "arrow.right"
    var loading: Bool = false
    var disabled: Bool = false
    let action: () -> Void
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                if loading { ProgressView().tint(.black) } else { Image(systemName: icon).font(.system(size: 16, weight: .bold)) }
                Text(loading ? "Please wait…" : title).font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(Color(red: 0.035, green: 0.043, blue: 0.085))
            .background(LinearGradient(colors: [store.palette.color, store.palette.secondary.opacity(0.96)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .shadow(color: store.palette.color.opacity(0.19), radius: 20, y: 8)
            .opacity(disabled ? 0.52 : 1)
        }
        .disabled(disabled || loading)
        .buttonStyle(.plain)
    }
}

struct AuraField: View {
    let label: String
    let icon: String
    var placeholder: String = ""
    @Binding var text: String
    var secure: Bool = false
    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.55))
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58)).frame(width: 20)
                Group {
                    if secure && !revealed {
                        SecureField(placeholder, text: $text)
                            .textContentType(.password)
                    } else {
                        TextField(placeholder, text: $text)
                            .textContentType(secure ? .password : .none)
                    }
                }
                .font(.system(size: 15))
                .tint(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                if secure {
                    Button { revealed.toggle() } label: {
                        Image(systemName: revealed ? "eye.slash" : "eye")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .accessibilityLabel(revealed ? "Hide password" : "Show password")
                }
            }
            .padding(.horizontal, 17)
            .frame(height: 56)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
        }
    }
}

struct AuraHeading: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(eyebrow.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(2.6).foregroundStyle(.white.opacity(0.52))
            Text(title).font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.8)
            if let subtitle { Text(subtitle).font(.system(size: 14)).foregroundStyle(.white.opacity(0.55)) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CategoryPill: View {
    let category: TaskCategory
    var body: some View {
        Label(category.rawValue, systemImage: category.icon)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(category.tint)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(category.tint.opacity(0.12), in: Capsule())
    }
}

extension Date {
    var auraDay: String { formatted(.dateTime.weekday(.wide).month(.abbreviated).day()) }
}
