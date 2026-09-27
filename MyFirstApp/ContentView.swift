import SwiftUI

// Категории расходов

// Структура расхода

struct ContentView: View {
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var selectedCategory: Category = .food
    @State private var expenses: [Expense] = []
    @State private var filterCategory: Category? = nil // nil = показывать все
    @State private var editingExpense: Expense? = nil
    @State private var dateFilter: DateFilter = .all
    @State private var showingShareSheet = false
    @State private var csvFileURL: URL? = nil
    @State private var monthlyBudget: Double = UserDefaults.standard.double(forKey: "monthlyBudget")
    
    // Отфильтрованные расходы
    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            let categoryMatch = filterCategory == nil || expense.category == filterCategory
            let dateMatch = dateFilter.matches(expense.date)
            return categoryMatch && dateMatch
        }
    }
    
    // Общая сумма (по фильтру)
    var total: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                            Button("Все") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    filterCategory = nil
                                }
                            }
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
                    
                    // Фильтр по датам
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(DateFilter.allCases) { filter in
                                Button(filter.rawValue) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        dateFilter = filter
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(dateFilter == filter ? Color.green : Color(.tertiarySystemFill))
                                .foregroundColor(dateFilter == filter ? .white : .primary)
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
                    // Кнопка экспорта
                    Button(action: exportCSV) {
                        Text("📤 Экспорт в CSV")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    // Диаграмма расходов по категориям
                    ChartView(expenses: expenses)
                    // Бюджет на месяц
                    BudgetView(monthlyBudget: $monthlyBudget, totalSpent: total)
                    
                    // Список карточек
                    ForEach(filteredExpenses) { expense in
                        ExpenseCard(expense: expense, onDelete: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                let id = expense.id
                                expenses.removeAll { $0.id == id }
                                saveExpenses()
                            }
                        })
                        .onTapGesture {
                            editingExpense = expense
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }
                .padding(.top)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.15),
                        Color.purple.opacity(0.1),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Трекер")
                .sheet(item: $editingExpense) { expense in
                    EditExpenseView(expense: expense) { updated in
                        if let index = expenses.firstIndex(where: { $0.id == updated.id }) {
                            expenses[index] = updated
                            saveExpenses()
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let url = csvFileURL {
                        ShareSheet(items: [url])
                    }
                }
                                                        .onAppear(perform: loadExpenses)
                                                    }
                                                }
                                                
    func addExpense() {
        guard let amount = Double(expenseAmount), !expenseName.isEmpty else { return }
        let newExpense = Expense(name: expenseName, amount: amount, category: selectedCategory)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            expenses.append(newExpense)
        }
        
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
    func exportCSV() {
        let csv = ExportHelper.makeCSV(from: expenses)
        if let url = ExportHelper.saveToTemporaryFile(csv: csv) {
            csvFileURL = url
            showingShareSheet = true
        }
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
