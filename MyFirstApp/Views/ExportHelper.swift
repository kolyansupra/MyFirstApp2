import Foundation
import SwiftUI

struct ExportHelper {
    /// Превращает массив расходов в CSV-строку
    static func makeCSV(from expenses: [Expense]) -> String {
        var csv = "Дата,Название,Категория,Сумма\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for expense in expenses {
            let dateStr = formatter.string(from: expense.date)
            let name = escapeCSV(expense.name)
            let category = expense.category.rawValue
            let amount = String(format: "%.2f", expense.amount)
            
            csv += "\(dateStr),\(name),\(category),\(amount)\n"
        }
        
        return csv
    }
    
    /// Экранирует запятые и кавычки в тексте
    private static func escapeCSV(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") {
            return "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return text
    }
    
    /// Сохраняет CSV во временный файл и возвращает URL
    static func saveToTemporaryFile(csv: String, filename: String = "expenses.csv") -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Ошибка сохранения CSV: \(error)")
            return nil
        }
    }
}
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
