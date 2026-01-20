import SwiftUI

// MARK: - App Constants
enum AppConstants {
    static let appName = "GymTracker"
    static let defaultRestDuration: RestDuration = .ninety
    static let defaultSetsPerExercise = 4
    static let maxWeight: Double = 300.0
    static let weightStep: Double = 2.5
    static let maxReps = 30
    static let cardCornerRadius: CGFloat = 16
}

// MARK: - App Colors
extension ShapeStyle where Self == Color {
    // Couleurs principales
    static var appPrimary: Color { Color(hex: "FF6B35") }     // Orange gym
    static var appSecondary: Color { Color(hex: "1E88E5") }   // Bleu
    static var appAccent: Color { Color(hex: "FFB74D") }      // Orange clair

    // Couleurs fonctionnelles
    static var appSuccess: Color { Color(hex: "4CAF50") }     // Vert
    static var appWarning: Color { Color(hex: "FF9800") }     // Orange warning
    static var appError: Color { Color(hex: "F44336") }       // Rouge

    // Couleurs de fond
    static var appBackground: Color { Color(UIColor.systemBackground) }
    static var appCardBackground: Color { Color(UIColor.secondarySystemBackground) }
    static var appGroupedBackground: Color { Color(UIColor.systemGroupedBackground) }

    // Couleurs des catégories d'exercices
    static var pushColor: Color { Color(hex: "E53935") }      // Rouge
    static var pullColor: Color { Color(hex: "1E88E5") }      // Bleu
    static var legsColor: Color { Color(hex: "43A047") }      // Vert
    static var jjbColor: Color { Color(hex: "7B1FA2") }       // Violet
    static var mobiliteColor: Color { Color(hex: "00ACC1") }  // Cyan
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startOfDay, to: date.startOfDay)
        return components.day ?? 0
    }

    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: self)
    }

    var formattedFull: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: self).capitalized
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - Double Extensions
extension Double {
    /// Formate le poids (ex: 82.5 -> "82.5kg", 80.0 -> "80kg")
    var formattedWeight: String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(self))kg"
        }
        return String(format: "%.1fkg", self)
    }

    /// Formate le volume (ex: 12500 -> "12,500 kg")
    var formattedVolume: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: self)) ?? "0") kg"
    }
}

// MARK: - Int Extensions
extension Int {
    /// Formate les répétitions
    var formattedReps: String {
        "\(self) reps"
    }
}
