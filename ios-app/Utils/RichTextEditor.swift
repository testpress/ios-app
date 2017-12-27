//
//  RichTextEditor.swift
//  ios-app
//
//  Copyright © 2017 Testpress. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
// Reference:
// https://gist.github.com/fabfelici
// https://medium.com/@fab.felici/rich-text-editor-for-ios-using-wkwebview-440d88d73bbf
//

import WebKit

public protocol RichTextEditorDelegate: class {
    func heightDidChange(_ editor: RichTextEditor, heightDidChange height: CGFloat)
}

fileprivate class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

public class RichTextEditor: UIView, WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {

    private static let textDidChange = "textDidChange"
    private static let heightDidChange = "heightDidChange"
    
    public var defaultHeight: CGFloat = 40 {
        didSet {
            if !editorView.isLoading {
                updateMinimumHeight()
            }
        }
    }
    public weak var delegate: RichTextEditorDelegate?
    public var height: CGFloat!

    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    private var textToLoad: String?
    public var text: String? {
        get {
            return textToLoad
        }
        set {
            guard let text = newValue else { return }
            if editorView.isLoading {
                textToLoad = text
            } else {
                editorView.evaluateJavaScript(
                    "richeditor.insertText(\"\(text.htmlEscapeQuotes)\");", completionHandler: nil)
                
                placeholderLabel.isHidden = !text.htmlToPlainText.isEmpty
            }
        }
    }

    private var editorView: WKWebView!
    private let placeholderLabel = UILabel()

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        initEditor()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initEditor()
    }
    
    public func initEditor() {
        height = defaultHeight
        placeholderLabel.textColor = UIColor.lightGray.withAlphaComponent(0.65)
        placeholderLabel.font = placeholderLabel.font.withSize(15)
        
        guard let scriptPath = Bundle.main.path(forResource: "RichTextEditor", ofType: "js"),
            let scriptContent =
                try? String(contentsOfFile: scriptPath, encoding: String.Encoding.utf8),
            let htmlPath = Bundle.main.path(forResource: "RichTextEditor", ofType: "html"),
            let html = try? String(contentsOfFile: htmlPath, encoding: String.Encoding.utf8)
            else { fatalError("Unable to find javscript/html for text editor") }
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(
            WKUserScript(source: scriptContent,
                         injectionTime: .atDocumentEnd,
                         forMainFrameOnly: true
            )
        )
        
        editorView = WKWebView(frame: .zero, configuration: configuration)
        
        [RichTextEditor.textDidChange, RichTextEditor.heightDidChange].forEach {
            configuration.userContentController.add(WeakScriptMessageHandler(delegate: self), name: $0)
        }
        
        editorView.navigationDelegate = self
        editorView.isOpaque = false
        editorView.backgroundColor = .clear
        editorView.scrollView.isScrollEnabled = false
        editorView.scrollView.showsHorizontalScrollIndicator = false
        editorView.scrollView.showsVerticalScrollIndicator = false
        editorView.scrollView.bounces = false
        editorView.scrollView.isScrollEnabled = false
        editorView.scrollView.delegate = self
        
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: -3),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        addSubview(editorView)
        editorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            editorView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            editorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            editorView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        editorView.loadHTMLString(html, baseURL: nil)
    }
    
    public func updateMinimumHeight() {
        editorView.evaluateJavaScript("setEditorMinimumHeight(\(defaultHeight));",
            completionHandler: nil)
    }

    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        
        switch message.name {
        case RichTextEditor.textDidChange:
            guard let body = message.body as? String else { return }
            let bodyText = body.htmlToPlainText
            placeholderLabel.isHidden = !bodyText.isEmpty
            textToLoad =
                !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? body : ""
            
        case RichTextEditor.heightDidChange:
            guard let height = message.body as? CGFloat else { return }
            self.height = height > defaultHeight ? height + 20 : defaultHeight
            delegate?.heightDidChange(self, heightDidChange: self.height)
        default:
            break
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let textToLoad = textToLoad {
            self.textToLoad = nil
            text = textToLoad
        }
        updateMinimumHeight()
    }

    public func viewForZooming(in: UIScrollView) -> UIView? {
        return nil
    }

}

fileprivate extension String {

    var htmlToPlainText: String {
        return [
            ("(<[^>]*>)|(&\\w+;)", " "),
            ("[ ]+", " ")
        ].reduce(self) {
            try! $0.replacing(pattern: $1.0, with: $1.1)
        }.resolvedHTMLEntities
    }

    var resolvedHTMLEntities: String {
        return self
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    func replacing(pattern: String, with template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
    }

    var htmlEscapeQuotes: String {
        return [
            ("\"", "\\\""),
            ("“", "&quot;"),
            ("\r", "\\r"),
            ("\n", "\\n")
        ].reduce(self) {
            return $0.replacingOccurrences(of: $1.0, with: $1.1)
        }
    }
}
