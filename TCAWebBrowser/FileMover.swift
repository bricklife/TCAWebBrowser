//
//  FileMover.swift
//  TCAWebBrowser
//
//  Created by Shinichiro Oba on 2024/02/19.
//

import ComposableArchitecture
import SwiftUI

struct FileMoverState<Action>: Identifiable {
    let id = UUID()
    let url: URL?
}

extension FileMoverState: Equatable {}

extension FileMoverState: _EphemeralState {}

extension FileMoverState: Sendable where Action: Sendable {}

extension View {
    func fileMover<Action>(_ item: Binding<Store<FileMoverState<Action>, Action>?>) -> some View {
        let store = item.wrappedValue
        let fileMoverState = store?.withState { $0 }
        return self.fileMover(isPresented: item.isPresent(), file: fileMoverState?.url) { print($0) }
    }
}

extension Binding {
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        self._isPresent
    }
}

extension Optional {
    fileprivate var _isPresent: Bool {
        get { self != nil }
        set {
            guard !newValue else { return }
            self = nil
        }
    }
}
