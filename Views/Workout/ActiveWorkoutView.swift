import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WorkoutViewModel()
    @State private var showingStartSheet = false
    @State private var showingCancelAlert = false
    @State private var showingCompleteAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isWorkoutActive {
                    activeWorkoutContent
                } else {
                    noWorkoutView
                }
            }
            .navigationTitle(viewModel.isWorkoutActive ? "Workout" : "Démarrer")
            .toolbar {
                if viewModel.isWorkoutActive {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            showingCancelAlert = true
                        }
                        .foregroundStyle(.red)
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Button("Terminer") {
                            showingCompleteAlert = true
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.appSuccess)
                    }
                }
            }
            .sheet(isPresented: $showingStartSheet) {
                StartWorkoutSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingWeightRepsPicker) {
                WeightRepsPicker(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingExercisePicker) {
                ExercisePickerSheet(viewModel: viewModel)
            }
            .alert("Annuler la séance ?", isPresented: $showingCancelAlert) {
                Button("Continuer", role: .cancel) {}
                Button("Annuler la séance", role: .destructive) {
                    viewModel.cancelWorkout()
                }
            } message: {
                Text("Toutes les données de cette séance seront perdues.")
            }
            .alert("Terminer la séance ?", isPresented: $showingCompleteAlert) {
                Button("Continuer", role: .cancel) {}
                Button("Terminer", role: .none) {
                    viewModel.completeWorkout()
                }
            } message: {
                Text("La séance sera enregistrée dans l'historique.")
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    // MARK: - Active Workout Content

    private var activeWorkoutContent: some View {
        VStack(spacing: 0) {
            // Header with session info
            workoutHeaderView

            // Rest Timer (if running)
            if viewModel.timerManager.isRunning || viewModel.timerManager.isComplete {
                RestTimerView(timerManager: viewModel.timerManager)
                    .padding(.horizontal)
                    .padding(.top, 12)
            }

            // Exercises List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array((viewModel.currentWorkout?.sortedExercises ?? []).enumerated()), id: \.element.id) { index, workoutExercise in
                        ExerciseCardView(
                            workoutExercise: workoutExercise,
                            isSelected: index == viewModel.selectedExerciseIndex,
                            viewModel: viewModel
                        )
                        .onTapGesture {
                            viewModel.selectExercise(at: index)
                        }
                    }

                    // Add exercise button
                    Button {
                        viewModel.showingExercisePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Ajouter un exercice")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.appPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                                .fill(Color.appCardBackground)
                                .strokeBorder(Color.appPrimary.opacity(0.3), lineWidth: 1, antialiased: true)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }

    // MARK: - Workout Header

    private var workoutHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                // Session type
                HStack(spacing: 8) {
                    Image(systemName: viewModel.currentWorkout?.sessionType.icon ?? "dumbbell.fill")
                        .foregroundStyle(viewModel.currentWorkout?.sessionType.color ?? .appPrimary)

                    Text(viewModel.currentWorkout?.sessionType.displayName ?? "Workout")
                        .font(.headline)
                }

                Spacer()

                // Duration
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.secondary)
                    Text(viewModel.currentWorkout?.durationFormatted ?? "0min")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appCardBackground)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appPrimary)
                        .frame(width: geometry.size.width * viewModel.workoutProgress, height: 8)
                }
            }
            .frame(height: 8)

            // Stats
            HStack {
                StatItem(
                    value: "\(viewModel.currentWorkout?.totalSets ?? 0)",
                    label: "Sets"
                )

                Spacer()

                StatItem(
                    value: viewModel.currentWorkout?.totalVolumeFormatted ?? "0 kg",
                    label: "Volume"
                )

                Spacer()

                StatItem(
                    value: "\(viewModel.currentWorkout?.exercisesCount ?? 0)",
                    label: "Exercices"
                )
            }
        }
        .padding()
        .background(Color.appCardBackground)
    }

    // MARK: - No Workout View

    private var noWorkoutView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "dumbbell.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Prêt à t'entraîner ?")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Démarre une nouvelle séance\npour tracker tes performances")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingStartSheet = true
            } label: {
                Label("Démarrer une séance", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.appPrimary)
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Start Workout Sheet

struct StartWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: WorkoutViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    let exerciseCount = viewModel.availableExercises.filter { $0.category == category }.count

                    Button {
                        viewModel.startWorkout(sessionType: category)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundStyle(category.color)
                                .frame(width: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text("\(exerciseCount) exercice\(exerciseCount > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(exerciseCount == 0)
                    .opacity(exerciseCount == 0 ? 0.5 : 1)
                }
            }
            .navigationTitle("Choisir une séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Exercise Picker Sheet

struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: WorkoutViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.exercises) { exercise in
                    let isAlreadyAdded = viewModel.currentWorkout?.exercises.contains { $0.exercise?.id == exercise.id } ?? false

                    Button {
                        if !isAlreadyAdded {
                            viewModel.addExercise(exercise)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.name)
                                    .foregroundStyle(isAlreadyAdded ? .secondary : .primary)

                                Text(exercise.muscleGroup.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isAlreadyAdded {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.appSuccess)
                            }
                        }
                    }
                    .disabled(isAlreadyAdded)
                }
            }
            .navigationTitle("Ajouter un exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ActiveWorkoutView()
        .modelContainer(for: [Exercise.self, Workout.self], inMemory: true)
}
