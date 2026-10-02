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
        Divider()
        Toggle("Mute", isOn: Binding(get: { model.isMuted }, set: { model.setMuted($0) }))
        Picker("Alert Sound", selection: Binding(get: { model.soundName }, set: { model.selectSound($0) })) {
            ForEach(model.availableSounds, id: \.self) { sound in
                Text(sound).tag(sound)
            }
        }
        .disabled(model.availableSounds.isEmpty)
    }
}
