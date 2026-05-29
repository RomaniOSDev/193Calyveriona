import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    SummaryStripCell(items: [
                        ("Entries", "\(store.routinesCreated + store.totalSessionsCompleted)", "square.and.pencil"),
                        ("Minutes", "\(store.totalMinutesUsed)", "clock.fill"),
                        ("Streak", "\(store.streakDays)d", "flame.fill")
                    ])
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    AppCard(padding: 0) {
                        VStack(spacing: 0) {
                            Button {
                                FeedbackManager.lightTap()
                                rateApp()
                            } label: {
                                SettingsRowCell(
                                    icon: "star.fill",
                                    title: "Rate Us",
                                    subtitle: "Enjoying the app? Leave a review"
                                )
                            }
                            divider
                            Button {
                                FeedbackManager.lightTap()
                                openLink(.privacyPolicy)
                            } label: {
                                SettingsRowCell(
                                    icon: "hand.raised.fill",
                                    title: "Privacy",
                                    subtitle: "Privacy policy"
                                )
                            }
                            divider
                            Button {
                                FeedbackManager.lightTap()
                                openLink(.termsOfUse)
                            } label: {
                                SettingsRowCell(
                                    icon: "doc.text.fill",
                                    title: "Terms",
                                    subtitle: "Terms of use"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    AppCard(padding: 0) {
                        VStack(spacing: 0) {
                            Button {
                                FeedbackManager.lightTap()
                                openSupportEmail()
                            } label: {
                                SettingsRowCell(
                                    icon: "envelope.fill",
                                    title: "Support",
                                    subtitle: "support@example.com"
                                )
                            }
                            divider
                            Button {
                                FeedbackManager.lightTap()
                                showResetAlert = true
                            } label: {
                                SettingsRowCell(
                                    icon: "trash.fill",
                                    title: "Reset All Data",
                                    subtitle: "Permanently delete everything",
                                    isDestructive: true
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackManager.lightTap()
                }
                Button("Reset", role: .destructive) {
                    FeedbackManager.warning()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete all routines, stats, and achievements.")
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppTextSecondary").opacity(0.12))
            .frame(height: 1)
            .padding(.leading, 68)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func openLink(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openSupportEmail() {
        if let url = URL(string: "mailto:support@example.com") {
            UIApplication.shared.open(url)
        }
    }
}
