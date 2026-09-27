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
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок с иконкой
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        category.color.opacity(0.3),
                                        category.color.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(category.icon)
                            .font(.system(size: 36))
                    }
                    .padding(.top, 20)
                    
                    // Поля ввода
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            TextField("Название", text: $name)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(10)
                        
                        HStack(spacing: 10) {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            TextField("Сумма", text: $amount)
                                .textFieldStyle(.plain)
                                .keyboardType(.decimalPad)
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Категории
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Категория")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Category.allCases) { cat in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            category = cat
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(cat.icon)
                                            Text(cat.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(category == cat ? cat.color : Color(.tertiarySystemFill))
                                        .foregroundColor(category == cat ? .white : .primary)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Кнопка сохранить
                    Button(action: save) {
                        Text("💾 Сохранить")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.1),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
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
                category: category,
                date: expense.date
            )
            onSave(updated)
            dismiss()
        }
    }
