import SwiftUI

struct BudgetView: View {
    @Binding var monthlyBudget: Double
    let totalSpent: Double
    
    @State private var budgetInput: String = ""
    @State private var isEditing: Bool = false
    
    var progress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(totalSpent / monthlyBudget, 1.0)
    }
    
    var progressColor: Color {
        if progress < 0.7 { return .green }
        if progress < 0.9 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💰 Бюджет на месяц")
                    .font(.headline)
                Spacer()
                Button(isEditing ? "Готово" : "Изменить") {
                    if isEditing {
                        saveBudget()
                    }
                    isEditing.toggle()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if isEditing {
                HStack {
                    Text("$")
                    TextField("1000", text: $budgetInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            } else {
                if monthlyBudget > 0 {
                    // Прогресс-бар
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.tertiarySystemFill))
                                .frame(height: 14)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(progressColor)
                                .frame(width: geo.size.width * progress, height: 14)
                        }
                    }
                    .frame(height: 14)
                    
                    HStack {
                        Text("Потрачено: $\(String(format: "%.2f", totalSpent))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Лимит: $\(String(format: "%.2f", monthlyBudget))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Осталось: $\(String(format: "%.2f", max(monthlyBudget - totalSpent, 0)))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(progressColor)
                } else {
                    Text("Лимит не установлен. Нажмите «Изменить», чтобы задать бюджет.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
        .padding(.horizontal)
        .onAppear {
            budgetInput = monthlyBudget > 0 ? String(format: "%.0f", monthlyBudget) : ""
        }
    }
    
    private func saveBudget() {
        if let value = Double(budgetInput), value > 0 {
            monthlyBudget = value
            UserDefaults.standard.set(value, forKey: "monthlyBudget")
        } else {
            monthlyBudget = 0
            UserDefaults.standard.removeObject(forKey: "monthlyBudget")
        }
    }
}

#Preview {
    BudgetView(monthlyBudget: .constant(1000), totalSpent: 320)
}
