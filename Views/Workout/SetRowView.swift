import SwiftUI

struct SetRowView: View {
    let set: ExerciseSet
    let lastWeight: Double?
    let lastReps: Int?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Set number/type indicator
                setIndicator

                // Weight & Reps
                weightRepsView

                Spacer()

                // Last time reference
                if !set.isCompleted, let lastWeight = lastWeight, let lastReps = lastReps {
                    Text("Last: \(Int(lastWeight))kg x \(lastReps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Completion checkbox
                completionCheckbox
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(set.isCompleted ? Color.appSuccess.opacity(0.1) : Color.appCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        set.isCompleted ? Color.appSuccess.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Set Indicator

    private var setIndicator: some View {
        ZStack {
            Circle()
                .fill(set.isWarmup ? Color.orange.opacity(0.2) : Color.appPrimary.opacity(0.2))
                .frame(width: 32, height: 32)

            Text(set.shortLabel)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(set.isWarmup ? .orange : .appPrimary)
        }
    }

    // MARK: - Weight & Reps View

    private var weightRepsView: some View {
        HStack(spacing: 8) {
            // Weight
            HStack(spacing: 4) {
                Image(systemName: "scalemass.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let weight = set.weight {
                    Text(weight.formattedWeight)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                } else {
                    Text("—")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 70, alignment: .leading)

            Text("×")
                .foregroundStyle(.secondary)

            // Reps
            HStack(spacing: 4) {
                if let reps = set.reps {
                    Text("\(reps)")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("— reps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Completion Checkbox

    private var completionCheckbox: some View {
        ZStack {
            Circle()
                .strokeBorder(set.isCompleted ? Color.appSuccess : Color.secondary.opacity(0.3), lineWidth: 2)
                .frame(width: 28, height: 28)

            if set.isCompleted {
                Circle()
                    .fill(Color.appSuccess)
                    .frame(width: 28, height: 28)

                Image(systemName: "checkmark")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SetRowView(
            set: {
                let set = ExerciseSet(setNumber: 1)
                set.complete(weight: 80, reps: 10)
                return set
            }(),
            lastWeight: 80,
            lastReps: 10,
            onTap: {}
        )

        SetRowView(
            set: ExerciseSet(setNumber: 2),
            lastWeight: 80,
            lastReps: 10,
            onTap: {}
        )

        SetRowView(
            set: ExerciseSet(setNumber: 1, isWarmup: true),
            lastWeight: nil,
            lastReps: nil,
            onTap: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}
