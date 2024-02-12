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
        var urlString = "https://google.com/"
        
        var title: String?
        var url: URL?
        var isLoading = false
        var canGoBack = false
        var canGoForward = false
        
        var web = WebFeature.State()
        
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case onAppear
        case goBackButtonTapped
        case goForwardButtonTapped
        case reloadButtonTapped
        case setUrlString(String)
        case didEnterUrl
        
        case web(WebFeature.Action)
        
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.web, action: \.web) {
            WebFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return requestUrlString(state: &state)
                
            case .goBackButtonTapped:
                return state.web.enqueue(.goBack).map(Action.web)
                
            case .goForwardButtonTapped:
                return state.web.enqueue(.goForward).map(Action.web)
                
            case .reloadButtonTapped:
                if state.url == nil {
                    return requestUrlString(state: &state)
                } else {
                    return state.web.enqueue(.reload).map(Action.web)
                }
                
            case .setUrlString(let urlString):
                state.urlString = urlString
                return .none
                
            case .didEnterUrl:
                return requestUrlString(state: &state)
                
            case .web(.delegate(let delegate)):
                switch delegate {
                case .titleUpdated(let value):
                    state.title = value
                    
                case .urlUpdated(let url):
                    state.url = url
                    if let url {
                        state.urlString = url.absoluteString
                    }
                    
                case .isLoadingUpdated(let value):
                    state.isLoading = value
                    
                case .canGoBackUpdated(let value):
                    state.canGoBack = value
                    
                case .canGoForwardUpdated(let value):
                    state.canGoForward = value
                    
                case .didFail(let error):
                    state.alert = AlertState {
                        TextState("Error")
                    } actions: {
                        ButtonState {
                            TextState("OK")
                        }
                    } message: {
                        TextState((error as NSError).localizedDescription)
                    }
                }
                return .none
                
            case .web:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    func requestUrlString(state: inout State) -> Effect<Action> {
        guard let url = URL(string: state.urlString) else { return .none }
        return state.web.enqueue(.loadUrl(url)).map(Action.web)
    }
}

struct WebBrowserView: View {
    @Bindable var store: StoreOf<WebBrowserFeature>
    
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
                
                TextField("URL", text: $store.urlString.sending(\.setUrlString), onCommit: {
                    store.send(.didEnterUrl)
                })
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                
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
        .alert($store.scope(state: \.alert, action: \.alert))
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
