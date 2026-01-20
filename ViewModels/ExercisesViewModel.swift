import Foundation
import SwiftData
import SwiftUI

@Observable
class ExercisesViewModel {
    var modelContext: ModelContext?

    var exercises: [Exercise] = []
    var selectedCategory: ExerciseCategory?
    var searchText: String = ""

    // Sheet state
    var showingAddSheet = false
    var exerciseToEdit: Exercise?

    // MARK: - Initialization

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadExercises()
    }

    // MARK: - Filtered Exercises

    var filteredExercises: [Exercise] {
        var result = exercises

        // Filtre par catégorie
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Filtre par recherche
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { $0.name < $1.name }
    }

    /// Exercices groupés par catégorie
    var exercisesByCategory: [ExerciseCategory: [Exercise]] {
        Dictionary(grouping: filteredExercises) { $0.category }
    }

    // MARK: - CRUD Operations

    func loadExercises() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            exercises = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching exercises: \(error)")
            exercises = []
        }
    }

    func addExercise(
        name: String,
        category: ExerciseCategory,
        muscleGroup: MuscleGroup,
        notes: String?
    ) {
        guard let modelContext else { return }

        let exercise = Exercise(
            name: name,
            category: category,
            muscleGroup: muscleGroup,
            notes: notes?.isEmpty == true ? nil : notes
        )

        modelContext.insert(exercise)
        saveContext()
        loadExercises()

        HapticManager.shared.success()
    }

    func updateExercise(
        _ exercise: Exercise,
        name: String,
        category: ExerciseCategory,
        muscleGroup: MuscleGroup,
        notes: String?
    ) {
        exercise.name = name
        exercise.category = category
        exercise.muscleGroup = muscleGroup
        exercise.notes = notes?.isEmpty == true ? nil : notes

        saveContext()
        loadExercises()

        HapticManager.shared.success()
    }

    func deleteExercise(_ exercise: Exercise) {
        guard let modelContext else { return }

        modelContext.delete(exercise)
        saveContext()
        loadExercises()

        HapticManager.shared.mediumImpact()
    }

    func deleteExercises(at offsets: IndexSet, from exercises: [Exercise]) {
        for index in offsets {
            deleteExercise(exercises[index])
        }
    }

    // MARK: - Helpers

    func exercises(for category: ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.category == category }.sorted { $0.name < $1.name }
    }

    func exercise(withId id: UUID) -> Exercise? {
        exercises.first { $0.id == id }
    }

    // MARK: - Private

    private func saveContext() {
        do {
            try modelContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
