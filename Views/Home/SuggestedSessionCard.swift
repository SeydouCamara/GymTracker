import SwiftUI

struct SuggestedSessionCard: View {
    let sessionType: ExerciseCategory?
    let exerciseCount: Int
    let programName: String?

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.appPrimary)

                        Text("Prochaine séance suggérée")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let name = programName {
                        Text("Basé sur: \(name)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()
            }

            // Session type
            if let sessionType = sessionType {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(sessionType.color.opacity(0.2))
                            .frame(width: 60, height: 60)

                        Image(systemName: sessionType.icon)
                            .font(.title)
                            .foregroundStyle(sessionType.color)
                    }

                    // Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sessionType.displayName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(exerciseCount) exercice\(exerciseCount > 1 ? "s" : "")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                // Muscle groups preview
                HStack(spacing: 8) {
                    ForEach(MuscleGroup.groups(for: sessionType).prefix(3), id: \.self) { muscle in
                        HStack(spacing: 4) {
                            Image(systemName: muscle.icon)
                                .font(.caption2)

                            Text(muscle.displayName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.appCardBackground)
                        )
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                // Start button
                NavigationLink(value: "startWorkout") {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Démarrer la séance")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(sessionType.color)
                    )
                    .foregroundStyle(.white)
                }
            } else {
                // No suggestion available
                VStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("Aucune suggestion")
                        .font(.headline)

                    Text("Crée un programme pour avoir des suggestions automatiques")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: sessionType != nil
                            ? [sessionType!.color.opacity(0.5), sessionType!.color.opacity(0.1)]
                            : [Color.secondary.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview("With Session") {
    VStack {
        SuggestedSessionCard(
            sessionType: .push,
            exerciseCount: 5,
            programName: "PPL"
        )

        SuggestedSessionCard(
            sessionType: .pull,
            exerciseCount: 4,
            programName: nil
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("No Session") {
    SuggestedSessionCard(
        sessionType: nil,
        exerciseCount: 0,
        programName: nil
    )
    .padding()
    .background(Color.appBackground)
}
