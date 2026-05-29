import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
