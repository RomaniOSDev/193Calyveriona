import SwiftUI

// MARK: - Elevation (single composited shadow — GPU-friendly)

enum AppElevation {
    case flat
    case raised
    case floating

    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .raised: return 0.22
        case .floating: return 0.32
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 8
        case .floating: return 14
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 4
        case .floating: return 7
        }
    }
}

// MARK: - Shared gradients (inline Color assets — no extension)

enum AppGradients {
    static func surfaceFill() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func primaryFill() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary"),
                Color("AppPrimary").opacity(0.78)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func accentFill() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent"),
                Color("AppPrimary")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static func borderStroke() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.45),
                Color("AppAccent").opacity(0.12),
                Color("AppPrimary").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func topSheen() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.14),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    static func backgroundBase() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppBackground"),
                Color("AppSurface").opacity(0.22)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Reusable surface shape

struct AppSurfaceShape: View {
    var cornerRadius: CGFloat = 18
    var showBorder: Bool = true
    var showSheen: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.surfaceFill())
            .overlay {
                if showSheen {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.topSheen())
                }
            }
            .overlay {
                if showBorder {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppGradients.borderStroke(), lineWidth: 1)
                }
            }
    }
}

// MARK: - View modifiers

extension View {
    /// One composited shadow layer — cheaper than multiple .shadow calls.
    func appElevation(_ level: AppElevation) -> some View {
        compositingGroup()
            .shadow(
                color: .black.opacity(level.shadowOpacity),
                radius: level.shadowRadius,
                y: level.shadowY
            )
    }

    func appSurfaceBackground(
        cornerRadius: CGFloat = 18,
        showBorder: Bool = true,
        showSheen: Bool = true,
        elevation: AppElevation = .raised
    ) -> some View {
        background {
            AppSurfaceShape(
                cornerRadius: cornerRadius,
                showBorder: showBorder,
                showSheen: showSheen
            )
        }
        .appElevation(elevation)
    }

    func appPrimaryButtonBackground(cornerRadius: CGFloat = 16) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.primaryFill())
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.topSheen())
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .appElevation(.floating)
    }
}

// MARK: - Optimized decorative background (rasterized once)

struct AppDecorBackground: View {
    var body: some View {
        ZStack {
            AppGradients.backgroundBase()

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.11), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 280
            )

            RadialGradient(
                colors: [Color("AppAccent").opacity(0.07), .clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 240
            )

            // Sparse dot grid — low draw cost vs dense Canvas loops
            GeometryReader { geo in
                let spacing: CGFloat = 52
                Canvas { context, size in
                    var x: CGFloat = spacing / 2
                    while x < size.width {
                        var y: CGFloat = spacing / 2
                        while y < size.height {
                            let rect = CGRect(x: x, y: y, width: 2, height: 2)
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .color(Color("AppSurface").opacity(0.22))
                            )
                            y += spacing
                        }
                        x += spacing
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .drawingGroup(opaque: false)
        .ignoresSafeArea()
    }
}
