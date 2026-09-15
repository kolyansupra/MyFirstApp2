import SwiftUI

// Категории расходов

// Структура расхода

struct ContentView: View {
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var selectedCategory: Category = .food
    @State private var expenses: [Expense] = []
    @State private var filterCategory: Category? = nil // nil = показывать все
    
    // Отфильтрованные расходы
    var filteredExpenses: [Expense] {
        if let filter = filterCategory {
            return expenses.filter { $0.category == filter }
        } else {
            return expenses
        }
    }
    
    // Общая сумма (по фильтру)
    var total: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 14) {
                Text("💰 Мои расходы")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Название
                TextField("Название (например: Кофе)", text: $expenseName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Сумма
                TextField("Сумма (например: 2.50)", text: $expenseAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding(.horizontal)
                
                // Выбор категории
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(Category.allCases) { cat in
                        Text("\(cat.icon) \(cat.rawValue)").tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Кнопка добавить
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
                
                // Фильтр по категориям
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("Все") { filterCategory = nil }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(filterCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(filterCategory == nil ? .white : .primary)
                            .cornerRadius(8)
                        
                        ForEach(Category.allCases) { cat in
                            Button("\(cat.icon) \(cat.rawValue)") {
                                filterCategory = cat
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(filterCategory == cat ? cat.color :
                                            Color.gray.opacity(0.2))
                                                                        .foregroundColor(filterCategory == cat ? .white : .primary)
                                                                        .cornerRadius(8)
                                                                    }
                                                                }
                                                                .padding(.horizontal)
                                                            }
                                                            
                                                            // Итого
                                                            Text("Итого: $\(String(format: "%.2f", total))")
                                                                .font(.title)
                                                                .fontWeight(.semibold)
                                                            
                                                            // Кнопка очистки
                                                            Button(action: clearAll) {
                                                                Text("🗑 Очистить всё")
                                                                    .font(.subheadline)
                                                                    .foregroundColor(.red)
                                                            }
                                                            
                                                            // Список
                                                            List {
                                                                ForEach(filteredExpenses) { expense in
                                                                    HStack {
                                                                        Text("\(expense.category.icon)")
                                                                        VStack(alignment: .leading) {
                                                                            Text(expense.name)
                                                                                .font(.headline)
                                                                            Text(expense.category.rawValue)
                                                                                .font(.caption)
                                                                                .foregroundColor(.gray)
                                                                        }
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
                                                
                                                func addExpense() {
                                                    guard let amount = Double(expenseAmount), !expenseName.isEmpty else { return }
                                                    let newExpense = Expense(name: expenseName, amount: amount, category: selectedCategory)
                                                    expenses.append(newExpense)
                                                    expenseName = ""
                                                    expenseAmount = ""
                                                    saveExpenses()
                                                }
                                                
                                                func deleteExpense(at offsets: IndexSet) {
                                                    // Учитываем фильтр: удаляем по правильному индексу
                                                    let indicesToRemove = offsets.map { filteredExpenses[$0].id }
                                                    expenses.removeAll { indicesToRemove.contains($0.id) }
                                                    saveExpenses()
                                                }
                                                
                                                func clearAll() {
                                                    expenses.removeAll()
                                                    saveExpenses()
                                                }
                                                
                                                func saveExpenses() {
                                                    if let encoded = try? JSONEncoder().encode(expenses) {
                                                        UserDefaults.standard.set(encoded, forKey: "savedExpenses")
                                                    }
                                                }
                                                
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
