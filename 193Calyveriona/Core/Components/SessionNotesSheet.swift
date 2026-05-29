import SwiftUI

struct SessionNotesSheet: View {
    let title: String
    let subtitle: String
    let onSave: (String) -> Void
    let onSkip: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var notes = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    IconBadge(symbol: "note.text", size: 56, iconSize: .title2)
                        .padding(.top, 16)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    AppCard {
                        TextField("How did it feel? Optional notes...", text: $notes, axis: .vertical)
                            .lineLimit(4...8)
                            .focused($isFocused)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Save Notes", icon: "checkmark") {
                        onSave(notes.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .padding(.horizontal, 16)

                    Button {
                        FeedbackManager.lightTap()
                        onSkip()
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .padding(.bottom, 16)
                }
            }
            .background(Color("AppBackground"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { isFocused = true }
        }
    }
}
