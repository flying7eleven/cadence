import SwiftUI

struct MenuBarView: View {
    let model: MenuBarModel

    var body: some View {
        Text(PhaseDisplayName.string(for: model.phase))
        Divider()
        if model.isRunning {
            Button("Pause") { model.pause() }
        } else if model.isPaused {
            Button("Resume") { model.resume() }
        } else {
            Button("Start") { model.start() }
        }
        Button("Reset") { model.reset() }
            .disabled(model.isIdle)
    }
}