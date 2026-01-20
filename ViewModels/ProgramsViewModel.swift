import Foundation
import SwiftData
import SwiftUI

@Observable
class ProgramsViewModel {
    var modelContext: ModelContext?

    var programs: [Program] = []
    var activeProgram: Program?

    // Sheet state
    var showingAddSheet = false
    var programToEdit: Program?

    // MARK: - Initialization

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPrograms()
    }

    // MARK: - Load

    func loadPrograms() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Program>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            programs = try modelContext.fetch(descriptor)
            activeProgram = programs.first { $0.isActive }
        } catch {
            print("Error fetching programs: \(error)")
            programs = []
            activeProgram = nil
        }
    }

    // MARK: - CRUD Operations

    func addProgram(
        name: String,
        sessionOrder: [ExerciseCategory]
    ) {
        guard let modelContext else { return }

        let program = Program(
            name: name,
            sessionOrder: sessionOrder,
            isActive: programs.isEmpty // First program is active by default
        )

        modelContext.insert(program)
        saveContext()
        loadPrograms()

        HapticManager.shared.success()
    }

    func updateProgram(
        _ program: Program,
        name: String,
        sessionOrder: [ExerciseCategory]
    ) {
        program.name = name
        program.sessionOrder = sessionOrder

        saveContext()
        loadPrograms()

        HapticManager.shared.success()
    }

    func deleteProgram(_ program: Program) {
        guard let modelContext else { return }

        // If deleting active program, activate another one if available
        let wasActive = program.isActive

        modelContext.delete(program)
        saveContext()
        loadPrograms()

        if wasActive, let firstProgram = programs.first {
            setActiveProgram(firstProgram)
        }

        HapticManager.shared.mediumImpact()
    }

    // MARK: - Active Program Management

    func setActiveProgram(_ program: Program) {
        // Deactivate all programs
        for p in programs {
            p.isActive = false
        }

        // Activate selected program
        program.isActive = true
        activeProgram = program

        saveContext()
        loadPrograms()

        HapticManager.shared.success()
    }

    func advanceActiveProgram() {
        guard let active = activeProgram else { return }
        active.advanceToNextSession()
        saveContext()
        loadPrograms()
    }

    // MARK: - Helpers

    var nextSuggestedSession: ExerciseCategory? {
        activeProgram?.nextSession
    }

    // MARK: - Private

    private func saveContext() {
        do {
            try modelContext?.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
