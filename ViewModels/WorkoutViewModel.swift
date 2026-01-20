import Foundation
import SwiftData
import SwiftUI

@Observable
class WorkoutViewModel {
    var modelContext: ModelContext?

    // Current workout state
    var currentWorkout: Workout?
    var isWorkoutActive: Bool = false

    // UI State
    var selectedExerciseIndex: Int = 0
    var showingExercisePicker = false
    var showingWeightRepsPicker = false
    var selectedSet: ExerciseSet?

    // Weight/Reps picker state
    var pickerWeight: Double = 20.0
    var pickerReps: Int = 10

    // Available exercises
    var availableExercises: [Exercise] = []

    // Timer
    var timerManager = TimerManager.shared

    // MARK: - Initialization

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAvailableExercises()
        loadActiveWorkout()
    }

    // MARK: - Load

    func loadAvailableExercises() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            availableExercises = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching exercises: \(error)")
            availableExercises = []
        }
    }

    func loadActiveWorkout() {
        guard let modelContext else { return }

        // Find any incomplete workout from today
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let predicate = #Predicate<Workout> { workout in
            workout.date >= today && workout.date < tomorrow && !workout.isCompleted
        }

        let descriptor = FetchDescriptor<Workout>(predicate: predicate)

        do {
            if let activeWorkout = try modelContext.fetch(descriptor).first {
                currentWorkout = activeWorkout
                isWorkoutActive = true
            }
        } catch {
            print("Error fetching active workout: \(error)")
        }
    }

    // MARK: - Computed Properties

    var currentExercise: WorkoutExercise? {
        guard let workout = currentWorkout,
              selectedExerciseIndex < workout.sortedExercises.count else {
            return nil
        }
        return workout.sortedExercises[selectedExerciseIndex]
    }

    var workoutProgress: Double {
        guard let workout = currentWorkout else { return 0 }
        let totalSets = workout.exercises.reduce(0) { $0 + $1.totalSetsCount }
        let completedSets = workout.exercises.reduce(0) { $0 + $1.completedSetsCount }
        guard totalSets > 0 else { return 0 }
        return Double(completedSets) / Double(totalSets)
    }

    var exercises: [Exercise] {
        guard let workout = currentWorkout else { return [] }
        return availableExercises.filter { exercise in
            exercise.category == workout.sessionType
        }
    }

    // MARK: - Workout Lifecycle

    func startWorkout(sessionType: ExerciseCategory) {
        guard let modelContext else { return }

        let workout = Workout(sessionType: sessionType)
        modelContext.insert(workout)

        // Add exercises of this category to the workout
        let categoryExercises = availableExercises.filter { $0.category == sessionType }
        for exercise in categoryExercises {
            // Get last performance for "Last time" display
            let lastPerformance = exercise.lastPerformance
            let workoutExercise = workout.addExercise(
                exercise,
                lastWeight: lastPerformance?.maxWeight,
                lastReps: lastPerformance?.maxReps
            )

            // Add default sets
            workoutExercise.addSets(count: AppConstants.defaultSetsPerExercise)
        }

        currentWorkout = workout
        isWorkoutActive = true
        selectedExerciseIndex = 0

        saveContext()
        HapticManager.shared.success()
    }

    func completeWorkout() {
        guard let workout = currentWorkout else { return }

        workout.complete()

        // Save performance records for each exercise
        for workoutExercise in workout.exercises {
            savePerformanceRecord(for: workoutExercise)
        }

        // Advance program to next session
        advanceProgram()

        saveContext()

        currentWorkout = nil
        isWorkoutActive = false
        selectedExerciseIndex = 0

        timerManager.stop()
        HapticManager.shared.workoutComplete()
    }

    func cancelWorkout() {
        guard let workout = currentWorkout, let modelContext else { return }

        modelContext.delete(workout)
        saveContext()

        currentWorkout = nil
        isWorkoutActive = false
        selectedExerciseIndex = 0

        timerManager.stop()
        HapticManager.shared.warning()
    }

    // MARK: - Exercise Management

    func addExercise(_ exercise: Exercise) {
        guard let workout = currentWorkout else { return }

        let lastPerformance = exercise.lastPerformance
        let workoutExercise = workout.addExercise(
            exercise,
            lastWeight: lastPerformance?.maxWeight,
            lastReps: lastPerformance?.maxReps
        )

        workoutExercise.addSets(count: AppConstants.defaultSetsPerExercise)

        saveContext()
        HapticManager.shared.success()
    }

    func removeExercise(_ workoutExercise: WorkoutExercise) {
        guard let workout = currentWorkout else { return }

        workout.exercises.removeAll { $0.id == workoutExercise.id }

        // Adjust selected index if needed
        if selectedExerciseIndex >= workout.exercises.count {
            selectedExerciseIndex = max(0, workout.exercises.count - 1)
        }

        saveContext()
        HapticManager.shared.mediumImpact()
    }

    // MARK: - Set Management

    func addSet(to workoutExercise: WorkoutExercise, isWarmup: Bool = false) {
        _ = workoutExercise.addSet(isWarmup: isWarmup)
        saveContext()
        HapticManager.shared.lightImpact()
    }

    func removeSet(_ set: ExerciseSet, from workoutExercise: WorkoutExercise) {
        workoutExercise.removeSet(set)
        saveContext()
        HapticManager.shared.lightImpact()
    }

    func openSetEditor(for set: ExerciseSet) {
        selectedSet = set
        pickerWeight = set.weight ?? currentExercise?.lastWeight ?? 20.0
        pickerReps = set.reps ?? currentExercise?.lastReps ?? 10
        showingWeightRepsPicker = true
    }

    func completeSet() {
        guard let set = selectedSet else { return }

        set.complete(weight: pickerWeight, reps: pickerReps)
        saveContext()

        showingWeightRepsPicker = false
        selectedSet = nil

        // Start rest timer
        timerManager.start(duration: .ninety)

        HapticManager.shared.setComplete()
    }

    func toggleSet(_ set: ExerciseSet) {
        if set.isCompleted {
            set.uncomplete()
            HapticManager.shared.lightImpact()
        } else {
            openSetEditor(for: set)
        }
        saveContext()
    }

    // MARK: - Performance Records

    private func savePerformanceRecord(for workoutExercise: WorkoutExercise) {
        guard let exercise = workoutExercise.exercise,
              let record = PerformanceRecord.from(workoutExercise: workoutExercise) else {
            return
        }

        record.exercise = exercise
        exercise.performanceRecords.append(record)
    }

    // MARK: - Program Integration

    private func advanceProgram() {
        guard let modelContext else { return }

        let predicate = #Predicate<Program> { program in
            program.isActive == true
        }

        let descriptor = FetchDescriptor<Program>(predicate: predicate)

        do {
            if let activeProgram = try modelContext.fetch(descriptor).first {
                activeProgram.advanceToNextSession()
            }
        } catch {
            print("Error advancing program: \(error)")
        }
    }

    // MARK: - Navigation

    func selectExercise(at index: Int) {
        guard let workout = currentWorkout,
              index >= 0 && index < workout.exercises.count else {
            return
        }
        selectedExerciseIndex = index
        HapticManager.shared.selection()
    }

    func nextExercise() {
        guard let workout = currentWorkout else { return }
        if selectedExerciseIndex < workout.exercises.count - 1 {
            selectedExerciseIndex += 1
            HapticManager.shared.selection()
        }
    }

    func previousExercise() {
        if selectedExerciseIndex > 0 {
            selectedExerciseIndex -= 1
            HapticManager.shared.selection()
        }
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
