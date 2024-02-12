//
//  WebBrowserFeature.swift
//  TCAWebBrowser
//
//  Created by Shinichiro Oba on 2024/02/12.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct WebBrowserFeature {
    @ObservableState
    struct State: Equatable {
        var title: String?
        var url: URL?
        var isLoading = false
        var canGoBack = false
        var canGoForward = false
        
        var web = WebFeature.State()
    }
    
    enum Action {
        case onAppear
        case goBackButtonTapped
        case goForwardButtonTapped
        case reloadButtonTapped
        
        case web(WebFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.web, action: \.web) {
            WebFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return state.web.enqueue(.loadUrl(URL(string: "https://google.com")!)).map(Action.web)
                
            case .goBackButtonTapped:
                return state.web.enqueue(.goBack).map(Action.web)
                
            case .goForwardButtonTapped:
                return state.web.enqueue(.goForward).map(Action.web)
                
            case .reloadButtonTapped:
                return state.web.enqueue(.reload).map(Action.web)
                
            case .web(.delegate(let delegate)):
                switch delegate {
                case .titleUpdated(let value):
                    state.title = value
                    
                case .urlUpdated(let url):
                    state.url = url
                    
                case .isLoadingUpdated(let value):
                    state.isLoading = value
                    
                case .canGoBackUpdated(let value):
                    state.canGoBack = value
                    
                case .canGoForwardUpdated(let value):
                    state.canGoForward = value
                }
                return .none
                
            case .web:
                return .none
            }
        }
    }
}

struct WebBrowserView: View {
    let store: StoreOf<WebBrowserFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    store.send(.goBackButtonTapped)
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!store.canGoBack)
                
                Button {
                    store.send(.goForwardButtonTapped)
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!store.canGoForward)
                
                Text(store.title ?? "")
                    .lineLimit(1)
                
                Spacer()
                
                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                
                Button {
                    store.send(.reloadButtonTapped)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(store.isLoading)
            }
            .padding()
            
            WebView(store: store.scope(state: \.web, action: \.web))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    WebBrowserView(
        store: Store(initialState: WebBrowserFeature.State()) {
            WebBrowserFeature()
        }
    )
}
