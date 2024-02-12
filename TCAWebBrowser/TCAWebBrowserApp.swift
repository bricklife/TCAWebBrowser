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
    static let store = Store(initialState: WebBrowserFeature.State()) {
        WebBrowserFeature()
    }
    
    var body: some Scene {
        WindowGroup(id: "browser") {
            WebBrowserView(store: Self.store)
        }
    }
}
