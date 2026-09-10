import SwiftUI

struct ContentView: View {
    @State private var totalExpenses: Double = 0.0
    @State private var expenseName: String = ""
    @State private var expenseAmount: String = ""
    @State private var expenses: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("💰 Мои расходы")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Название (например: Кофе)", text: $expenseName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Сумма (например: 2.50)", text: $expenseAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding(.horizontal)
                
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
                
                Text("Итого: $\(String(format: "%.2f", totalExpenses))")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()
                
                List(expenses, id: \.self) { expense in
                    Text(expense)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
            }
            .padding()
            .navigationTitle("Трекер")
        }
    }
    
    func addExpense() {
        guard let amount = Double(expenseAmount), !expenseName.isEmpty else {
            return
        }
        totalExpenses += amount
        expenses.append("\(expenseName): $\(String(format: "%.2f", amount))")
        expenseName = ""
        expenseAmount = ""
    }
}

#Preview {
    ContentView()
}
