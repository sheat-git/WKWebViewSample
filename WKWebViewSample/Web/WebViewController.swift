//
//  WebViewController.swift
//  WKWebViewSample
//
//  Created by sheat on 2022/04/16.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webView: WKWebView!
    private var prevY: CGFloat? = nil
    private var observers: [NSKeyValueObservation] = []
    @objc dynamic var canGoBack: Bool = false
    @objc dynamic var canGoForward: Bool = false
    @objc dynamic var isLoading: Bool = true
    @objc dynamic var estimatedProgress: Double = 0
    @objc dynamic var url: URL? = nil
    @objc dynamic var isBarHidden: Bool = false
    @objc dynamic var toolBarHeight: CGFloat = 0
    @objc dynamic var bottomSafeAreaInset: CGFloat = 0
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        observers.append(webView.observe(\.title, options: .new){ [weak self] _, change in
            guard let title = change.newValue else { return }
            self?.parent?.navigationItem.title = title
        })
        
        observers.append(webView.observe(\.canGoBack, options: .new) { [weak self] _, change in
            guard let canGoBack = change.newValue else { return }
            self?.canGoBack = canGoBack
            if self?.parent?.navigationItem.hidesBackButton != canGoBack {
                self?.parent?.navigationItem.hidesBackButton = canGoBack
            }
        })
        observers.append(webView.observe(\.canGoForward, options: .new) { [weak self] _, change in
            guard let canGoForward = change.newValue else { return }
            self?.canGoForward = canGoForward
        })
        observers.append(webView.observe(\.isLoading, options: .new) { [weak self] _, change in
            guard let isLoading = change.newValue else { return }
            self?.isLoading = isLoading
        })
        observers.append(webView.observe(\.estimatedProgress, options: .new) { [weak self] _, change in
            guard let estimatedProgress = change.newValue else { return }
            self?.estimatedProgress = estimatedProgress
        })
        observers.append(webView.observe(\.url, options: .new) { [weak self] _, change in
            guard let url = change.newValue else { return }
            self?.url = url
        })
        
        view.addSubview(webView)
        
        webView.load(URLRequest(url: URL(string: "https://google.com")!))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setToolBarHeight()
        
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeFromSuperview()
    }
    
    private func setToolBarHeight() {
        if let toolBarHeight = parent?.navigationController?.toolbar.bounds.height {
            self.toolBarHeight = toolBarHeight
        }
        self.bottomSafeAreaInset = view.safeAreaInsets.bottom
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }

        if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false], completionHandler: { (finished: Bool) in
                    // pass
                })
            } else {
                UIApplication.shared.open(url)
                return nil
            }
        } else if !url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return nil
            }
        }

        // open target="_blank"
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            webView.load(URLRequest(url: url))
            return nil
        }
        return nil
    }
    
    // alert panel
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(closeAction)
        present(alertController, animated: true)
    }
    
    // confirm panel
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    // text input panel
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alertController.textFields?.first?.text)
        }
        alertController.addTextField(configurationHandler: { $0.text = defaultText })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
            if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false], completionHandler: { (finished: Bool) in
                    // pass
                })
            }
            else {
                UIApplication.shared.open(url)
            }
            decisionHandler(.cancel)
            return
        }
        else if !url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }

        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }
        case .backForward:
            break
        case .formResubmitted:
            break
        case .formSubmitted:
            break
        case .other:
            break
        case .reload:
            break
        @unknown default:
            fatalError()
        }

        decisionHandler(.allow)
    }
}

extension WebViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking && scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
            isBarHidden = true
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
            isBarHidden = false
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if isBarHidden {
            isBarHidden = false
            return false
        }
        return true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isBarHidden = false
    }
}
