import SwiftUI

struct ControlMenuView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Morandi.background.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                Text("Control")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Morandi.textPrimary)

                VStack(spacing: 16) {
                    menuCard(title: "Things To Do", icon: "list.bullet.rectangle", route: .todoList)
                    menuCard(title: "Things Completed", icon: "checkmark.rectangle", route: .completedList)
                    menuCard(title: "Countdown", icon: "timer", route: .countdown)
                    menuCard(title: "Guide", icon: "book.closed", route: .guide)
                    menuCard(title: "Color", icon: "paintpalette", route: .colorPicker)
                }
                .padding(.horizontal, 32)
                Spacer(); Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .navigationBarLeading) { LightOrbBackButton() } }
    }

    @ViewBuilder
    private func menuCard(title: String, icon: String, route: AppRoute) -> some View {
        NavigationLink(value: route) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(Morandi.textSecondary).frame(width: 32)
                Text(title).font(.system(size: 17, weight: .medium, design: .rounded)).foregroundColor(Morandi.textPrimary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundColor(Morandi.textSecondary)
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 16).fill(Morandi.cardBg)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2))
        }
    }
}
