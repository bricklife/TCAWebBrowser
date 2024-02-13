//
//  WebFeature.swift
//  TCAWebBrowser
//
//  Created by Shinichiro Oba on 2024/02/12.
//

import ComposableArchitecture
import SwiftUI
import Combine
import WebKit

@Reducer
struct WebFeature {
    @ObservableState
    struct State: Equatable {
        var title: String?
        var url: URL?
        var isLoading = false
        var canGoBack = false
        var canGoForward = false
        
        fileprivate var command: Command?
        
        enum Command: Equatable {
            case loadUrl(URL)
            case reload
            case stopLoading
            case goBack
            case goForward
        }
        
        mutating func enqueue(_ command: Command) -> Effect<Action> {
            self.command = command
            return .none
        }
    }
    
    enum Action {
        case dequeueCommand
        
        case delegate(Delegate)
        
        enum Delegate {
            case titleUpdated(String?)
            case urlUpdated(URL?)
            case isLoadingUpdated(Bool)
            case canGoBackUpdated(Bool)
            case canGoForwardUpdated(Bool)
            case didFail(error: Error)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dequeueCommand:
                state.command = nil
                return .none
                
            case .delegate(.titleUpdated(let value)):
                state.title = value
                return .none
                
            case .delegate(.urlUpdated(let value)):
                state.url = value
                return .none
                
            case .delegate(.isLoadingUpdated(let value)):
                state.isLoading = value
                return .none
                
            case .delegate(.canGoBackUpdated(let value)):
                state.canGoBack = value
                return .none
                
            case .delegate(.canGoForwardUpdated(let value)):
                state.canGoForward = value
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

#if canImport(UIKit)
typealias ViewRepresentable = UIViewRepresentable
#endif
#if canImport(AppKit)
typealias ViewRepresentable = NSViewRepresentable
#endif

struct WebView: ViewRepresentable {
    let store: StoreOf<WebFeature>
    
    func makeCoordinator() -> Coordinator {
        print(#function)
        return Coordinator(store: store)
    }
    
#if canImport(UIKit)
    func makeUIView(context: Context) -> WKWebView {
        print(#function)
        let webView = WKWebView()
        context.coordinator.bind(webView)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        print(#function)
    }
#endif
    
#if canImport(AppKit)
    func makeNSView(context: Context) -> WKWebView {
        print(#function)
        let webView = WKWebView()
        context.coordinator.bind(webView)
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        print(#function)
    }
#endif
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private let store: StoreOf<WebFeature>
        
        private var cancellables = Set<AnyCancellable>()
        
        init(store: StoreOf<WebFeature>) {
            self.store = store
        }
        
        func bind(_ webView: WKWebView) {
            webView.navigationDelegate = self
            
            observe { [weak self, weak webView] in
                print("observe(_:)")
                guard let command = self?.store.command else { return }
                switch command {
                case .loadUrl(let url):
                    webView?.load(URLRequest(url: url))
                case .reload:
                    webView?.reload()
                case .stopLoading:
                    webView?.stopLoading()
                case .goBack:
                    webView?.goBack()
                case .goForward:
                    webView?.goForward()
                }
                self?.store.send(.dequeueCommand)
            }
            
            webView.publisher(for: \.isLoading).sink { [store] value in
                store.send(.delegate(.isLoadingUpdated(value)))
            }.store(in: &cancellables)
            
            webView.publisher(for: \.url).sink { [store] value in
                store.send(.delegate(.urlUpdated(value)))
            }.store(in: &cancellables)
            
            webView.publisher(for: \.title).sink { [store] value in
                store.send(.delegate(.titleUpdated(value)))
            }.store(in: &cancellables)
            
            webView.publisher(for: \.canGoBack).sink { [store] value in
                store.send(.delegate(.canGoBackUpdated(value)))
            }.store(in: &cancellables)
            
            webView.publisher(for: \.canGoForward).sink { [store] value in
                store.send(.delegate(.canGoForwardUpdated(value)))
            }.store(in: &cancellables)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print(#function)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print(#function)
            store.send(.delegate(.didFail(error: error)))
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            print(#function)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print(#function)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(#function)
            store.send(.delegate(.didFail(error: error)))
        }
    }
}

#Preview {
    WebView(
        store: Store(initialState: WebFeature.State(command: .loadUrl(URL(string: "https://google.com")!))) {
            WebFeature()
        }
    )
}
