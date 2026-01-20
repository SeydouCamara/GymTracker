import SwiftUI

struct WeightRepsPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: WorkoutViewModel

    private let weightRange = stride(from: 0.0, through: 300.0, by: 2.5).map { $0 }
    private let repsRange = Array(1...30)

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Current set info
                if let set = viewModel.selectedSet {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(set.isWarmup ? Color.orange.opacity(0.2) : Color.appPrimary.opacity(0.2))
                                .frame(width: 40, height: 40)

                            Text(set.shortLabel)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(set.isWarmup ? .orange : .appPrimary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(set.isWarmup ? "Échauffement" : "Série \(set.setNumber)")
                                .font(.headline)

                            if let exerciseName = viewModel.currentExercise?.exercise?.name {
                                Text(exerciseName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        // Last time reference
                        if let lastWeight = viewModel.currentExercise?.lastWeight,
                           let lastReps = viewModel.currentExercise?.lastReps {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Dernière fois")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text("\(Int(lastWeight))kg × \(lastReps)")
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
                    .padding(.horizontal)
                }

                // Pickers
                HStack(spacing: 0) {
                    // Weight Picker
                    VStack(spacing: 8) {
                        Text("Poids")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Picker("Poids", selection: $viewModel.pickerWeight) {
                            ForEach(weightRange, id: \.self) { weight in
                                Text(weight.formattedWeight)
                                    .tag(weight)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(maxWidth: .infinity)

                    // Divider
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 1)
                        .padding(.vertical, 40)

                    // Reps Picker
                    VStack(spacing: 8) {
                        Text("Répétitions")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Picker("Reps", selection: $viewModel.pickerReps) {
                            ForEach(repsRange, id: \.self) { reps in
                                Text("\(reps)")
                                    .tag(reps)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(Color.appCardBackground)
                .cornerRadius(16)
                .padding(.horizontal)

                // Quick adjustments
                HStack(spacing: 16) {
                    // Weight quick adjust
                    HStack(spacing: 8) {
                        QuickAdjustButton(label: "-5") {
                            viewModel.pickerWeight = max(0, viewModel.pickerWeight - 5)
                        }

                        QuickAdjustButton(label: "-2.5") {
                            viewModel.pickerWeight = max(0, viewModel.pickerWeight - 2.5)
                        }

                        QuickAdjustButton(label: "+2.5") {
                            viewModel.pickerWeight = min(300, viewModel.pickerWeight + 2.5)
                        }

                        QuickAdjustButton(label: "+5") {
                            viewModel.pickerWeight = min(300, viewModel.pickerWeight + 5)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Confirm button
                Button {
                    viewModel.completeSet()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Valider \(viewModel.pickerWeight.formattedWeight) × \(viewModel.pickerReps) reps")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.appSuccess)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Enregistrer la série")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(500)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Quick Adjust Button

struct QuickAdjustButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            HapticManager.shared.selection()
        }) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appCardBackground)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WeightRepsPicker(viewModel: {
        let vm = WorkoutViewModel()
        vm.pickerWeight = 80
        vm.pickerReps = 10
        return vm
    }())
}
