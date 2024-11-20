//
//  HeadwayPlayerApp.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 18.11.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct HeadwayPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            BookSummaryView(
                store: Store(initialState: BookSummaryFeature.State()) { BookSummaryFeature() }
            )
        }
    }
}
