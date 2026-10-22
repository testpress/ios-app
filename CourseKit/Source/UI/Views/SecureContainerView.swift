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
        
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
        
        // 2. Embed the child view into the secure canvas container (textField.subviews.first)
        let canvas = textField.subviews.first ?? self
        canvas.isUserInteractionEnabled = true
        canvas.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Constrain child content view to secure container edges (Top, Bottom, Leading, Trailing) with 0 constant
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: canvas.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: canvas.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: canvas.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: canvas.trailingAnchor)
        ])
        
        // 4. Immediately ensure non-zero frame dimensions
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = bounds
        if let canvas = textField.subviews.first {
            canvas.frame = textField.bounds
            if let contentView = contentView, contentView.superview === canvas {
                contentView.frame = canvas.bounds
            }
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
