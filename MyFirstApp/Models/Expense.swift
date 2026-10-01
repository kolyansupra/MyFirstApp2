import SwiftUI

enum Category: String, CaseIterable, Codable, Identifiable {
    case food = "Еда"
    case transport = "Транспорт"
    case housing = "Жильё"
    case fun = "Развлечения"
    case other = "Другое"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .food: return "🍔"
        case .transport: return "🚗"
        case .housing: return "🏠"
        case .fun: return "🎉"
        case .other: return "📦"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .housing: return .green
        case .fun: return .purple
        case .other: return .gray
        }
    }
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var category: Category
    var date: Date
    
    init(id: UUID = UUID(), name: String, amount: Double, category: Category, date: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.date = date
    }
}

enum DateFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case today = "День"
    case week = "Неделя"
    case month = "Месяц"
    
    var id: String { self.rawValue }
    
    func matches(_ date: Date) -> Bool {
        let calendar = Calendar.current
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return false }
            return date >= weekAgo
        case .month:
            guard let monthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) else { return false }
            return date >= monthAgo
        }
    }
}
