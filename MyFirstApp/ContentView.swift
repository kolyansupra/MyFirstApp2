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
                VStack(spacing: 16) {
                    // Заголовок
                    Text("💰 Мои расходы")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                    // Форма ввода
                    formCard

                    // Фильтр категорий
                    categoryFilterCard

                    // Фильтр дат
                    dateFilterCard

                    // Итого
                    totalCard

                    // Диаграмма
                    ChartView(expenses: expenses)

                    // Бюджет
                    BudgetView(monthlyBudget: $monthlyBudget, totalSpent: total)

                    // Кнопки
                    actionButtons

                    // Список карточек или пустой экран
                    if filteredExpenses.isEmpty {
                        EmptyStateView()
                    } else {
                        ForEach(filteredExpenses) { expense in
                            ExpenseCard(expense: expense, onDelete: {
                                Haptics.medium()
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    let id = expense.id
                                    expenses.removeAll { $0.id == id }
                                    saveExpenses()
                                }
                            })
                            .onTapGesture {
                                editingExpense = expense
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 40)
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
            .navigationBarHidden(true)
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

                // MARK: - Форма ввода (карточка)
                var formCard: some View {
                    VStack(spacing: 12) {
                        // Поле "Название"
                        HStack(spacing: 10) {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            TextField("Название (например: Кофе)", text: $expenseName)
                                .textFieldStyle(.plain)
                        }
                        .padding(14)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(12)

                        // Поле "Сумма"
                        HStack(spacing: 10) {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            TextField("Сумма (например: 2.50)", text: $expenseAmount)
                                .textFieldStyle(.plain)
                                .keyboardType(.decimalPad)
                        }
                        .padding(14)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(12)

                        // Кнопка "Добавить"
                        Button(action: addExpense) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Добавить расход")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(cardBackground)
                    .padding(.horizontal, 16)
                }

                // MARK: - Фильтр категорий (плитки)
                var categoryFilterCard: some View {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Категория")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Кнопка "Все"
                                CategoryTile(
                                    icon: "square.grid.2x2.fill",
                                    title: "Все",
                                    color: .blue,
                                    isSelected: filterCategory == nil
                                ) {
                                    Haptics.light()
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        filterCategory = nil
                                    }
                                }

                                // Категории
                                ForEach(Category.allCases) { cat in
                                    CategoryTile(
                                        icon: cat.icon,
                                        title: cat.rawValue,
                                        color: cat.color,
                                        isSelected: filterCategory == cat
                                    ) {
                                        Haptics.light()
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            filterCategory = cat
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(16)
                    .background(cardBackground)
                    .padding(.horizontal, 16)
                }

                // MARK: - Фильтр дат (pill-кнопки)
                var dateFilterCard: some View {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Период")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        HStack(spacing: 8) {
                            ForEach(DateFilter.allCases) { filter in
                                                        Button {
                                                            Haptics.light()
                                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                                dateFilter = filter
                                                            }
                                                        } label: {
                                                            Text(filter.rawValue)
                                                                .font(.subheadline)
                                                                .fontWeight(.medium)
                                                                .padding(.horizontal, 12)
                                                                .padding(.vertical, 8)
                                                                .frame(maxWidth: .infinity)
                                                                .background(dateFilter == filter ? Color.green : Color(.tertiarySystemFill))
                                                                .foregroundColor(dateFilter == filter ? .white : .primary)
                                                                .cornerRadius(20)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(16)
                                            .background(cardBackground)
                                            .padding(.horizontal, 16)
                                        }

                                        // MARK: - Итого
                                        var totalCard: some View {
                                            VStack(spacing: 4) {
                                                Text("Итого за период")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)

                                                Text("$\(String(format: "%.2f", total))")
                                                    .font(.system(size: 36, weight: .bold))
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(20)
                                            .background(cardBackground)
                                            .padding(.horizontal, 16)
                                        }

                                        // MARK: - Кнопки действий
                                        var actionButtons: some View {
                                            HStack(spacing: 12) {
                                                Button(action: exportCSV) {
                                                    HStack {
                                                        Image(systemName: "square.and.arrow.up")
                                                        Text("Экспорт")
                                                            .fontWeight(.medium)
                                                    }
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 12)
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.blue.opacity(0.9))
                                                    .cornerRadius(12)
                                                }

                                                Button(action: clearAll) {
                                                    HStack {
                                                        Image(systemName: "trash")
                                                        Text("Очистить")
                                                            .fontWeight(.medium)
                                                    }
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 12)
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.red.opacity(0.85))
                                                    .cornerRadius(12)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }

                                        // MARK: - Общий фон карточки
                                        var cardBackground: some View {
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color(.secondarySystemBackground))
                                                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                                        }

                                        // MARK: - Функции
                                        func addExpense() {
                                            guard let amount = Double(expenseAmount), !expenseName.isEmpty else { return }
                                            let newExpense = Expense(name: expenseName, amount: amount, category: selectedCategory)
                                            Haptics.success()
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                expenses.append(newExpense)
                                            }
                                            expenseName = ""
                                            expenseAmount = ""
                                            saveExpenses()
                                        }

                                        func clearAll() {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                expenses.removeAll()
                                                saveExpenses()
                                            }
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
                                               let decoded = try? JSONDecoder()
                                                .decode([Expense].self, from: data) {
                                                            expenses = decoded
                                                        }
                                                    }
                                                }

                                                // MARK: - Плитка категории (кружок + текст)
                                                struct CategoryTile: View {
                                                    let icon: String
                                                    let title: String
                                                    let color: Color
                                                    let isSelected: Bool
                                                    let action: () -> Void

                                                    var body: some View {
                                                        Button(action: action) {
                                                            VStack(spacing: 6) {
                                                                ZStack {
                                                                    Circle()
                                                                        .fill(isSelected ? color : Color(.tertiarySystemFill))
                                                                        .frame(width: 56, height: 56)
                                                                    if icon.contains(".") {
                                                                        Image(systemName: icon)
                                                                            .font(.title2)
                                                                            .foregroundColor(isSelected ? .white : color)
                                                                    } else {
                                                                        Text(icon)
                                                                            .font(.title2)
                                                                    }
                                                                }

                                                                Text(title)
                                                                    .font(.caption)
                                                                    .fontWeight(isSelected ? .semibold : .regular)
                                                                    .foregroundColor(isSelected ? color : .secondary)
                                                                    .lineLimit(1)
                                                                    .frame(width: 64)
                                                            }
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                }

                                                #Preview {
                                                    ContentView()
                                                }
