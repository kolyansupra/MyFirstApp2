import SwiftUI

// Структура для одного расхода (название + сумма)
struct Expense: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
}

struct ContentView: View {
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var expenses: [Expense] = []
    
    // Общая сумма всех расходов
    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("💰 Мои расходы")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Поля для ввода
                TextField("Название (например: Кофе)", text: $expenseName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Сумма (например: 2.50)", text: $expenseAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding(.horizontal)
                
                // Кнопка "Добавить"
                Button(action: addExpense) {
                    Text("➕ Добавить расход")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Итого
                Text("Итого: $\(String(format: "%.2f", total))")
                    .font(.title)
                    .fontWeight(.semibold)
                
                // Кнопка "Очистить всё"
                Button(action: clearAll) {
                    Text("🗑 Очистить всё")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.top, 4)
                
                // Список расходов
                List {
                    ForEach(expenses) { expense in
                        HStack {
                            Text(expense.name)
                            Spacer()
                            Text("$\(String(format: "%.2f", expense.amount))")
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteExpense)
                }
                .listStyle(PlainListStyle())
            }
            .padding(.top)
            .navigationTitle("Трекер")
            .onAppear(perform: loadExpenses)
        }
    }
    
    // Добавить расход
    func addExpense() {
        guard let amount = Double(expenseAmount), !expenseName.isEmpty else { return }
        let newExpense = Expense(name: expenseName, amount: amount)
        expenses.append(newExpense)
        expenseName = ""
        expenseAmount = ""
        saveExpenses()
    }
    
    // Удалить расход смахиванием
    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }
    
    // Очистить всё
    func clearAll() {
        expenses.removeAll()
        saveExpenses()
    }
    
    // СОХРАНЕНИЕ данных в UserDefaults
    func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "savedExpenses")
        }
    }
    
    // ЗАГРУЗКА данных из UserDefaults
    func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: "savedExpenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
    }
}

#Preview {
    ContentView()
}
