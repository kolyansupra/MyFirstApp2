import SwiftUI

struct ExpenseCard: View {
    let expense: Expense
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Иконка категории в градиентном кружке
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                expense.category.color.opacity(0.3),
                                expense.category.color.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: expense.category.color.opacity(0.25), radius: 4, x: 0, y: 2)
                
                Text(expense.category.icon)
                    .font(.title3)
            }
            
            // Название + категория
            VStack(alignment: .leading, spacing: 3) {
                Text(expense.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(expense.category.color)
                        .frame(width: 6, height: 6)
                    
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Сумма
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", expense.amount))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(expense.category.color)
                
                Text(expense.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

#Preview {
    VStack {
        ExpenseCard(
            expense: Expense(name: "Кофе", amount: 3.50, category: .food),
            onDelete: {}
        )
        ExpenseCard(
            expense: Expense(name: "Такси", amount: 12.00, category: .transport),
            onDelete: {}
        )
    }
    .padding()
}
