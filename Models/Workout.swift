import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var sessionTypeRaw: String
    var date: Date
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise]

    // MARK: - Computed Properties

    var sessionType: ExerciseCategory {
        get { ExerciseCategory(rawValue: sessionTypeRaw) ?? .push }
        set { sessionTypeRaw = newValue.rawValue }
    }

    /// Durée de la séance en minutes
    var duration: Int {
        guard let endTime = endTime else {
            return Int(Date().timeIntervalSince(startTime) / 60)
        }
        return Int(endTime.timeIntervalSince(startTime) / 60)
    }

    /// Durée formatée (ex: "1h 23min")
    var durationFormatted: String {
        let hours = duration / 60
        let minutes = duration % 60

        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }

    /// Volume total de la séance (poids x reps)
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    /// Volume formaté (ex: "12,500 kg")
    var totalVolumeFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: totalVolume)) ?? "0") kg"
    }

    /// Nombre total de séries complétées
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.completedSetsCount }
    }

    /// Nombre total d'exercices
    var exercisesCount: Int {
        exercises.count
    }

    /// Date formatée (ex: "Lundi 15 Janvier")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM"
        return formatter.string(from: date).capitalized
    }

    /// Heure de début formatée
    var startTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }

    /// Exercices triés par ordre
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }

    // MARK: - Initialization

    init(
        sessionType: ExerciseCategory,
        date: Date = Date(),
        notes: String? = nil
    ) {
        self.id = UUID()
        self.sessionTypeRaw = sessionType.rawValue
        self.date = date
        self.startTime = Date()
        self.endTime = nil
        self.isCompleted = false
        self.notes = notes
        self.exercises = []
    }

    // MARK: - Methods

    /// Termine la séance
    func complete() {
        self.endTime = Date()
        self.isCompleted = true
    }

    /// Annule la séance
    func cancel() {
        self.endTime = Date()
        self.isCompleted = false
    }

    /// Ajoute un exercice à la séance
    func addExercise(_ exercise: Exercise, lastWeight: Double? = nil, lastReps: Int? = nil) -> WorkoutExercise {
        let workoutExercise = WorkoutExercise(
            order: exercises.count,
            lastWeight: lastWeight,
            lastReps: lastReps
        )
        workoutExercise.exercise = exercise
        workoutExercise.workout = self
        exercises.append(workoutExercise)
        return workoutExercise
    }
}
