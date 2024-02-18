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
        .commands {
            NavigationCommands()
        }
    }
}

struct NavigationCommands: Commands {
    @FocusedValue(\.webBrowserFeatureStore) var store
    
    var body: some Commands {
        CommandMenu("Navigation") {
            Button("Back") {
                store?.send(.goBackButtonTapped)
            }
            .keyboardShortcut("[")
            .disabled(store?.state.web.canGoBack != true)
            
            Button("Forward") {
                store?.send(.goForwardButtonTapped)
            }
            .keyboardShortcut("]")
            .disabled(store?.state.web.canGoForward != true)
            
            Divider()
            
            Button("Stop") {
                store?.send(.stopButtonTapped)
            }
            .keyboardShortcut(".")
            .disabled(store == nil)
            
            Button("Reload Page") {
                store?.send(.reloadButtonTapped)
            }
            .keyboardShortcut("R")
            .disabled(store == nil)
        }
    }
}
