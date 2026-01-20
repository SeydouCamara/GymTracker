import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    @State private var selectedWorkout: Workout?
    @State private var showingProgressView = false

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    emptyStateView
                } else {
                    workoutListView
                }
            }
            .navigationTitle("Historique")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingProgressView = true
                    } label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                    .disabled(workouts.isEmpty)
                }
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
            .sheet(isPresented: $showingProgressView) {
                ProgressView()
            }
        }
    }

    // MARK: - Workout List

    private var workoutListView: some View {
        List {
            ForEach(groupedWorkouts, id: \.key) { monthYear, monthWorkouts in
                Section {
                    ForEach(monthWorkouts) { workout in
                        WorkoutHistoryRow(workout: workout)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedWorkout = workout
                                HapticManager.shared.lightImpact()
                            }
                    }
                } header: {
                    Text(monthYear)
                        .font(.headline)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Grouped Workouts

    private var groupedWorkouts: [(key: String, value: [Workout])] {
        let completed = workouts.filter { $0.isCompleted }

        let grouped = Dictionary(grouping: completed) { workout -> String in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: workout.date).capitalized
        }

        return grouped.sorted { $0.value.first?.date ?? Date() > $1.value.first?.date ?? Date() }
            .map { (key: $0.key, value: $0.value) }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "clock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Aucune séance")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Ton historique d'entraînement\napparaîtra ici")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Workout History Row

struct WorkoutHistoryRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            // Session type indicator
            ZStack {
                Circle()
                    .fill(workout.sessionType.color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: workout.sessionType.icon)
                    .foregroundStyle(workout.sessionType.color)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workout.sessionType.displayName)
                        .font(.headline)

                    Spacer()

                    Text(workout.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Label(workout.durationFormatted, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label("\(workout.totalSets) séries", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label(workout.totalVolumeFormatted, systemImage: "scalemass")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Workout.self, inMemory: true)
}
