import SwiftUI

struct ContentView: View {
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var selectedCategory: Category = .food
    @State private var expenses: [Expense] = []
    @State private var filterCategory: Category? = nil
    @State private var editingExpense: Expense? = nil
    @State private var dateFilter: DateFilter = .all
    @State private var showingShareSheet = false
    @State private var csvFileURL: URL? = nil
    @State private var monthlyBudget: Double = UserDefaults.standard.double(forKey: "monthlyBudget")

    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            let categoryMatch = filterCategory == nil || expense.category == filterCategory
            let dateMatch = dateFilter.matches(expense.date)
            return categoryMatch && dateMatch
        }
    }

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

                    // Форма ввода
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            TextField("Название (например: Кофе)", text: $expenseName)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(10)

                        HStack(spacing: 10) {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            TextField("Сумма (например: 2.50)", text: $expenseAmount)
                                .textFieldStyle(.plain)
                                .keyboardType(.decimalPad)
                        }
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(10)

                        // Горизонтальный Picker категорий
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Category.allCases) { cat in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = cat
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
                                        .background(selectedCategory == cat ? cat.color : Color(.tertiarySystemFill))
                                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
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
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(filterCategory == nil ? Color.blue : Color(.tertiarySystemFill))
                            .foregroundColor(filterCategory == nil ? .white : .primary)
                            .cornerRadius(8)

                            ForEach(Category.allCases) { cat in
                                Button("\(cat.icon) \(cat.rawValue)") {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        filterCategory = cat
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(filterCategory == cat ? cat.color
                                            : Color(.tertiarySystemFill))
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

                                                                // Диаграмма
                                                                ChartView(expenses: expenses)

                                                                // Бюджет
                                                                BudgetView(monthlyBudget: $monthlyBudget, totalSpent: total)

                                                                // Список карточек или пустой экран
                                                                if filteredExpenses.isEmpty {
                                                                    EmptyStateView()
                                                                } else {
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
