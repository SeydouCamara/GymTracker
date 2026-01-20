import Foundation
import SwiftData
import SwiftUI

@Observable
class HomeViewModel {
    var modelContext: ModelContext?

    // Data
    var activeProgram: Program?
    var recentWorkouts: [Workout] = []
    var exercises: [Exercise] = []

    // Stats
    var suggestedSession: ExerciseCategory?
    var workoutsThisWeek: Int = 0
    var currentStreak: Int = 0
    var volumeThisWeek: Double = 0
    var setsThisWeek: Int = 0

    // State
    var showingWorkoutTab: Bool = false

    private let suggestionEngine = SuggestionEngine.shared

    // MARK: - Initialization

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
        calculateStats()
    }

    func refresh() {
        loadData()
        calculateStats()
    }

    // MARK: - Load Data

    private func loadData() {
        guard let modelContext else { return }

        // Load active program
        let programPredicate = #Predicate<Program> { $0.isActive == true }
        let programDescriptor = FetchDescriptor<Program>(predicate: programPredicate)

        do {
            activeProgram = try modelContext.fetch(programDescriptor).first
        } catch {
            print("Error fetching active program: \(error)")
        }

        // Load recent workouts (last 30 days)
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let workoutPredicate = #Predicate<Workout> { $0.date >= thirtyDaysAgo }
        let workoutDescriptor = FetchDescriptor<Workout>(
            predicate: workoutPredicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            recentWorkouts = try modelContext.fetch(workoutDescriptor)
        } catch {
            print("Error fetching workouts: \(error)")
        }

        // Load exercises
        let exerciseDescriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            exercises = try modelContext.fetch(exerciseDescriptor)
        } catch {
            print("Error fetching exercises: \(error)")
        }
    }

    // MARK: - Calculate Stats

    private func calculateStats() {
        // Suggested session
        suggestedSession = suggestionEngine.suggestNextSession(
            activeProgram: activeProgram,
            recentWorkouts: recentWorkouts
        )

        // Weekly stats
        workoutsThisWeek = suggestionEngine.workoutsThisWeek(from: recentWorkouts)
        currentStreak = suggestionEngine.currentStreak(from: recentWorkouts)
        volumeThisWeek = suggestionEngine.volumeThisWeek(from: recentWorkouts)
        setsThisWeek = suggestionEngine.setsThisWeek(from: recentWorkouts)
    }

    // MARK: - Computed Properties

    var hasExercises: Bool {
        !exercises.isEmpty
    }

    var exercisesForSuggestedSession: Int {
        guard let session = suggestedSession else { return 0 }
        return exercises.filter { $0.category == session }.count
    }

    var lastWorkout: Workout? {
        recentWorkouts.first { $0.isCompleted }
    }

    var daysSinceLastWorkout: Int? {
        guard let lastWorkout = lastWorkout else { return nil }
        return lastWorkout.date.daysBetween(Date())
    }

    var formattedVolumeThisWeek: String {
        volumeThisWeek.formattedVolume
    }
}
