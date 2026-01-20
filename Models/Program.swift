import Foundation
import SwiftData

@Model
final class Program {
    var id: UUID
    var name: String
    var sessionOrderRaw: [String]
    var isActive: Bool
    var currentSessionIndex: Int
    var createdAt: Date

    // MARK: - Computed Properties

    /// Ordre des séances comme array d'ExerciseCategory
    var sessionOrder: [ExerciseCategory] {
        get {
            sessionOrderRaw.compactMap { ExerciseCategory(rawValue: $0) }
        }
        set {
            sessionOrderRaw = newValue.map { $0.rawValue }
        }
    }

    /// Prochaine séance à effectuer
    var nextSession: ExerciseCategory? {
        guard !sessionOrder.isEmpty else { return nil }
        let index = currentSessionIndex % sessionOrder.count
        return sessionOrder[index]
    }

    /// Nombre total de séances dans le programme
    var totalSessions: Int {
        sessionOrder.count
    }

    /// Affichage formaté de l'ordre des séances
    var sessionOrderDisplay: String {
        sessionOrder.map { $0.displayName }.joined(separator: " → ")
    }

    // MARK: - Initialization

    init(
        name: String,
        sessionOrder: [ExerciseCategory] = [],
        isActive: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.sessionOrderRaw = sessionOrder.map { $0.rawValue }
        self.isActive = isActive
        self.currentSessionIndex = 0
        self.createdAt = Date()
    }

    // MARK: - Methods

    /// Avance à la prochaine séance dans le cycle
    func advanceToNextSession() {
        guard !sessionOrder.isEmpty else { return }
        currentSessionIndex = (currentSessionIndex + 1) % sessionOrder.count
    }

    /// Réinitialise l'index de la séance courante
    func resetSessionIndex() {
        currentSessionIndex = 0
    }

    /// Retourne la séance à un index donné (cyclique)
    func session(at index: Int) -> ExerciseCategory? {
        guard !sessionOrder.isEmpty else { return nil }
        let normalizedIndex = index % sessionOrder.count
        return sessionOrder[normalizedIndex]
    }
}
