import SwiftUI

struct ProgramFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: ProgramsViewModel
    var program: Program?

    @State private var name: String = ""
    @State private var sessionOrder: [ExerciseCategory] = []
    @State private var showingCategoryPicker = false

    var isEditing: Bool {
        program != nil
    }

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !sessionOrder.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section {
                    TextField("Nom du programme", text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Nom")
                } footer: {
                    Text("Ex: PPL, Full Body, Upper/Lower...")
                }

                // Session Order Section
                Section {
                    if sessionOrder.isEmpty {
                        Button {
                            showingCategoryPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.appPrimary)
                                Text("Ajouter une séance")
                                    .foregroundStyle(.primary)
                            }
                        }
                    } else {
                        ForEach(Array(sessionOrder.enumerated()), id: \.offset) { index, category in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)

                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)

                                Text(category.displayName)
                                    .fontWeight(.medium)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .onMove(perform: moveSession)
                        .onDelete(perform: deleteSession)

                        Button {
                            showingCategoryPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.appPrimary)
                                Text("Ajouter une séance")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Ordre des séances")
                        Spacer()
                        if !sessionOrder.isEmpty {
                            EditButton()
                                .font(.caption)
                        }
                    }
                } footer: {
                    if sessionOrder.isEmpty {
                        Text("Définissez l'ordre des types de séances dans votre programme")
                    } else {
                        Text("Glissez pour réorganiser, balayez pour supprimer")
                    }
                }

                // Preview Section
                if !sessionOrder.isEmpty {
                    Section("Aperçu du cycle") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(sessionOrder.enumerated()), id: \.offset) { index, category in
                                    HStack(spacing: 4) {
                                        if index > 0 {
                                            Image(systemName: "arrow.right")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }

                                        Text(category.displayName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(category.color.opacity(0.2))
                                            )
                                            .foregroundStyle(category.color)
                                    }
                                }

                                // Loop indicator
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Quick Add Templates
                if sessionOrder.isEmpty {
                    Section("Modèles populaires") {
                        Button {
                            sessionOrder = [.push, .pull, .legs]
                            name = "PPL"
                            HapticManager.shared.success()
                        } label: {
                            HStack {
                                Text("PPL")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("Push → Pull → Legs")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)

                        Button {
                            sessionOrder = [.push, .pull, .legs, .jjb]
                            name = "PPL + JJB"
                            HapticManager.shared.success()
                        } label: {
                            HStack {
                                Text("PPL + JJB")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("Push → Pull → Legs → JJB")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)

                        Button {
                            sessionOrder = [.push, .pull, .legs, .jjb, .mobilite]
                            name = "Programme complet"
                            HapticManager.shared.success()
                        } label: {
                            HStack {
                                Text("Programme complet")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("PPL + JJB + Mobilité")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.primary)
                    }
                }

                // Delete button for editing
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let program = program {
                                viewModel.deleteProgram(program)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Label("Supprimer le programme", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouveau programme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Enregistrer" : "Créer") {
                        saveProgram()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerSheet(selectedCategories: $sessionOrder)
            }
            .onAppear {
                loadProgramData()
            }
        }
    }

    // MARK: - Actions

    private func loadProgramData() {
        if let program = program {
            name = program.name
            sessionOrder = program.sessionOrder
        }
    }

    private func saveProgram() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let program = program {
            viewModel.updateProgram(
                program,
                name: trimmedName,
                sessionOrder: sessionOrder
            )
        } else {
            viewModel.addProgram(
                name: trimmedName,
                sessionOrder: sessionOrder
            )
        }

        dismiss()
    }

    private func moveSession(from source: IndexSet, to destination: Int) {
        sessionOrder.move(fromOffsets: source, toOffset: destination)
        HapticManager.shared.lightImpact()
    }

    private func deleteSession(at offsets: IndexSet) {
        sessionOrder.remove(atOffsets: offsets)
        HapticManager.shared.lightImpact()
    }
}

// MARK: - Category Picker Sheet

struct CategoryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategories: [ExerciseCategory]

    var body: some View {
        NavigationStack {
            List {
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategories.append(category)
                        HapticManager.shared.mediumImpact()
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundStyle(category.color)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(categoryDescription(category))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Ajouter une séance")
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

    private func categoryDescription(_ category: ExerciseCategory) -> String {
        switch category {
        case .push: return "Pectoraux, Épaules, Triceps"
        case .pull: return "Dos, Biceps"
        case .legs: return "Quadriceps, Ischio-jambiers, Fessiers"
        case .jjb: return "Jiu-Jitsu Brésilien"
        case .mobilite: return "Étirements et mobilité"
        }
    }
}

#Preview("Add") {
    ProgramFormSheet(
        viewModel: ProgramsViewModel(),
        program: nil
    )
}
