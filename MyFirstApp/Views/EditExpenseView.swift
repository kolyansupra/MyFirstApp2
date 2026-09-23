import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    
    let expense: Expense
    let onSave: (Expense) -> Void
    
    @State private var name: String
    @State private var amount: String
    @State private var category: Category
    
    init(expense: Expense, onSave: @escaping (Expense) -> Void) {
        self.expense = expense
        self.onSave = onSave
        _name = State(initialValue: expense.name)
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
        _category = State(initialValue: expense.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Название") {
                    TextField("Например: Кофе", text: $name)
                }
                
                Section("Сумма") {
                    TextField("2.50", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $category) {
                        ForEach(Category.allCases) { cat in
                            Text("\(cat.icon) \(cat.rawValue)").tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && Double(amount) != nil
    }
    
    private func save() {
        guard let amountDouble = Double(amount) else { return }
        let updated = Expense(
            id: expense.id,
            name: name,
            amount: amountDouble,
            category: category
        )
        onSave(updated)
        dismiss()
    }
}

#Preview {
    EditExpenseView(
        expense: Expense(name: "Кофе", amount: 3.5, category: .food),
        onSave: { _ in }
    )
}
