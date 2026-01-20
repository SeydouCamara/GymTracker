import SwiftUI
import SwiftData

struct ProgramsListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgramsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.programs.isEmpty {
                    emptyStateView
                } else {
                    programListView
                }
            }
            .navigationTitle("Programmes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.programToEdit = nil
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                ProgramFormSheet(
                    viewModel: viewModel,
                    program: viewModel.programToEdit
                )
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    // MARK: - Program List

    private var programListView: some View {
        List {
            ForEach(viewModel.programs) { program in
                ProgramRowView(
                    program: program,
                    isActive: program.isActive
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.programToEdit = program
                    viewModel.showingAddSheet = true
                    HapticManager.shared.lightImpact()
                }
                .swipeActions(edge: .leading) {
                    if !program.isActive {
                        Button {
                            viewModel.setActiveProgram(program)
                        } label: {
                            Label("Activer", systemImage: "checkmark.circle.fill")
                        }
                        .tint(.appSuccess)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.deleteProgram(program)
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Aucun programme")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Créez un programme pour organiser\nvos séances d'entraînement")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.showingAddSheet = true
            } label: {
                Label("Créer un programme", systemImage: "plus")
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

// MARK: - Program Row View

struct ProgramRowView: View {
    let program: Program
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(program.name)
                    .font(.headline)

                Spacer()

                if isActive {
                    Text("ACTIF")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.appSuccess)
                        )
                        .foregroundStyle(.white)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Session order display
            HStack(spacing: 4) {
                ForEach(Array(program.sessionOrder.enumerated()), id: \.offset) { index, category in
                    HStack(spacing: 4) {
                        if index > 0 {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Text(category.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(category.color.opacity(0.2))
                            )
                            .foregroundStyle(category.color)
                    }
                }
            }

            // Next session indicator for active program
            if isActive, let nextSession = program.nextSession {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(.appPrimary)

                    Text("Prochaine séance:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(nextSession.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(nextSession.color)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProgramsListView()
        .modelContainer(for: Program.self, inMemory: true)
}
