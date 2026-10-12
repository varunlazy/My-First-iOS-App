import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var store: AppStore

    private var week: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        return (-6...0).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: Date()) ?? Date()
            let count = store.tasks.filter { $0.completedAt.map { calendar.isDate($0, inSameDayAs: day) } == true }.count
            return (date: day, count: count)
        }
    }

    private var categoryCounts: [(TaskCategory, Int)] {
        TaskCategory.allCases.map { category in
            (category, store.tasks.filter { $0.category == category }.count)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                AuraHeading(eyebrow: "LOOK HOW FAR YOU'VE COME", title: "Your insights", subtitle: "Small steps turn into extraordinary progress.")

                GlassPanel(cornerRadius: 27) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 7) {
                                Text("OVERALL COMPLETION")
                                    .font(.system(size: 10, weight: .bold, design: .rounded)).tracking(2)
                                    .foregroundStyle(.white.opacity(0.56))
                                Text("\(Int(store.completionRatio * 100))%")
                                    .font(.system(size: 53, weight: .bold, design: .rounded))
                                    .foregroundStyle(store.palette.color)
                                Text("of all your tasks are done")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.56))
                            }
                            Spacer()
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 44)).foregroundStyle(store.palette.color.opacity(0.8))
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.1))
                                Capsule().fill(LinearGradient(colors: [store.palette.color, store.palette.secondary], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: max(0, proxy.size.width * store.completionRatio))
                            }
                        }
                        .frame(height: 11)
                        HStack {
                            Label("\(store.completedCount) finished", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.mint)
                            Spacer()
                            Text("\(store.pendingCount) remaining")
                                .foregroundStyle(.white.opacity(0.59))
                        }
                        .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(22)
                }

                GlassPanel(cornerRadius: 27) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ACTIVITY PULSE")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .tracking(2.1).foregroundStyle(store.palette.color)
                                Text("Last seven days")
                                    .font(.system(size: 21, weight: .bold, design: .rounded))
                            }
                            Spacer()
                            Text("\(week.reduce(0) { $0 + $1.count }) DONE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .tracking(1)
                                .foregroundStyle(.white.opacity(0.57))
                        }
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(week.indices, id: \.self) { index in
                                let day = week[index]
                                let maxCount = max(1, week.map(\.count).max() ?? 1)
                                VStack(spacing: 11) {
                                    Text(day.count > 0 ? "\(day.count)" : "")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(store.palette.color)
                                        .frame(height: 13)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(day.count > 0 ? store.palette.color : .white.opacity(0.085))
                                        .frame(height: max(11, CGFloat(day.count) / CGFloat(maxCount) * 112))
                                        .frame(maxHeight: 112, alignment: .bottom)
                                    Text(day.date.formatted(.dateTime.weekday(.narrow)))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.56))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 149, alignment: .bottom)
                        Text("Bars show tasks completed each day on this device.")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.43))
                    }
                    .padding(22)
                }

                VStack(alignment: .leading, spacing: 13) {
                    Text("YOUR FOCUS AREAS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(2).foregroundStyle(.white.opacity(0.53))
                    ForEach(categoryCounts, id: \.0) { category, count in
                        GlassPanel(cornerRadius: 17) {
                            HStack(spacing: 13) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 17))
                                    .foregroundStyle(category.tint)
                                    .frame(width: 39, height: 39)
                                    .background(category.tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 12))
                                Text(category.rawValue).font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("\(count) tasks")
                                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.56))
                            }
                            .padding(15)
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 32)
            .frame(maxWidth: 740)
            .frame(maxWidth: .infinity)
        }
    }
}
