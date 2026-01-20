import Foundation
import SwiftUI

@Observable
class TimerManager {
    static let shared = TimerManager()

    var isRunning = false
    var remainingTime: TimeInterval = 0
    var selectedDuration: RestDuration = .ninety
    var totalDuration: TimeInterval = 0

    private var timer: Timer?

    private init() {}

    // MARK: - Computed Properties

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1 - (remainingTime / totalDuration)
    }

    var formattedTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var isComplete: Bool {
        remainingTime <= 0 && totalDuration > 0
    }

    // MARK: - Timer Control

    func start(duration: RestDuration) {
        selectedDuration = duration
        totalDuration = TimeInterval(duration.seconds)
        remainingTime = totalDuration
        isRunning = true

        startTimer()
        HapticManager.shared.mediumImpact()
    }

    func startWithSeconds(_ seconds: TimeInterval) {
        totalDuration = seconds
        remainingTime = seconds
        isRunning = true

        startTimer()
        HapticManager.shared.mediumImpact()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        HapticManager.shared.lightImpact()
    }

    func resume() {
        guard remainingTime > 0 else { return }
        isRunning = true
        startTimer()
        HapticManager.shared.lightImpact()
    }

    func stop() {
        isRunning = false
        remainingTime = 0
        totalDuration = 0
        timer?.invalidate()
        timer = nil
        HapticManager.shared.lightImpact()
    }

    func addTime(_ seconds: TimeInterval) {
        remainingTime += seconds
        totalDuration += seconds
        HapticManager.shared.selection()
    }

    func reset() {
        remainingTime = totalDuration
        if !isRunning {
            isRunning = true
            startTimer()
        }
        HapticManager.shared.mediumImpact()
    }

    // MARK: - Private

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.remainingTime > 0 {
                self.remainingTime -= 1

                // Tick haptic for last 5 seconds
                if self.remainingTime <= 5 && self.remainingTime > 0 {
                    HapticManager.shared.timerTick()
                }

                if self.remainingTime <= 0 {
                    self.timerCompleted()
                }
            }
        }
    }

    private func timerCompleted() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        HapticManager.shared.timerComplete()
    }
}
