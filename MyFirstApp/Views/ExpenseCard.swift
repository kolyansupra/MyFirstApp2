import SwiftUI

struct ExpenseCard: View {
    let expense: Expense
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(expense.category.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(expense.category.icon)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", expense.amount))")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(expense.category.color)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
