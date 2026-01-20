import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var id: UUID
    var setNumber: Int
    var weight: Double?
    var reps: Int?
    var isCompleted: Bool
    var completedAt: Date?
    var isWarmup: Bool

    var workoutExercise: WorkoutExercise?

    // MARK: - Computed Properties

    /// Volume de la série (poids x reps)
    var volume: Double {
        guard let weight = weight, let reps = reps else { return 0 }
        return weight * Double(reps)
    }

    /// Texte formaté de la série (ex: "80kg x 10")
    var displayText: String {
        guard let weight = weight, let reps = reps else {
            return "— x —"
        }
        return "\(Int(weight))kg x \(reps)"
    }

    /// Label de la série (ex: "Set 1" ou "Warmup")
    var label: String {
        if isWarmup {
            return "Échauffement"
        }
        return "Série \(setNumber)"
    }

    /// Label court (ex: "1" ou "W")
    var shortLabel: String {
        if isWarmup {
            return "E"
        }
        return "\(setNumber)"
    }

    // MARK: - Initialization

    init(
        setNumber: Int,
        weight: Double? = nil,
        reps: Int? = nil,
        isWarmup: Bool = false
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
        self.completedAt = nil
        self.isWarmup = isWarmup
    }

    // MARK: - Methods

    /// Complète la série avec le poids et les répétitions
    func complete(weight: Double, reps: Int) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = true
        self.completedAt = Date()
    }

    /// Marque la série comme incomplète
    func uncomplete() {
        self.isCompleted = false
        self.completedAt = nil
    }

    /// Toggle l'état de complétion
    func toggle() {
        if isCompleted {
            uncomplete()
        } else if let weight = weight, let reps = reps {
            complete(weight: weight, reps: reps)
        }
    }

    /// Met à jour les valeurs sans changer l'état de complétion
    func update(weight: Double?, reps: Int?) {
        self.weight = weight
        self.reps = reps
    }
}
