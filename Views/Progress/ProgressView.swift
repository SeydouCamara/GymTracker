import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    @State private var selectedExercise: Exercise?
    @State private var selectedMetric: ProgressMetric = .maxWeight
    @State private var selectedTimeRange: TimeRange = .month

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall stats
                    overallStatsSection

                    // Exercise selector
                    exerciseSelector

                    // Chart
                    if let exercise = selectedExercise {
                        progressChart(for: exercise)
                    }

                    // Personal records
                    if let exercise = selectedExercise {
                        personalRecordsSection(for: exercise)
                    }
                }
                .padding()
            }
            .navigationTitle("Progression")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
            }
        }
    }

    // MARK: - Overall Stats

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vue d'ensemble")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                OverviewStatCard(
                    value: "\(completedWorkouts.count)",
                    label: "Séances totales",
                    icon: "dumbbell.fill"
                )

                OverviewStatCard(
                    value: "\(exercises.count)",
                    label: "Exercices",
                    icon: "list.bullet"
                )

                OverviewStatCard(
                    value: totalVolumeAllTime,
                    label: "Volume total",
                    icon: "scalemass.fill"
                )
            }
        }
    }

    private var completedWorkouts: [Workout] {
        workouts.filter { $0.isCompleted }
    }

    private var totalVolumeAllTime: String {
        let total = completedWorkouts.reduce(0.0) { $0 + $1.totalVolume }
        if total > 1_000_000 {
            return String(format: "%.1fM kg", total / 1_000_000)
        } else if total > 1000 {
            return String(format: "%.0fk kg", total / 1000)
        }
        return "\(Int(total)) kg"
    }

    // MARK: - Exercise Selector

    private var exerciseSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sélectionner un exercice")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(exercises) { exercise in
                        Button {
                            selectedExercise = exercise
                            HapticManager.shared.selection()
                        } label: {
                            Text(exercise.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedExercise?.id == exercise.id
                                              ? exercise.category.color
                                              : Color.appCardBackground)
                                )
                                .foregroundStyle(selectedExercise?.id == exercise.id
                                                 ? .white
                                                 : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Progress Chart

    private func progressChart(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progression")
                    .font(.headline)

                Spacer()

                Picker("Métrique", selection: $selectedMetric) {
                    ForEach(ProgressMetric.allCases, id: \.self) { metric in
                        Text(metric.displayName).tag(metric)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
            }

            let records = exercise.performanceRecords.sorted { $0.date < $1.date }

            if records.count >= 2 {
                Chart {
                    ForEach(records) { record in
                        LineMark(
                            x: .value("Date", record.date),
                            y: .value(selectedMetric.displayName, metricValue(for: record))
                        )
                        .foregroundStyle(exercise.category.color)

                        PointMark(
                            x: .value("Date", record.date),
                            y: .value(selectedMetric.displayName, metricValue(for: record))
                        )
                        .foregroundStyle(exercise.category.color)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                        .fill(Color.appCardBackground)
                )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("Pas assez de données")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Effectue au moins 2 séances pour voir ta progression")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                        .fill(Color.appCardBackground)
                )
            }
        }
    }

    private func metricValue(for record: PerformanceRecord) -> Double {
        switch selectedMetric {
        case .maxWeight:
            return record.maxWeight
        case .volume:
            return record.totalVolume
        case .sets:
            return Double(record.totalSets)
        }
    }

    // MARK: - Personal Records Section

    private func personalRecordsSection(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Records personnels")
                .font(.headline)

            if let pb = exercise.personalBestWeight,
               let lastRecord = exercise.lastPerformance {
                HStack(spacing: 16) {
                    // Max weight
                    PRCard(
                        title: "Poids max",
                        value: pb.formattedWeight,
                        icon: "trophy.fill",
                        color: .yellow
                    )

                    // Best set
                    PRCard(
                        title: "Meilleur set",
                        value: lastRecord.bestSetText,
                        icon: "star.fill",
                        color: .appPrimary
                    )
                }

                // Progression percentage
                if let progressPercentage = SuggestionEngine.shared.progressionPercentage(for: exercise) {
                    HStack {
                        Image(systemName: progressPercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundStyle(progressPercentage >= 0 ? .appSuccess : .appError)

                        Text(String(format: "%.1f%% depuis le début", abs(progressPercentage)))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appCardBackground)
                    )
                }
            } else {
                Text("Aucun record pour cet exercice")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appCardBackground)
                    )
            }
        }
    }
}

// MARK: - Supporting Types

enum ProgressMetric: String, CaseIterable {
    case maxWeight
    case volume
    case sets

    var displayName: String {
        switch self {
        case .maxWeight: return "Poids"
        case .volume: return "Volume"
        case .sets: return "Séries"
        }
    }
}

enum TimeRange: String, CaseIterable {
    case week
    case month
    case threeMonths
    case year
    case all

    var displayName: String {
        switch self {
        case .week: return "7j"
        case .month: return "1m"
        case .threeMonths: return "3m"
        case .year: return "1an"
        case .all: return "Tout"
        }
    }
}

// MARK: - Overview Stat Card

struct OverviewStatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.appPrimary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appCardBackground)
        )
    }
}

// MARK: - PR Card

struct PRCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appCardBackground)
        )
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: [Exercise.self, Workout.self], inMemory: true)
}
