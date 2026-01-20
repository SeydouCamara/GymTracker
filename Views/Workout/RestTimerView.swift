import SwiftUI

struct RestTimerView: View {
    var timerManager: TimerManager

    var body: some View {
        VStack(spacing: 16) {
            // Timer display
            HStack {
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color.appCardBackground, lineWidth: 6)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            timerManager.isComplete ? Color.appSuccess : Color.appPrimary,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: timerManager.progress)

                    Text(timerManager.formattedTime)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundStyle(timerManager.isComplete ? .appSuccess : .primary)
                }

                Spacer()

                // Status text
                VStack(alignment: .leading, spacing: 4) {
                    Text(timerManager.isComplete ? "Repos terminé !" : "Repos en cours")
                        .font(.headline)

                    Text(timerManager.isComplete ? "Prêt pour la prochaine série" : "Récupère bien 💪")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Control buttons
                HStack(spacing: 8) {
                    if !timerManager.isComplete {
                        // Pause/Resume button
                        Button {
                            if timerManager.isRunning {
                                timerManager.pause()
                            } else {
                                timerManager.resume()
                            }
                        } label: {
                            Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.appCardBackground))
                        }
                        .buttonStyle(.plain)
                    }

                    // Stop/Dismiss button
                    Button {
                        timerManager.stop()
                    } label: {
                        Image(systemName: timerManager.isComplete ? "checkmark" : "xmark")
                            .font(.title3)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(timerManager.isComplete ? Color.appSuccess : Color.appCardBackground)
                            )
                            .foregroundStyle(timerManager.isComplete ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Quick time adjustments
            if !timerManager.isComplete {
                HStack(spacing: 12) {
                    ForEach(RestDuration.allCases, id: \.self) { duration in
                        Button {
                            timerManager.startWithSeconds(TimeInterval(duration.seconds))
                        } label: {
                            Text(duration.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(
                                            timerManager.totalDuration == TimeInterval(duration.seconds)
                                            ? Color.appPrimary
                                            : Color.appCardBackground
                                        )
                                )
                                .foregroundStyle(
                                    timerManager.totalDuration == TimeInterval(duration.seconds)
                                    ? .white
                                    : .primary
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    // Add 30s button
                    Button {
                        timerManager.addTime(30)
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "plus")
                            Text("30s")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.appPrimary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cardCornerRadius)
                .fill(timerManager.isComplete ? Color.appSuccess.opacity(0.15) : Color.appCardBackground)
        )
    }
}

#Preview("Running") {
    RestTimerView(timerManager: {
        let timer = TimerManager.shared
        timer.startWithSeconds(90)
        return timer
    }())
    .padding()
}

#Preview("Complete") {
    RestTimerView(timerManager: {
        let timer = TimerManager.shared
        timer.startWithSeconds(0)
        return timer
    }())
    .padding()
}
