//
//  SecureContainerView.swift
//  CourseKit
//
//  Created by Antigravity on 21/10/26.
//

import UIKit

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
        
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        embedContentViewIfNeeded()
    }
    
    private func embedContentViewIfNeeded() {
        guard !hasEmbeddedContentView, let contentView = contentView else { return }
        
        textField.layoutIfNeeded()
        
        guard let canvas = textField.subviews.first else {
            embeddingRetryCount += 1
            debugPrint("SecureContainerView: Secure canvas not ready (attempt \(embeddingRetryCount)/\(maxEmbeddingRetries)). Will retry on next layout pass.")
            
            if embeddingRetryCount >= maxEmbeddingRetries {
                debugPrint("SecureContainerView: FAIL-CLOSED: Secure canvas unavailable after \(maxEmbeddingRetries) retries. Content hidden for security.")
                contentView.isHidden = true
                contentView.alpha = 0
                hasEmbeddedContentView = true
                showFallbackErrorOverlay()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.setNeedsLayout()
                }
            }
            return
        }
        
        canvas.isUserInteractionEnabled = true
        canvas.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = canvas.bounds
        hasEmbeddedContentView = true
        
        debugPrint("SecureContainerView: contentView embedded successfully in secure canvas.")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if !hasEmbeddedContentView {
            embedContentViewIfNeeded()
        }
        
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
