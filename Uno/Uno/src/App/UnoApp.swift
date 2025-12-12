//
//  UnoApp.swift
//  Uno
//
//  Created by Schuetz Moritz - s2310237015 on 21.11.25.
//

import SwiftUI

@main
struct UnoApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
