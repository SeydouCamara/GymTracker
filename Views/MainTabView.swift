import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ActiveWorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell.fill")
                }
                .tag(1)

            ExercisesListView()
                .tabItem {
                    Label("Exercices", systemImage: "list.bullet")
                }
                .tag(2)

            ProgramsListView()
                .tabItem {
                    Label("Programmes", systemImage: "calendar")
                }
                .tag(3)

            HistoryView()
                .tabItem {
                    Label("Historique", systemImage: "clock.fill")
                }
                .tag(4)
        }
        .tint(.appPrimary)
    }
}

#Preview {
    MainTabView()
}
