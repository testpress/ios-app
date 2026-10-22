//
//  SecureContainerView.swift
//  CourseKit
//
//  Created by Antigravity on 21/10/26.
//

import UIKit
import os.log

private let secureLog = OSLog(subsystem: "CourseKit", category: "SecureContainerView")

open class SecureContainerView: UIView {
    
    public let textField = UITextField()
    public private(set) var contentView: UIView?
    public var recordingOverlayMessage: String = Strings.SCREEN_RECORDING_NOT_ALLOWED
    public private(set) var overlayView: UIView?
    public var fallbackErrorMessage: String = Strings.UNABLE_TO_LOAD_PROTECTED_CONTENT
    public private(set) var fallbackOverlayView: UIView?
    private var hasEmbeddedContentView = false
    private var embeddingRetryCount = 0
    private let maxEmbeddingRetries = 10
    
    public var isSecure: Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    public var secureCanvasView: UIView? {
        return textField.subviews.first
    }
    
    public init(contentView: UIView) {
        super.init(frame: .zero)
        setupSecureContainer(with: contentView)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            // If fallback overlay was shown while offscreen or prior to window attachment, reset to allow embed
            if fallbackOverlayView != nil {
                fallbackOverlayView?.removeFromSuperview()
                fallbackOverlayView = nil
                contentView?.isHidden = false
                contentView?.alpha = 1.0
                hasEmbeddedContentView = false
                embeddingRetryCount = 0
            }
            registerScreenCaptureObserver()
            checkScreenCaptureStatus()
            // View is now in window hierarchy - trigger layout to embed content
            setNeedsLayout()
        } else {
            unregisterScreenCaptureObserver()
        }
    }
    
    deinit {
        unregisterScreenCaptureObserver()
    }
    
    public func setupSecureContainer(with contentView: UIView) {
        self.contentView = contentView
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        // 1. Ensure textField is initialized with isSecureTextEntry = true BEFORE querying its subviews
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false // Pass touch/scroll events to child content
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. textField MUST be added as a subview of SecureContainerView first
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // 3. Attempt embedding directly into textField.subviews.first
        embedContentViewIfNeeded()
    }
    
    private func embedContentViewIfNeeded() {
        guard !hasEmbeddedContentView, let contentView = contentView else { return }
        
        // Force layout pass on textField to ensure secure canvas subview is materialized
        textField.layoutIfNeeded()
        
        // Try to get the secure canvas (the private _UITextFieldCanvasView)
        guard let canvas = textField.subviews.first else {
            embeddingRetryCount += 1
            os_log("Secure canvas not ready (attempt %d/%d). Will retry on next layout pass.", log: secureLog, type: .info, embeddingRetryCount, maxEmbeddingRetries)
            
            if embeddingRetryCount >= maxEmbeddingRetries {
                // FAIL-CLOSED: After max retries, log error, hide content, and display user-facing fallback UI
                // Never fall back to adding contentView to self
                os_log("FAIL-CLOSED: Secure canvas unavailable after %d retries. Content hidden for security.", log: secureLog, type: .error, maxEmbeddingRetries)
                contentView.isHidden = true
                contentView.alpha = 0
                hasEmbeddedContentView = true // Prevent further retries
                showFallbackErrorOverlay()
            } else {
                // Schedule next layout pass on the main thread to continue retry loop
                DispatchQueue.main.async { [weak self] in
                    self?.setNeedsLayout()
                }
            }
            return
        }
        
        // contentView (PDFView / WKWebView) MUST be added directly as a subview of
        // textField.subviews.first, NOT directly to textField and NOT to SecureContainerView (self)
        canvas.isUserInteractionEnabled = true
        canvas.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = canvas.bounds
        hasEmbeddedContentView = true
        
        os_log("Secure container: contentView embedded successfully in secure canvas.", log: secureLog, type: .info)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // textField is sized via AutoLayout constraints (top/bottom/leading/trailing = 0)
        // Secure canvas (textField.subviews.first) is sized by UIKit to match textField
        
        // Lazy embed: secure canvas only exists after textField renders in window
        if !hasEmbeddedContentView {
            embedContentViewIfNeeded()
        }
        
        // Frame sync is the source of truth for the content because the secure canvas is a private UIKit view.
        if let canvas = textField.subviews.first,
           let contentView = contentView,
           contentView.superview === canvas {
            contentView.frame = canvas.bounds
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        
        if let fallbackOverlayView = fallbackOverlayView {
            let convertedPoint = convert(point, to: fallbackOverlayView)
            if let hit = fallbackOverlayView.hitTest(convertedPoint, with: event) {
                return hit
            }
            return fallbackOverlayView
        }
        
        if let overlayView = overlayView {
            let convertedPoint = convert(point, to: overlayView)
            if let hit = overlayView.hitTest(convertedPoint, with: event) {
                return hit
            }
            return overlayView
        }
        
        if let contentView = contentView {
            let convertedPoint = convert(point, to: contentView)
            if let hit = contentView.hitTest(convertedPoint, with: event) {
                return hit
            }
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Screen Recording Prevention
    
    public var isScreenCaptured: Bool {
        if #available(iOS 16.0, *), let screen = window?.windowScene?.screen {
            return screen.isCaptured
        }
        return UIScreen.main.isCaptured
    }
    
    public func checkScreenCaptureStatus() {
        handleScreenCapture(isCaptured: isScreenCaptured)
    }
    
    private func registerScreenCaptureObserver() {
        unregisterScreenCaptureObserver()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureDidChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
    
    private func unregisterScreenCaptureObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func screenCaptureDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.checkScreenCaptureStatus()
        }
    }
    
    open func handleScreenCapture(isCaptured: Bool) {
        if isCaptured {
            showRecordingOverlay()
        } else {
            hideRecordingOverlay()
        }
    }
    
    open func showRecordingOverlay() {
        guard overlayView == nil else { return }
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = recordingOverlayMessage
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: blurView.contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: blurView.contentView.trailingAnchor, constant: -20)
        ])
        
        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        overlayView = blurView
    }
    
    open func hideRecordingOverlay() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
    
    // MARK: - Fail-Closed Fallback UI
    
    public func showFallbackErrorOverlay() {
        guard fallbackOverlayView == nil else { return }
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            container.backgroundColor = .systemBackground
        } else {
            container.backgroundColor = .white
        }
        
        let label = UILabel()
        label.text = fallbackErrorMessage
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .darkGray
        }
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24)
        ])
        
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        fallbackOverlayView = container
    }
}
