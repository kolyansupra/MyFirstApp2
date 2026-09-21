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
}
