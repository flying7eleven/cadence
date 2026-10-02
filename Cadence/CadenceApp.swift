import SwiftUI

@main
struct CadenceApp: App {
    @State private var model = MenuBarModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(model: model)
        } label: {
            Text(CountdownFormatter.string(from: model.remaining))
        }
        .menuBarExtraStyle(.menu)
    }
}