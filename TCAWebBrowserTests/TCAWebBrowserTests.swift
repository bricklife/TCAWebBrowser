//
//  TCAWebBrowserTests.swift
//  TCAWebBrowserTests
//
//  Created by Shinichiro Oba on 2024/02/14.
//

import ComposableArchitecture
import XCTest

@testable import TCAWebBrowser

@MainActor
final class TCAWebBrowserTests: XCTestCase {
    func testLoadUrl() async {
        let store = TestStore(initialState: WebBrowserFeature.State()) {
            WebBrowserFeature()
        }
        
        let url = URL(string: "https://yahoo.com")!
        await store.send(.setLocation(url.absoluteString)) {
            $0.location = url.absoluteString
        }
        await store.send(.didCommitLocation) {
            $0.web.command = .loadUrl(url)
        }
        
        await store.send(.web(.dequeueCommand)) {
            $0.web.command = nil
        }
        
        let newUrl = URL(string: "https://www.yahoo.com")!
        await store.send(.web(.delegate(.didUpdateURL(newUrl)))) {
            $0.web.url = newUrl
            $0.location = newUrl.absoluteString
        }
        
        await store.send(.web(.delegate(.didUpdateURL(nil)))) {
            $0.web.url = nil
        }
    }
    
    func testReload() async {
        let store = TestStore(initialState: WebBrowserFeature.State()) {
            WebBrowserFeature()
        }
        
        let url = URL(string: "https://yahoo.com")!
        await store.send(.setLocation(url.absoluteString)) {
            $0.location = url.absoluteString
        }
        await store.send(.reloadButtonTapped) {
            $0.web.command = .loadUrl(url)
        }
        
        await store.send(.web(.delegate(.didUpdateURL(url)))) {
            $0.web.url = url
        }
        await store.send(.reloadButtonTapped) {
            $0.web.command = .reload
        }
        
        let newUrl = URL(string: "https://google.com")!
        await store.send(.setLocation(newUrl.absoluteString)) {
            $0.location = newUrl.absoluteString
        }
        await store.send(.reloadButtonTapped) {
            $0.web.command = .loadUrl(newUrl)
        }
    }
}
