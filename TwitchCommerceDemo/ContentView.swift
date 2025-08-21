import SwiftUI

struct Contribution: Identifiable, Codable {
    let id: UUID
    let user: String
    let type: String   // "Sub", "Gift", "Bits"
    let amount: Int
    let message: String?
    let timestamp: Date

    init(user: String, type: String, amount: Int, message: String? = nil) {
        self.id = UUID()
        self.user = user
        self.type = type
        self.amount = amount
        self.message = message
        self.timestamp = Date()
    }
}

@MainActor
final class CommerceViewModel: ObservableObject {
    @Published var contributions: [Contribution] = []
    @Published var goal: Int = 100
    @Published var current: Int = 0

    init() {
        seedDemoData()
    }

    func seedDemoData() {
        let seed: [Contribution] = [
            .init(user: "arin", type: "Sub",  amount: 1,  message: "Let’s go!"),
            .init(user: "bri",  type: "Gift", amount: 5,  message: "Hype train time"),
            .init(user: "casey",type: "Bits", amount: 300, message: "GGs"),
            .init(user: "dev",  type: "Sub",  amount: 1),
            .init(user: "ez",   type: "Gift", amount: 10, message: "Love the stream")
        ]
        contributions = seed
        current = seed.reduce(0) { $0 + normalizedPoints(for: $1) }
    }

    // scoring: Sub = 10 each, Gift = 10 each, Bits = amount/100
    private func normalizedPoints(for c: Contribution) -> Int {
        switch c.type {
        case "Sub":  return 10 * c.amount
        case "Gift": return 10 * c.amount
        case "Bits": return c.amount / 100
        default:     return 0
        }
    }

    func addRandom() {
        let samplePool: [Contribution] = [
            .init(user: "kay", type: "Sub",  amount: 1,   message: "🔥"),
            .init(user: "leo", type: "Gift", amount: 3),
            .init(user: "may", type: "Bits", amount: 500, message: "Pog")
        ]
        let sample = samplePool.randomElement()!
        contributions.insert(sample, at: 0)
        current += normalizedPoints(for: sample)
    }

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }
}

struct ContentView: View {
    @StateObject private var vm = CommerceViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Goal Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Community Goal")
                        .font(.title2).bold()
                    ProgressView(value: vm.progress)
                        .progressViewStyle(.linear)
                    HStack {
                        Text("Progress: \(vm.current)/\(vm.goal) pts")
                        Spacer()
                        Button("Add Random Event") {
                            vm.addRandom()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))

                // Contributions List
                List(vm.contributions) { c in
                    HStack(spacing: 12) {
                        Circle().frame(width: 10, height: 10)
                        VStack(alignment: .leading) {
                            Text("\(c.user) • \(c.type)")
                                .font(.headline)
                            Text(detailText(for: c))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("+\(points(for: c))")
                            .font(.headline)
                    }
                }
                .listStyle(.plain)
            }
            .padding()
            .navigationTitle("TwitchCommerceDemo")
        }
    }

    private func points(for c: Contribution) -> Int {
        switch c.type {
        case "Sub":  return 10 * c.amount
        case "Gift": return 10 * c.amount
        case "Bits": return c.amount / 100
        default:     return 0
        }
    }

    private func detailText(for c: Contribution) -> String {
        switch c.type {
        case "Sub":
            return "New sub • \(c.amount)x" + (c.message.map { " • \($0)" } ?? "")
        case "Gift":
            return "Gifted subs • \(c.amount)x" + (c.message.map { " • \($0)" } ?? "")
        case "Bits":
            return "Bits • \(c.amount)" + (c.message.map { " • \($0)" } ?? "")
        default:
            return c.message ?? ""
        }
    }
}

#Preview {
    ContentView()
}
