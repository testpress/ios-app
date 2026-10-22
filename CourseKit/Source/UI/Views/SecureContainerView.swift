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
    public var recordingOverlayMessage: String = "Screen recording is not allowed."
    public private(set) var overlayView: UIView?
    private var hasEmbeddedContentView = false
    
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
    
    public func setupSecureContainer(with contentView: UIView) {
        self.contentView = contentView
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        // 1. Configure internal UITextField for secure rendering without intercepting touches
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false // Pass touch/scroll events to child content
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // NOTE: Do NOT embed contentView here. The secure canvas (textField.subviews.first)
        // is created LAZILY by UIKit when the textField is actually rendered in a window.
        // We'll embed contentView in layoutSubviews once canvas exists.
    }
    
    private func embedContentViewIfNeeded() {
        guard !hasEmbeddedContentView, let contentView = contentView else { return }
        
        // FAIL-CLOSED: Secure canvas must exist
        guard let canvas = textField.subviews.first else {
            // Canvas not ready yet - will retry on next layoutSubviews
            return
        }
        
        canvas.isUserInteractionEnabled = true
        canvas.addSubview(contentView)
        // Use manual frame layout (canvas is private UIKit view, not AutoLayout-friendly)
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = canvas.bounds
        hasEmbeddedContentView = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // textField is sized via AutoLayout constraints (top/bottom/leading/trailing = 0)
        // Secure canvas (textField.subviews.first) is sized by UIKit to match textField
        
        // Lazy embed: secure canvas only exists after textField renders in window
        if !hasEmbeddedContentView {
            embedContentViewIfNeeded()
        }
        
        // Sync contentView frame to canvas bounds (canvas resizes with textField)
        if let canvas = textField.subviews.first,
           let contentView = contentView,
           contentView.superview === canvas {
            contentView.frame = canvas.bounds
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        
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
}
