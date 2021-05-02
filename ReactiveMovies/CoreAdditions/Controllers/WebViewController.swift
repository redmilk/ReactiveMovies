//
//  WebViewController.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 01.05.2021.
//

import Combine
import UIKit.UIViewController
import WebKit

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: ResultPublishable {
    typealias Result = String
    var resultPublisher: AnyPublisher<String, Never> {
        result.eraseToAnyPublisher()
    }
}

final class WebViewController: UIViewController {
    
    lazy private var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = [.all]
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layer.cornerRadius = 20
        webView.clipsToBounds = true
        self.view.addSubview(webView)
        /// for having transparent space on top (navbar spacer trick without constraints)
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        return webView
    }()
    
    private let result = PassthroughSubject<String, Never>()
    private var initialUrlString: String
    private var allowedHost: String
    private let dismissTriggers: [String]
    
    init(initialUrlString: String, allowedHost: String, dismissTriggers: [String] = []) {
        self.initialUrlString = initialUrlString
        self.allowedHost = allowedHost
        self.dismissTriggers = dismissTriggers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(initialUrlString)
    }
    
    private func dismissIfHasToken(_ url: URL?) {
        guard let url = url, let token = url.pathComponents[safe: 2] else { return }
        dismiss(animated: true, completion: {
            self.result.send(token)
        })
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        Logger.log(navigationAction.request.url?.absoluteString, type: .redirectURL)
        dismissIfHasToken(navigationAction.request.url)
        
        guard let host = navigationAction.request.url?.host,
              host == allowedHost else { return decisionHandler(.cancel) }
        
        decisionHandler(.allow)
    }
}
