import Foundation
import SwiftData

@Model
final class PerformanceRecord {
    var id: UUID
    var date: Date
    var maxWeight: Double
    var maxReps: Int
    var totalVolume: Double
    var totalSets: Int

    var exercise: Exercise?

    // MARK: - Computed Properties

    /// Date formatée (ex: "15 Jan 2024")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    /// Texte du meilleur set (ex: "100kg x 8")
    var bestSetText: String {
        "\(Int(maxWeight))kg x \(maxReps)"
    }

    /// Volume moyen par série
    var averageVolumePerSet: Double {
        guard totalSets > 0 else { return 0 }
        return totalVolume / Double(totalSets)
    }

    // MARK: - Initialization

    init(
        date: Date = Date(),
        maxWeight: Double,
        maxReps: Int,
        totalVolume: Double,
        totalSets: Int
    ) {
        self.id = UUID()
        self.date = date
        self.maxWeight = maxWeight
        self.maxReps = maxReps
        self.totalVolume = totalVolume
        self.totalSets = totalSets
    }

    // MARK: - Factory

    /// Crée un PerformanceRecord à partir d'un WorkoutExercise
    static func from(workoutExercise: WorkoutExercise) -> PerformanceRecord? {
        let completedSets = workoutExercise.sets.filter { $0.isCompleted }

        guard !completedSets.isEmpty else { return nil }

        let maxWeight = completedSets.compactMap { $0.weight }.max() ?? 0
        let maxRepsAtMaxWeight = completedSets
            .filter { $0.weight == maxWeight }
            .compactMap { $0.reps }
            .max() ?? 0

        let totalVolume = completedSets.reduce(0.0) { total, set in
            total + ((set.weight ?? 0) * Double(set.reps ?? 0))
        }

        return PerformanceRecord(
            date: Date(),
            maxWeight: maxWeight,
            maxReps: maxRepsAtMaxWeight,
            totalVolume: totalVolume,
            totalSets: completedSets.count
        )
    }
}
