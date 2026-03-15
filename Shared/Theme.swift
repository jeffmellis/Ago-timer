import SwiftUI

enum AgoTheme {
    // MARK: - Brand
    static let accent = Color(red: 1.0, green: 0.78, blue: 0.28)

    // MARK: - Stopwatch time display
    static let runningTime = accent
    static let pausedTime = Color(white: 0.65)

    // MARK: - Buttons
    static let playButton = Color.green
    static let resumeButton = accent
    static let pauseButton = Color(white: 0.35)
    static let secondaryButton = Color.gray

    // MARK: - Labels
    static let nameLabel = Color.white.opacity(0.5)
    static let pausedLabel = Color.white.opacity(0.4)
    static let pausedIcon = Color.white.opacity(0.6)
    static let addButton = Color.white.opacity(0.3)

    // MARK: - Actions
    static let confirmAction = Color.green
    static let destructiveAction = Color.red
}
