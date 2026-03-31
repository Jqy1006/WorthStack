import SwiftUI

struct GuideView: View {
    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Welcome to MindBlock")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Morandi.textPrimary)

                    Text("This app helps you understand how you spend your time and what truly matters to you.\n\nHere's how each feature works:")
                        .font(.system(size: 15)).foregroundColor(Morandi.textSecondary)

                    // Main Page
                    featureSection(icon: "square.grid.3x3.fill", title: "Main Page",
                        detail: "• Top blocks (Rain of Tasks): pending tasks.\n• Bottom blocks (Life's Meadow): completed & abandoned events.\n• Tap a block to view/edit.\n• Long-press blocks to delete.")

                    // Things To Do
                    featureSection(icon: "list.bullet.rectangle", title: "Things To Do",
                        detail: "• Add tasks with value scores and times.\n• Enable Countdown to track deadlines.\n• Convert to 'Completed' when done.\n• Keep a record with 'Abandon' or clear with 'Delete'.")

                    // Things Completed
                    featureSection(icon: "checkmark.rectangle", title: "Things Completed",
                        detail: "• Add actual duration for time tracking.\n• Set a Final Value representing your post-task feeling.\n• Convert back to Todo or abandon/delete if needed.")

                    // Countdown
                    featureSection(icon: "timer", title: "Countdown",
                        detail: "• Live active timers.\n• Pin important ones; overdue highlighted in red.")

                    // Color
                    featureSection(icon: "paintpalette", title: "Color",
                        detail: "• Customize block colors.\n• Reset to Morandi defaults anytime.")

                    // Observe
                    featureSection(icon: "eye", title: "Observe",
                        detail: "• View personal analytics on your time and values.\n• Read and manage all your notes in one place.")

                    Divider().padding(.vertical, 4)

                    // Closing message
                    Text("May this app help you stay honest with your emotions and choices, and make visible the time you spend on what you truly value. Whether rain settles on the meadow or the meadow reaches the sky, this is simply the shape of life today. Keep hold of yourself, and tomorrow will still be waiting.")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundColor(Morandi.textPrimary.opacity(0.85))
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(
                                    colors: [Morandi.lightGreen.opacity(0.15), Morandi.lightBlue.opacity(0.10)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
    }

    @ViewBuilder
    private func featureSection(icon: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 16, weight: .medium)).foregroundColor(Morandi.darkBlue)
                Text(title).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(Morandi.textPrimary)
            }
            Text(detail).font(.system(size: 14)).foregroundColor(Morandi.textSecondary).fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Morandi.cardBg))
    }


}
