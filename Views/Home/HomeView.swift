import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    welcomeHeader

                    // Suggested session card
                    if viewModel.hasExercises {
                        SuggestedSessionCard(
                            sessionType: viewModel.suggestedSession,
                            exerciseCount: viewModel.exercisesForSuggestedSession,
                            programName: viewModel.activeProgram?.name
                        )
                    } else {
                        noExercisesCard
                    }

                    // Quick stats
                    statsGridView

                    // Last workout summary
                    if let lastWorkout = viewModel.lastWorkout {
                        lastWorkoutCard(lastWorkout)
                    }

                    // Program status
                    if let program = viewModel.activeProgram {
                        programStatusCard(program)
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .refreshable {
                viewModel.refresh()
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingMessage)
                    .font(.title2)
                    .fontWeight(.bold)

                if let days = viewModel.daysSinceLastWorkout {
                    Text(daysMessage(days))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Streak badge
            if viewModel.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(viewModel.currentStreak)")
                        .fontWeight(.bold)
                }
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
            }
        }
    }

    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bonjour 👋"
        case 12..<18: return "Bon après-midi 💪"
        case 18..<22: return "Bonsoir 🌙"
        default: return "Bonne nuit 😴"
        }
    }

    private func daysMessage(_ days: Int) -> String {
        switch days {
        case 0: return "Tu t'es entraîné aujourd'hui !"
        case 1: return "Dernier entraînement: hier"
        default: return "Dernier entraînement: il y a \(days) jours"
        }
    }

    // MARK: - No Exercises Card

    private var noExercisesCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            VStack(spacing: 4) {
                Text("Commence par créer des exercices")
                    .font(.headline)

                Text("Va dans l'onglet Exercices pour ajouter tes premiers exercices")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }

    // MARK: - Stats Grid

    private var statsGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Cette semaine",
                value: "\(viewModel.workoutsThisWeek)",
                unit: "séances",
                icon: "calendar",
                color: .appPrimary
            )

            StatCard(
                title: "Volume",
                value: viewModel.volumeThisWeek > 1000
                    ? String(format: "%.1fk", viewModel.volumeThisWeek / 1000)
                    : "\(Int(viewModel.volumeThisWeek))",
                unit: "kg",
                icon: "scalemass.fill",
                color: .appSecondary
            )

            StatCard(
                title: "Séries",
                value: "\(viewModel.setsThisWeek)",
                unit: "total",
                icon: "checkmark.circle.fill",
                color: .appSuccess
            )

            StatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                unit: "jours",
                icon: "flame.fill",
                color: .orange
            )
        }
    }

    // MARK: - Last Workout Card

    private func lastWorkoutCard(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Dernière séance")
                    .font(.headline)

                Spacer()

                Text(workout.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: workout.sessionType.icon)
                        .foregroundStyle(workout.sessionType.color)

                    Text(workout.sessionType.displayName)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(workout.durationFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("\(workout.totalSets) séries • \(workout.totalVolumeFormatted)")
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

    // MARK: - Program Status Card

    private func programStatusCard(_ program: Program) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Programme actif")
                    .font(.headline)

                Spacer()

                Text(program.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.appPrimary)
            }

            // Session order visualization
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(program.sessionOrder.enumerated()), id: \.offset) { index, category in
                        let isNext = index == program.currentSessionIndex

                        HStack(spacing: 4) {
                            if index > 0 {
                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Text(category.displayName)
                                .font(.caption)
                                .fontWeight(isNext ? .bold : .medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isNext ? category.color : category.color.opacity(0.2))
                                )
                                .foregroundStyle(isNext ? .white : category.color)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(Color.appCardBackground)
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Exercise.self, Program.self, Workout.self], inMemory: true)
}
