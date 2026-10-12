import SwiftUI

/// Pop-up wheel that picks the anniversary day once: one slice per possible day
/// (1...9 by default). It spins for a few seconds, slows down, stops on a random slice
/// and saves that day for good. Shown as a sheet from the countdowns screen.
struct AnniversaryWheelView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var result: Int?

    private var days: [Int] { Array(store.anniversaryDayChoices) }
    private var sliceAngle: Double { 360 / Double(days.count) }
    private var spinDuration: Double { reduceMotion ? 1.5 : 5 }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingL) {
            header

            wheel
                .frame(maxWidth: .infinity)

            if let result {
                resultView(day: result)
            } else {
                Text("Çarkı çevir, çıkan gün yıl dönümümüz olsun. Bu seçim bir kez yapılır.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            primaryButton
        }
        .padding(Theme.spacingL)
        .background(Theme.background.ignoresSafeArea())
        .interactiveDismissDisabled(isSpinning)
        .sensoryFeedback(.success, trigger: result)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            Text("Yıl dönümümüzü belirle")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Theme.spacingS)
            if !isSpinning && result == nil {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(Theme.spacingS)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Kapat")
            }
        }
    }

    // MARK: - Wheel

    /// The slices rotate together; the pointer above stays fixed at the top.
    private var wheel: some View {
        VStack(spacing: Theme.spacingXS) {
            PointerShape()
                .fill(Theme.textPrimary)
                .frame(width: 22, height: 16)

            ZStack {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    let start = -90 + Double(index) * sliceAngle
                    let isAccent = index.isMultiple(of: 2)

                    SliceShape(start: .degrees(start), end: .degrees(start + sliceAngle))
                        .fill(isAccent ? Theme.accent : Theme.surface)
                    SliceShape(start: .degrees(start), end: .degrees(start + sliceAngle))
                        .stroke(Theme.separator, lineWidth: Theme.borderWidth)

                    label(day, centerAngle: start + sliceAngle / 2, onAccent: isAccent)
                }
                Circle()
                    .stroke(Theme.separator, lineWidth: Theme.borderWidth)
            }
            .frame(width: 280, height: 280)
            .rotationEffect(.degrees(rotation))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("1 ile \(days.count) arası günleri gösteren çark")
    }

    /// Day number placed inside its slice, about two thirds of the way out.
    private func label(_ day: Int, centerAngle: Double, onAccent: Bool) -> some View {
        let radians = centerAngle * .pi / 180
        let distance: CGFloat = 140 * 0.68
        return Text("\(day)")
            .font(.system(size: 30, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(onAccent ? Theme.onAccent : Theme.textPrimary)
            .offset(x: cos(radians) * distance, y: sin(radians) * distance)
    }

    // MARK: - Result and button

    private func resultView(day: Int) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text("YIL DÖNÜMÜMÜZ")
                .font(Theme.unitLabelFont)
                .tracking(Theme.unitLabelTracking)
                .foregroundStyle(Theme.textSecondary)
            Text(DateLogic.shortDateText(DateLogic.relationshipStart(pickedDay: day)))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Theme.accent)
        }
        .transition(.opacity)
    }

    private var primaryButton: some View {
        Button {
            if result == nil { spin() } else { dismiss() }
        } label: {
            Text(result == nil ? (isSpinning ? "Dönüyor…" : "Çevir") : "Tamam")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingM)
                .background(Theme.accent, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .opacity(isSpinning ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isSpinning)
    }

    // MARK: - Spin

    /// Picks a random day, turns the wheel several full turns plus the offset that brings
    /// that slice under the pointer, then saves the day when the wheel stops.
    private func spin() {
        guard !isSpinning, result == nil, let day = days.randomElement(),
              let index = days.firstIndex(of: day) else { return }
        isSpinning = true

        let sliceCenter = Double(index) * sliceAngle + sliceAngle / 2
        let fullTurns: Double = reduceMotion ? 1 : 6
        let target = rotation + fullTurns * 360 + (360 - sliceCenter)

        // Fast start, long slow finish.
        withAnimation(.timingCurve(0.15, 0.85, 0.25, 1, duration: spinDuration)) {
            rotation = target
        }

        Task {
            try? await Task.sleep(for: .seconds(spinDuration + 0.2))
            store.pickAnniversaryDay(day)
            withAnimation(.easeInOut(duration: 0.3)) {
                isSpinning = false
                result = day
            }
        }
    }
}

// MARK: - Shapes

/// One pie slice between two angles (0 degrees points right, angles grow clockwise).
private struct SliceShape: Shape {
    let start: Angle
    let end: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        path.closeSubpath()
        return path
    }
}

/// Small triangle pointing down at the wheel.
private struct PointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews
// Uses a throwaway store so spinning in the preview never saves the real pick.

#Preview("Light") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AnniversaryWheelView()
                .environment(DataStore(defaults: UserDefaults(suiteName: "preview-wheel")!,
                                       sharedDefaults: UserDefaults(suiteName: "preview-wheel-shared")!))
        }
}

#Preview("Dark") {
    AnniversaryWheelView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview-wheel")!,
                               sharedDefaults: UserDefaults(suiteName: "preview-wheel-shared")!))
        .preferredColorScheme(.dark)
}
