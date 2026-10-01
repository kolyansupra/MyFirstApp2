import SwiftUI
import Charts

struct ChartView: View {
    let expenses: [Expense]
    
    // Группируем расходы по категориям и считаем сумму
    var chartData: [(Category, Double)] {
        Category.allCases.compactMap { cat in
            let sum = expenses
                .filter { $0.category == cat }
                .reduce(0) { $0 + $1.amount }
            return sum > 0 ? (cat, sum) : nil
        }
    }
    
    var body: some View {
        if !chartData.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("📊 Расходы по категориям")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Chart(chartData, id: \.0) { item in
                    SectorMark(
                        angle: .value("Сумма", item.1),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.0.color)
                    .annotation(position: .overlay) {
                        Text(item.0.icon)
                            .font(.caption)
                    }
                }
                .frame(height: 200)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: chartData.count)
                .padding()
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
            .padding(.horizontal)
        }
    }
}

#Preview {
    ChartView(expenses: [
        Expense(name: "Кофе", amount: 3.5, category: .food),
        Expense(name: "Такси", amount: 10, category: .transport),
        Expense(name: "Аренда", amount: 300, category: .housing)
    ])
}
