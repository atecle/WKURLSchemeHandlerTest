//
//  ViewController.swift
//  WKURLSchemeHandlerTest
//
//  Created by Tecle, Adam on 7/9/19.
//  Copyright © 2019 Tecle, Adam. All rights reserved.
//

import UIKit
import WebKit

enum Constant {
    static let articleHTML = """
    <!DOCTYPE html>
    <html>
        <head>
            <script src="proxy://myscript.js"></script>
        </head>
        <body>
            <h1> hello world </h1>
    <   /body>
    </html>
"""

    static let articleURLString = "proxy://some.test"

    static let scriptURLString = "proxy://myscript.js"

    static let script = """
    console.log("This is being printed from a JS snippet loaded via WKURLSchemeHandler")
"""
}

/// A toy example to demonstrate how to use WKURLSchemeHandler as a proxy
/// for a webpage's requests for external resources.
class ViewController: UIViewController {

    let webView: WKWebView
    let schemeHandler: SchemeHandler

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let config = WKWebViewConfiguration()
        self.schemeHandler = SchemeHandler(config)
        webView = WKWebView(frame: .zero, configuration: config)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.frame = self.view.bounds

        /// We must initially load the webpage using our custom scheme.
        webView.load(URLRequest(url: URL(string: "proxy://some.test")!))
    }

}

class SchemeHandler: NSObject, WKURLSchemeHandler {

    init(_ config: WKWebViewConfiguration) {
        super.init()

        config.setURLSchemeHandler(self, forURLScheme: "proxy")
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Processing request for URL: \(urlSchemeTask.request.url?.absoluteString ?? "")")
        guard let urlString = urlSchemeTask.request.url?.absoluteString else {
            return
        }

        if urlString == Constant.articleURLString, let data = Constant.articleHTML.data(using: .utf8) {
            let response = URLResponse(url: URL(string: "some")!, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: "utf-8")
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } else if urlString == Constant.scriptURLString, let data = Constant.script.data(using: .utf8) {
            let response = URLResponse(url: URL(string: "some")!, mimeType: "application/javascript", expectedContentLength: data.count, textEncodingName: "utf-8")
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }

    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("Stopping request for URL: \(urlSchemeTask.request.url?.absoluteString ?? ""))")
    }

}
