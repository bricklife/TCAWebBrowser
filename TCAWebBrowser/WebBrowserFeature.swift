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
                .disabled(!store.web.canGoBack)
                
                Button {
                    store.send(.goForwardButtonTapped)
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!store.web.canGoForward)
                
                Text(store.web.title ?? "")
                    .lineLimit(1)
                
                Spacer()
                
                if store.web.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                
                Button {
                    store.send(.reloadButtonTapped)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(store.web.isLoading)
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
