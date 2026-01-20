import SwiftUI

struct ExerciseCardView: View {
    let workoutExercise: WorkoutExercise
    let isSelected: Bool
    var viewModel: WorkoutViewModel

    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Sets (when expanded)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(workoutExercise.sortedSets) { set in
                        SetRowView(
                            set: set,
                            lastWeight: workoutExercise.lastWeight,
                            lastReps: workoutExercise.lastReps,
                            onTap: {
                                viewModel.toggleSet(set)
                            }
                        )
                    }

                    // Add set button
                    HStack(spacing: 16) {
                        Button {
                            viewModel.addSet(to: workoutExercise)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Série")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.appPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.appPrimary.opacity(0.15))
                            )
                        }

                        Button {
                            viewModel.addSet(to: workoutExercise, isWarmup: true)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Échauffement")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.secondary.opacity(0.15))
                            )
                        }

                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.appBackground)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .strokeBorder(
                    isSelected ? Color.appPrimary : Color.clear,
                    lineWidth: 2
                )
        )
        .padding(.horizontal)
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutExercise.exercise?.name ?? "Exercice")
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(workoutExercise.exercise?.muscleGroup.displayName ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let lastTime = workoutExercise.lastTimeText {
                        Text("•")
                            .foregroundStyle(.secondary)

                        Text("Last: \(lastTime)")
                            .font(.caption)
                            .foregroundStyle(.appPrimary)
                    }
                }
            }

            Spacer()

            // Progress indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text(workoutExercise.setsProgress)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if workoutExercise.isFullyCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.appSuccess)
                }
            }

            // Expand/collapse button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticManager.shared.lightImpact()
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        ExerciseCardView(
            workoutExercise: WorkoutExercise(order: 0, lastWeight: 80, lastReps: 10),
            isSelected: true,
            viewModel: WorkoutViewModel()
        )

        ExerciseCardView(
            workoutExercise: WorkoutExercise(order: 1),
            isSelected: false,
            viewModel: WorkoutViewModel()
        )
    }
    .padding(.vertical)
    .background(Color.appBackground)
}
