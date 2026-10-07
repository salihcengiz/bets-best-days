import SwiftUI

/// Content of the coupons section. The use button asks for confirmation, then the coupon
/// is struck through and marked as used for good.
/// The header and footer come from the root view.
struct CouponsView: View {
    @Environment(DataStore.self) private var store
    /// The coupon waiting for confirmation; non-nil while the alert is shown.
    @State private var pendingCoupon: Coupon?

    var body: some View {
        Group {
            if store.coupons.isEmpty {
                Text("Henüz kupon yok.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(Theme.spacingL)
            } else {
                ScrollView {
                    VStack(spacing: Theme.spacingM) {
                        ForEach(store.coupons) { coupon in
                            CouponCard(
                                coupon: coupon,
                                redeemedDate: store.redeemedDate(of: coupon),
                                onUse: { pendingCoupon = coupon }
                            )
                        }
                    }
                    .padding(Theme.spacingL)
                }
            }
        }
        .background(Theme.background)
        .alert(
            "Bu kuponu kullanmak istediğine emin misin?",
            isPresented: Binding(
                get: { pendingCoupon != nil },
                set: { if !$0 { pendingCoupon = nil } }
            ),
            presenting: pendingCoupon
        ) { coupon in
            Button("Vazgeç", role: .cancel) {}
            Button("Kullan") { store.redeem(coupon) }
        } message: { coupon in
            Text(coupon.title)
        }
        .sensoryFeedback(.success, trigger: store.redeemedCoupons.count)
    }
}

/// One coupon. Available: title, detail and an orange use button.
/// Used: dimmed, title struck through, a "used" label with the date.
private struct CouponCard: View {
    let coupon: Coupon
    let redeemedDate: Date?
    let onUse: () -> Void

    /// 0 = no line, 1 = line across the title. Animated when the coupon is used.
    @State private var strike: CGFloat

    init(coupon: Coupon, redeemedDate: Date?, onUse: @escaping () -> Void) {
        self.coupon = coupon
        self.redeemedDate = redeemedDate
        self.onUse = onUse
        _strike = State(initialValue: redeemedDate == nil ? 0 : 1)
    }

    private var isUsed: Bool { redeemedDate != nil }

    var body: some View {
        HStack(alignment: .center, spacing: Theme.spacingM) {
            Image(systemName: "ticket")
                .font(.system(size: 20))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(coupon.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .overlay(alignment: .leading) { strikeLine }

                if let redeemedDate {
                    Text("Kullanıldı · \(DateLogic.shortDateText(redeemedDate))"
                            .uppercased(with: Locale(identifier: "tr_TR")))
                        .font(Theme.unitLabelFont)
                        .tracking(Theme.unitLabelTracking)
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Text(coupon.detail)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .opacity(isUsed ? 0.55 : 1)

            Spacer(minLength: Theme.spacingS)

            if !isUsed {
                Button(action: onUse) {
                    Text("Kullan")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.onAccent)
                        .padding(.horizontal, Theme.spacingM)
                        .padding(.vertical, Theme.spacingS)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(Theme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.separator, lineWidth: Theme.borderWidth)
        )
        .animation(.easeInOut(duration: 0.25), value: isUsed)
        .onChange(of: isUsed) { _, used in
            withAnimation(.easeOut(duration: 0.35)) { strike = used ? 1 : 0 }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(isUsed ? "Kullanıldı" : "")
    }

    /// Line drawn across the title from left to right.
    private var strikeLine: some View {
        Rectangle()
            .fill(Theme.textPrimary)
            .frame(height: 1.5)
            .scaleEffect(x: strike, y: 1, anchor: .leading)
            .allowsHitTesting(false)
    }
}

// MARK: - Previews
// Coupons come from the local content file at runtime; nothing personal is written here.

#Preview("Light") {
    CouponsView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview-coupons")!))
}

#Preview("Dark") {
    CouponsView()
        .environment(DataStore(defaults: UserDefaults(suiteName: "preview-coupons")!))
        .preferredColorScheme(.dark)
}
