//
//  WebView.swift
//  OneKit
//
//  Created by zyw on 2025/12/31.
//

import SwiftUI
import WebKit

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

public struct WebContentView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var url: String?
    public var tintColor: Color
    public var title: String
    
    public init(url: String?, title: String, tintColor: Color) {
        self._url = State(initialValue: url)
        self.title = title
        self.tintColor = tintColor
    }
    
    public var body: some View {
        NavigationView {
            WebView(url: $url)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                })
        }
        .navigationViewStyle(.stack)
        .tint(tintColor)
    }
}

#endif

#if canImport(UIKit)

public struct WebView: UIViewRepresentable {
    
    @Binding var url: String?
    
    public init(url: Binding<String?>) {
        self._url = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = context.coordinator
        return webview
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url, let requetURL = URL(string: url) {
            uiView.load(URLRequest(url: requetURL))
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.title") { (result, error) in
                print("didFinish:\(String(describing: result ?? ""))")
            }
        }
    }
}

#endif
