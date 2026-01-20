import Foundation
import SwiftData

class SuggestionEngine {
    static let shared = SuggestionEngine()

    private init() {}

    // MARK: - Session Suggestion

    /// Suggère la prochaine séance basée sur le programme actif et l'historique
    func suggestNextSession(
        activeProgram: Program?,
        recentWorkouts: [Workout]
    ) -> ExerciseCategory? {
        // Si pas de programme actif, suggérer basé sur l'historique
        guard let program = activeProgram else {
            return suggestBasedOnHistory(recentWorkouts: recentWorkouts)
        }

        // Utiliser la prochaine séance du programme
        return program.nextSession
    }

    /// Suggestion basée sur l'historique quand il n'y a pas de programme
    private func suggestBasedOnHistory(recentWorkouts: [Workout]) -> ExerciseCategory? {
        // Si pas d'historique, suggérer Push par défaut
        guard let lastWorkout = recentWorkouts.first else {
            return .push
        }

        // Rotation simple: Push -> Pull -> Legs
        let basicRotation: [ExerciseCategory] = [.push, .pull, .legs]
        let lastType = lastWorkout.sessionType

        if let currentIndex = basicRotation.firstIndex(of: lastType) {
            let nextIndex = (currentIndex + 1) % basicRotation.count
            return basicRotation[nextIndex]
        }

        // Si la dernière séance n'était pas dans la rotation de base, suggérer Push
        return .push
    }

    // MARK: - Performance Analysis

    /// Récupère la dernière performance pour un exercice dans les workouts récents
    func getLastPerformance(
        for exercise: Exercise,
        in workouts: [Workout]
    ) -> (weight: Double, reps: Int)? {
        for workout in workouts {
            for workoutExercise in workout.exercises {
                if workoutExercise.exercise?.id == exercise.id {
                    if let maxWeight = workoutExercise.maxWeightUsed,
                       let maxReps = workoutExercise.maxRepsAtMaxWeight {
                        return (maxWeight, maxReps)
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Stats Calculation

    /// Calcule le nombre de séances cette semaine
    func workoutsThisWeek(from workouts: [Workout]) -> Int {
        let startOfWeek = Date().startOfWeek
        return workouts.filter { $0.date >= startOfWeek && $0.isCompleted }.count
    }

    /// Calcule le streak actuel (jours consécutifs d'entraînement)
    func currentStreak(from workouts: [Workout]) -> Int {
        let completedWorkouts = workouts.filter { $0.isCompleted }
            .sorted { $0.date > $1.date }

        guard !completedWorkouts.isEmpty else { return 0 }

        var streak = 0
        var currentDate = Date().startOfDay

        // Si pas d'entraînement aujourd'hui, commencer par hier
        if !completedWorkouts.contains(where: { $0.date.isSameDay(as: currentDate) }) {
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }

        while true {
            if completedWorkouts.contains(where: { $0.date.isSameDay(as: currentDate) }) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }

        return streak
    }

    /// Calcule le volume total de la semaine
    func volumeThisWeek(from workouts: [Workout]) -> Double {
        let startOfWeek = Date().startOfWeek
        return workouts
            .filter { $0.date >= startOfWeek && $0.isCompleted }
            .reduce(0) { $0 + $1.totalVolume }
    }

    /// Calcule le nombre total de séries cette semaine
    func setsThisWeek(from workouts: [Workout]) -> Int {
        let startOfWeek = Date().startOfWeek
        return workouts
            .filter { $0.date >= startOfWeek && $0.isCompleted }
            .reduce(0) { $0 + $1.totalSets }
    }

    // MARK: - Progression Analysis

    /// Vérifie si un exercice a progressé par rapport à la dernière séance
    func hasProgressed(
        exercise: Exercise,
        currentWeight: Double,
        currentReps: Int
    ) -> Bool {
        guard let lastPerformance = exercise.lastPerformance else {
            return true // Première fois = progression
        }

        let currentVolume = currentWeight * Double(currentReps)
        let lastVolume = lastPerformance.maxWeight * Double(lastPerformance.maxReps)

        return currentVolume > lastVolume
    }

    /// Calcule le pourcentage de progression depuis le premier entraînement
    func progressionPercentage(for exercise: Exercise) -> Double? {
        let records = exercise.performanceRecords.sorted { $0.date < $1.date }

        guard records.count >= 2,
              let first = records.first,
              let last = records.last,
              first.maxWeight > 0 else {
            return nil
        }

        return ((last.maxWeight - first.maxWeight) / first.maxWeight) * 100
    }
}
