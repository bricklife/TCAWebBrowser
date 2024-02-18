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
        var location: String
        
        var web = WebFeature.State()
        
        @Presents var alert: AlertState<Action.Alert>?
        
        init(url: URL? = nil) {
            self.location = url?.absoluteString ?? "https://google.com"
        }
    }
    
    enum Action {
        case onAppear
        case goBackButtonTapped
        case goForwardButtonTapped
        case setLocation(String)
        case didCommitLocation
        case reloadButtonTapped
        case stopButtonTapped
        
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
                
            case .setLocation(let urlString):
                state.location = urlString
                return .none
                
            case .didCommitLocation:
                return requestUrlString(state: &state)
                
            case .reloadButtonTapped:
                if state.location != state.web.url?.absoluteString {
                    return requestUrlString(state: &state)
                } else {
                    return state.web.enqueue(.reload).map(Action.web)
                }
                
            case .stopButtonTapped:
                return state.web.enqueue(.stopLoading).map(Action.web)
                
            case .web(.delegate(.didUpdateURL(let url))):
                if let url {
                    state.location = url.absoluteString
                }
                return .none
                
            case .web(.delegate(.didFail(error: let error))):
                state.alert = .didFail(error: error)
                return .none
                
            case .web:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    private func requestUrlString(state: inout State) -> Effect<Action> {
        guard let url = URL(string: state.location) else { return .none }
        return state.web.enqueue(.loadUrl(url)).map(Action.web)
    }
}

extension AlertState where Action == WebBrowserFeature.Action.Alert {
    static func didFail(error: Error) -> Self {
        Self {
            TextState("Error")
        } actions: {
            ButtonState {
                TextState("OK")
            }
        } message: {
            TextState((error as NSError).localizedDescription)
        }
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
                .disabled(!store.web.canGoBack)
                
                Button {
                    store.send(.goForwardButtonTapped)
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!store.web.canGoForward)
                
                TextField("URL", text: $store.location.sending(\.setLocation), onCommit: {
                    store.send(.didCommitLocation)
                })
#if !os(macOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
#endif
                .frame(maxWidth: .infinity)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(store.web.isLoading ? 1 : 0)
                
                if store.web.isLoading {
                    Button {
                        store.send(.stopButtonTapped)
                    } label: {
                        Image(systemName: "xmark")
                    }
                } else {
                    Button {
                        store.send(.reloadButtonTapped)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding()
            
            WebView(store: store.scope(state: \.web, action: \.web))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
        .focusedSceneValue(\.webBrowserFeatureStore, store)
    }
}

struct WebBrowserFeatureStoreKey: FocusedValueKey {
    typealias Value = StoreOf<WebBrowserFeature>
}

extension FocusedValues {
    var webBrowserFeatureStore: StoreOf<WebBrowserFeature>? {
        get { self[WebBrowserFeatureStoreKey.self] }
        set { self[WebBrowserFeatureStoreKey.self] = newValue }
    }
}

#Preview {
    WebBrowserView(
        store: Store(initialState: WebBrowserFeature.State()) {
            WebBrowserFeature()
        }
    )
}
