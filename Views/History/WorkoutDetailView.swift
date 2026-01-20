import SwiftUI

struct WorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let workout: Workout

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header card
                    headerCard

                    // Stats summary
                    statsSummary

                    // Exercises list
                    exercisesList

                    // Notes if any
                    if let notes = workout.notes, !notes.isEmpty {
                        notesCard(notes)
                    }
                }
                .padding()
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(workout.sessionType.color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: workout.sessionType.icon)
                        .font(.title)
                        .foregroundStyle(workout.sessionType.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.sessionType.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(workout.formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider()

            HStack {
                VStack(spacing: 2) {
                    Text(workout.startTimeFormatted)
                        .font(.headline)
                    Text("Début")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 2) {
                    Text(workout.durationFormatted)
                        .font(.headline)
                    Text("Durée")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 2) {
                    if let endTime = workout.endTime {
                        Text(endTime.formattedTime)
                            .font(.headline)
                    } else {
                        Text("—")
                            .font(.headline)
                    }
                    Text("Fin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }

    // MARK: - Stats Summary

    private var statsSummary: some View {
        HStack(spacing: 0) {
            StatSummaryItem(
                value: "\(workout.exercisesCount)",
                label: "Exercices",
                color: .appPrimary
            )

            Divider()
                .frame(height: 40)

            StatSummaryItem(
                value: "\(workout.totalSets)",
                label: "Séries",
                color: .appSecondary
            )

            Divider()
                .frame(height: 40)

            StatSummaryItem(
                value: workout.totalVolumeFormatted,
                label: "Volume",
                color: .appSuccess
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }

    // MARK: - Exercises List

    private var exercisesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercices")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(workout.sortedExercises) { workoutExercise in
                ExerciseDetailCard(workoutExercise: workoutExercise)
            }
        }
    }

    // MARK: - Notes Card

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(.secondary)
                Text("Notes")
                    .font(.headline)
            }

            Text(notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Stat Summary Item

struct StatSummaryItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Exercise Detail Card

struct ExerciseDetailCard: View {
    let workoutExercise: WorkoutExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(workoutExercise.exercise?.name ?? "Exercice")
                    .font(.headline)

                Spacer()

                if workoutExercise.isFullyCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.appSuccess)
                }

                Text(workoutExercise.setsProgress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Sets
            VStack(spacing: 6) {
                ForEach(workoutExercise.sortedSets.filter { $0.isCompleted }) { set in
                    HStack {
                        Text(set.isWarmup ? "Échauffement" : "Série \(set.setNumber)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .leading)

                        Spacer()

                        if let weight = set.weight {
                            Text(weight.formattedWeight)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Text("×")
                            .foregroundStyle(.secondary)

                        if let reps = set.reps {
                            Text("\(reps) reps")
                                .font(.subheadline)
                        }

                        Spacer()

                        Text(set.volume.formattedVolume)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Volume summary
            if workoutExercise.completedSetsCount > 0 {
                Divider()

                HStack {
                    Text("Volume total")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(workoutExercise.totalVolume.formattedVolume)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.appPrimary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appCardBackground)
        )
    }
}

#Preview {
    WorkoutDetailView(workout: Workout(sessionType: .push))
}
