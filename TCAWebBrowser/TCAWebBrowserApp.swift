//
//  TCAWebBrowserApp.swift
//  TCAWebBrowser
//
//  Created by Shinichiro Oba on 2024/02/12.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCAWebBrowserApp: App {
    var body: some Scene {
        WindowGroup(for: URL.self) { $url in
            WebBrowserView(store: Store(initialState: WebBrowserFeature.State(url: url)) {
                WebBrowserFeature()
            })
        }
    }
}
