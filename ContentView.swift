import SwiftUI

enum AppRoute: Hashable {
    case control, observe, todoList, completedList, countdown, guide, colorPicker
}

struct ContentView: View {
    @State private var showLaunch = true
    @StateObject private var store = EventStore()

    var body: some View {
        ZStack {
            if showLaunch {
                LaunchAnimationView {
                    withAnimation(.easeInOut(duration: 0.5)) { showLaunch = false }
                }
                .transition(.opacity)
            } else {
                NavigationStack {
                    MainView()
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .control:       ControlMenuView()
                            case .observe:       ObserveView()
                            case .todoList:      TodoListView()
                            case .completedList: CompletedListView()
                            case .countdown:     CountdownListView()
                            case .guide:         GuideView()
                            case .colorPicker:   ColorPickerView()
                            }
                        }
                }
                .environmentObject(store)
                .transition(.opacity)
            }
        }
    }
}
