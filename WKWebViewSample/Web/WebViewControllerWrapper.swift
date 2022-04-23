//
//  WebViewControllerWrapper.swift
//  WKWebViewSample
//
//  Created by sheat on 2022/04/18.
//

import SwiftUI
import WebKit

struct WebViewControllerWrapper: UIViewControllerRepresentable {
    
    private let webViewController = WebViewController()
    @Binding var action: Action?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var estimatedProgress: Double
    @Binding var url: URL?
    @Binding var isBarHidden: Bool
    @Binding var toolBarHeight: CGFloat
    @Binding var bottomSafeAreaInset: CGFloat
    
    enum Action: Equatable {
        case stopLoading
        case reload
        case goBack
        case goForward
        case share
        case openSafari
    }
    
    typealias UIViewControllerType = WebViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        webViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        switch action {
        case .stopLoading:
            uiViewController.webView.stopLoading()
        case .reload:
            uiViewController.webView.reload()
        case .goBack:
            uiViewController.webView.goBack()
        case .goForward:
            uiViewController.webView.goForward()
        case .share:
            if let url = url {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                uiViewController.present(activityViewController, animated: true)
            }
        case .openSafari:
            if let url = url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case .none:
            return
        }
        
        DispatchQueue.main.async {
            action = nil
        }
    }
    
    class Coordinator {
        let parent: WebViewControllerWrapper
        var observers: [NSKeyValueObservation] = []
        
        init(parent: WebViewControllerWrapper) {
            self.parent = parent
            
            observers.append(parent.webViewController.observe(\.canGoBack, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    self?.parent.canGoBack = change.newValue ?? false
                }
            })
            observers.append(parent.webViewController.observe(\.canGoForward, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    self?.parent.canGoForward = change.newValue ?? false
                }
            })
            observers.append(parent.webViewController.observe(\.isLoading, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    self?.parent.isLoading = change.newValue ?? false
                }
            })
            observers.append(parent.webViewController.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    self?.parent.estimatedProgress = change.newValue ?? 0
                }
            })
            observers.append(parent.webViewController.observe(\.url, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    self?.parent.url = change.newValue ?? nil
                }
            })
            observers.append(parent.webViewController.observe(\.isBarHidden, options: .new) { [weak self] _, change in
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self?.parent.isBarHidden = change.newValue ?? false
                    }
                }
            })
            observers.append(parent.webViewController.observe(\.toolBarHeight, options: .new) { [weak self] _, change in
                guard let toolBarHeight = change.newValue else { return }
                DispatchQueue.main.async {
                    self?.parent.toolBarHeight = toolBarHeight
                }
            })
            observers.append(parent.webViewController.observe(\.bottomSafeAreaInset, options: .new) { [weak self] _, change in
                guard let bottomSafeAreaInset = change.newValue else { return }
                DispatchQueue.main.async {
                    self?.parent.bottomSafeAreaInset = bottomSafeAreaInset
                }
            })
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
