import SwiftUI

@main
struct CadenceApp: App {
    @State private var model = MenuBarModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(model: model)
        } label: {
            Text(model.menuBarLabel)
        }
        .menuBarExtraStyle(.menu)
    }
}
