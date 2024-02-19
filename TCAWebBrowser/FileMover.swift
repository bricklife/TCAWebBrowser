//
//  FileMover.swift
//  TCAWebBrowser
//
//  Created by Shinichiro Oba on 2024/02/19.
//

import ComposableArchitecture
import SwiftUI

struct FileMoverState<Action>: Identifiable {
    let id: UUID
    let url: URL?
    let completed: Action?
    let failed: Action?
    
    init(url: URL?, completed: Action? = nil, failed: Action? = nil) {
        self.id = UUID()
        self.url = url
        self.completed = completed
        self.failed = failed
    }
}

extension FileMoverState: Equatable where Action: Equatable  {}

extension FileMoverState: _EphemeralState {}

extension FileMoverState: Sendable where Action: Sendable {}

extension View {
    func fileMover<Action>(_ item: Binding<Store<FileMoverState<Action>, Action>?>) -> some View {
        let store = item.wrappedValue
        let fileMoverState = store?.withState { $0 }
        let binding = Binding<Bool>(get: { store != nil }, set: { _ in })
        return self.fileMover(isPresented: binding, file: fileMoverState?.url, onCompletion: { result in
            switch result {
            case .success:
                if let action = fileMoverState?.completed {
                    store?.send(action)
                }
            case .failure:
                if let action = fileMoverState?.failed {
                    store?.send(action)
                }
            }
            item.wrappedValue = nil
        }, onCancellation: {
            item.wrappedValue = nil
        })
    }
}
