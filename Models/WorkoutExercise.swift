import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var id: UUID
    var order: Int
    var notes: String?
    var lastWeight: Double?
    var lastReps: Int?

    var workout: Workout?
    var exercise: Exercise?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workoutExercise)
    var sets: [ExerciseSet]

    // MARK: - Computed Properties

    /// Séries triées par numéro
    var sortedSets: [ExerciseSet] {
        sets.sorted { $0.setNumber < $1.setNumber }
    }

    /// Nombre de séries complétées
    var completedSetsCount: Int {
        sets.filter { $0.isCompleted }.count
    }

    /// Nombre total de séries
    var totalSetsCount: Int {
        sets.count
    }

    /// Progression des séries (ex: "3/4")
    var setsProgress: String {
        "\(completedSetsCount)/\(totalSetsCount)"
    }

    /// Volume total de cet exercice dans la séance
    var totalVolume: Double {
        sets.filter { $0.isCompleted }.reduce(0) { total, set in
            total + ((set.weight ?? 0) * Double(set.reps ?? 0))
        }
    }

    /// Poids maximum utilisé dans cette séance
    var maxWeightUsed: Double? {
        sets.filter { $0.isCompleted }.compactMap { $0.weight }.max()
    }

    /// Reps maximum avec le poids max
    var maxRepsAtMaxWeight: Int? {
        guard let maxWeight = maxWeightUsed else { return nil }
        return sets.filter { $0.isCompleted && $0.weight == maxWeight }
            .compactMap { $0.reps }
            .max()
    }

    /// Texte formaté "Last time" (ex: "80kg x 10")
    var lastTimeText: String? {
        guard let weight = lastWeight, let reps = lastReps else { return nil }
        return "\(Int(weight))kg x \(reps)"
    }

    /// Indique si toutes les séries sont complétées
    var isFullyCompleted: Bool {
        !sets.isEmpty && sets.allSatisfy { $0.isCompleted }
    }

    // MARK: - Initialization

    init(
        order: Int,
        lastWeight: Double? = nil,
        lastReps: Int? = nil,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.order = order
        self.lastWeight = lastWeight
        self.lastReps = lastReps
        self.notes = notes
        self.sets = []
    }

    // MARK: - Methods

    /// Ajoute une série à l'exercice
    func addSet(isWarmup: Bool = false) -> ExerciseSet {
        let newSet = ExerciseSet(
            setNumber: sets.count + 1,
            isWarmup: isWarmup
        )
        newSet.workoutExercise = self
        sets.append(newSet)
        return newSet
    }

    /// Supprime une série
    func removeSet(_ set: ExerciseSet) {
        sets.removeAll { $0.id == set.id }
        // Renuméroter les séries
        for (index, set) in sortedSets.enumerated() {
            set.setNumber = index + 1
        }
    }

    /// Ajoute plusieurs séries d'un coup
    func addSets(count: Int, isWarmup: Bool = false) {
        for _ in 0..<count {
            _ = addSet(isWarmup: isWarmup)
        }
    }
}
