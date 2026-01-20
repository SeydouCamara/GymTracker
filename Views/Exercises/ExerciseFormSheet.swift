import SwiftUI

struct ExerciseFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: ExercisesViewModel
    var exercise: Exercise?

    @State private var name: String = ""
    @State private var selectedCategory: ExerciseCategory = .push
    @State private var selectedMuscleGroup: MuscleGroup = .chest
    @State private var notes: String = ""

    var isEditing: Bool {
        exercise != nil
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section {
                    TextField("Nom de l'exercice", text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Nom")
                } footer: {
                    Text("Ex: Bench Press, Squat, Deadlift...")
                }

                // Category Section
                Section("Catégorie") {
                    Picker("Type d'entraînement", selection: $selectedCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    .onChange(of: selectedCategory) { _, newValue in
                        // Auto-select first muscle group for new category
                        let availableGroups = MuscleGroup.groups(for: newValue)
                        if !availableGroups.contains(selectedMuscleGroup),
                           let firstGroup = availableGroups.first {
                            selectedMuscleGroup = firstGroup
                        }
                        HapticManager.shared.selection()
                    }
                }

                // Muscle Group Section
                Section("Groupe musculaire") {
                    let availableGroups = MuscleGroup.groups(for: selectedCategory)

                    Picker("Muscle ciblé", selection: $selectedMuscleGroup) {
                        ForEach(availableGroups, id: \.self) { group in
                            HStack {
                                Image(systemName: group.icon)
                                Text(group.displayName)
                            }
                            .tag(group)
                        }
                    }
                    .onChange(of: selectedMuscleGroup) { _, _ in
                        HapticManager.shared.selection()
                    }
                }

                // Notes Section
                Section {
                    TextField("Notes (optionnel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Ajoutez des notes sur la technique, les variantes, etc.")
                }

                // Delete button for editing
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let exercise = exercise {
                                viewModel.deleteExercise(exercise)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Label("Supprimer l'exercice", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouvel exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Enregistrer" : "Ajouter") {
                        saveExercise()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                loadExerciseData()
            }
        }
    }

    // MARK: - Actions

    private func loadExerciseData() {
        if let exercise = exercise {
            name = exercise.name
            selectedCategory = exercise.category
            selectedMuscleGroup = exercise.muscleGroup
            notes = exercise.notes ?? ""
        }
    }

    private func saveExercise() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exercise = exercise {
            viewModel.updateExercise(
                exercise,
                name: trimmedName,
                category: selectedCategory,
                muscleGroup: selectedMuscleGroup,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
        } else {
            viewModel.addExercise(
                name: trimmedName,
                category: selectedCategory,
                muscleGroup: selectedMuscleGroup,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
        }

        dismiss()
    }
}

#Preview("Add") {
    ExerciseFormSheet(
        viewModel: ExercisesViewModel(),
        exercise: nil
    )
}
