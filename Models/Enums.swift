import Foundation
import SwiftUI

// MARK: - Exercise Category
/// Catégories d'exercices basées sur le type d'entraînement
enum ExerciseCategory: String, CaseIterable, Codable {
    case push = "PUSH"
    case pull = "PULL"
    case legs = "LEGS"
    case jjb = "JJB"
    case mobilite = "MOBILITE"

    var displayName: String {
        switch self {
        case .push: return "Push"
        case .pull: return "Pull"
        case .legs: return "Legs"
        case .jjb: return "JJB"
        case .mobilite: return "Mobilité"
        }
    }

    var icon: String {
        switch self {
        case .push: return "arrow.up.circle.fill"
        case .pull: return "arrow.down.circle.fill"
        case .legs: return "figure.walk"
        case .jjb: return "figure.martial.arts"
        case .mobilite: return "figure.flexibility"
        }
    }

    var color: Color {
        switch self {
        case .push: return .pushColor
        case .pull: return .pullColor
        case .legs: return .legsColor
        case .jjb: return .jjbColor
        case .mobilite: return .mobiliteColor
        }
    }
}

// MARK: - Muscle Group
/// Groupes musculaires ciblés par les exercices
enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "CHEST"
    case back = "BACK"
    case shoulders = "SHOULDERS"
    case biceps = "BICEPS"
    case triceps = "TRICEPS"
    case quadriceps = "QUADRICEPS"
    case hamstrings = "HAMSTRINGS"
    case glutes = "GLUTES"
    case calves = "CALVES"
    case core = "CORE"
    case fullBody = "FULL_BODY"

    var displayName: String {
        switch self {
        case .chest: return "Pectoraux"
        case .back: return "Dos"
        case .shoulders: return "Épaules"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .quadriceps: return "Quadriceps"
        case .hamstrings: return "Ischio-jambiers"
        case .glutes: return "Fessiers"
        case .calves: return "Mollets"
        case .core: return "Abdominaux"
        case .fullBody: return "Corps complet"
        }
    }

    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.strengthtraining.functional"
        case .triceps: return "dumbbell.fill"
        case .quadriceps: return "figure.walk"
        case .hamstrings: return "figure.run"
        case .glutes: return "figure.step.training"
        case .calves: return "shoeprints.fill"
        case .core: return "figure.core.training"
        case .fullBody: return "figure.mixed.cardio"
        }
    }

    /// Groupes musculaires associés à chaque catégorie d'exercice
    static func groups(for category: ExerciseCategory) -> [MuscleGroup] {
        switch category {
        case .push:
            return [.chest, .shoulders, .triceps]
        case .pull:
            return [.back, .biceps]
        case .legs:
            return [.quadriceps, .hamstrings, .glutes, .calves]
        case .jjb:
            return [.fullBody, .core]
        case .mobilite:
            return [.fullBody, .core]
        }
    }
}

// MARK: - Rest Duration
/// Durées de repos prédéfinies entre les séries
enum RestDuration: Int, CaseIterable, Codable {
    case thirty = 30
    case sixty = 60
    case ninety = 90
    case twoMinutes = 120
    case threeMinutes = 180

    var displayName: String {
        switch self {
        case .thirty: return "30s"
        case .sixty: return "1min"
        case .ninety: return "1min30"
        case .twoMinutes: return "2min"
        case .threeMinutes: return "3min"
        }
    }

    var seconds: Int {
        return rawValue
    }
}

// MARK: - Workout Status
/// État d'une séance d'entraînement
enum WorkoutStatus: String, Codable {
    case notStarted = "NOT_STARTED"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}
