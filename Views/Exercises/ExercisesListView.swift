import SwiftUI
import SwiftData

struct ExercisesListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExercisesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                categoryFilterView

                // Exercise List
                exerciseListView
            }
            .navigationTitle("Exercices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.exerciseToEdit = nil
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                ExerciseFormSheet(
                    viewModel: viewModel,
                    exercise: viewModel.exerciseToEdit
                )
            }
            .searchable(text: $viewModel.searchText, prompt: "Rechercher un exercice")
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All categories button
                FilterChip(
                    title: "Tous",
                    isSelected: viewModel.selectedCategory == nil,
                    color: .appPrimary
                ) {
                    withAnimation {
                        viewModel.selectedCategory = nil
                    }
                    HapticManager.shared.selection()
                }

                // Individual category buttons
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category,
                        color: category.color
                    ) {
                        withAnimation {
                            viewModel.selectedCategory = category
                        }
                        HapticManager.shared.selection()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color.appCardBackground)
    }

    // MARK: - Exercise List

    private var exerciseListView: some View {
        Group {
            if viewModel.filteredExercises.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(ExerciseCategory.allCases, id: \.self) { category in
                        let categoryExercises = viewModel.exercisesByCategory[category] ?? []
                        if !categoryExercises.isEmpty {
                            Section {
                                ForEach(categoryExercises) { exercise in
                                    ExerciseRowView(exercise: exercise)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.exerciseToEdit = exercise
                                            viewModel.showingAddSheet = true
                                            HapticManager.shared.lightImpact()
                                        }
                                }
                                .onDelete { offsets in
                                    viewModel.deleteExercises(at: offsets, from: categoryExercises)
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .foregroundStyle(category.color)
                                    Text(category.displayName)
                                        .foregroundStyle(category.color)
                                }
                                .font(.headline)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "dumbbell.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Aucun exercice")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Créez votre premier exercice\npour commencer à tracker vos performances")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.showingAddSheet = true
            } label: {
                Label("Ajouter un exercice", systemImage: "plus")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.appPrimary)
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Exercise Row View

struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 12) {
            // Category indicator
            Circle()
                .fill(exercise.category.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(exercise.muscleGroup.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Personal best if available
            if let pb = exercise.personalBestWeight {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("PR")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(pb.formattedWeight)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.appPrimary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color.appCardBackground)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExercisesListView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
