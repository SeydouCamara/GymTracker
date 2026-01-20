import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var categoryRaw: String
    var muscleGroupRaw: String
    var notes: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PerformanceRecord.exercise)
    var performanceRecords: [PerformanceRecord]

    @Relationship(inverse: \WorkoutExercise.exercise)
    var workoutExercises: [WorkoutExercise]

    // MARK: - Computed Properties

    var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRaw) ?? .push }
        set { categoryRaw = newValue.rawValue }
    }

    var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .chest }
        set { muscleGroupRaw = newValue.rawValue }
    }

    // MARK: - Initialization

    init(
        name: String,
        category: ExerciseCategory,
        muscleGroup: MuscleGroup,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.muscleGroupRaw = muscleGroup.rawValue
        self.notes = notes
        self.createdAt = Date()
        self.performanceRecords = []
        self.workoutExercises = []
    }

    // MARK: - Helpers

    /// Retourne le dernier record de performance
    var lastPerformance: PerformanceRecord? {
        performanceRecords.sorted { $0.date > $1.date }.first
    }

    /// Retourne le poids maximum jamais soulevé
    var personalBestWeight: Double? {
        performanceRecords.map { $0.maxWeight }.max()
    }

    /// Retourne le volume total sur tous les entraînements
    var totalVolumeAllTime: Double {
        performanceRecords.reduce(0) { $0 + $1.totalVolume }
    }
}
