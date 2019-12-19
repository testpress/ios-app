//
//  VideoPlayerSlider.swift
//  ios-app
//
//  Created by Karthik raja on 12/9/19.
//  Copyright © 2019 Testpress. All rights reserved.
//

import UIKit

class VideoSlider: UIControl {
    var currentPosition : Float = 0.0
    {
        didSet
        {
            updateLayers()
        }
    }
    
    var currentBuffer : Float = 0.0
    {
        didSet
        {
            updateLayers()
        }
    }
    
    var backgroundLayerColor : UIColor = UIColor.darkGray
    var progressLayerColor : UIColor = Colors.getRGB(Colors.PRIMARY)
    var bufferLayerColor : UIColor = UIColor.lightGray
    var positionRingLayerColor : UIColor = Colors.getRGB(Colors.PRIMARY)
    
    private var backgroundLayer : CAShapeLayer!
    private var progressLayer : CAShapeLayer!
    private var bufferLayer : CAShapeLayer!
    private var positionRingLayer : CAShapeLayer!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func draw(_ rect: CGRect)
    {
        updateLayers()
    }
    
    private func initialize()
    {
        self.backgroundColor = UIColor.clear
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        backgroundLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: self.frame.size.width, height: self.frame.size.height / 2.0)).cgPath
        backgroundLayer.fillColor = backgroundLayerColor.cgColor
        backgroundLayer.backgroundColor = UIColor.clear.cgColor
        
        progressLayer = CAShapeLayer()
        progressLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        bufferLayer = CAShapeLayer()
        bufferLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        positionRingLayer = CAShapeLayer()
        positionRingLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(bufferLayer)
        self.layer.addSublayer(progressLayer)
        self.layer.addSublayer(positionRingLayer)
        
        updateLayers()
    }
    
    private func updateLayers()
    {
        updateProgressLine()
        updateBufferLine()
        updatePositionRing()
    }
    
    private func updateProgressLine()
    {
        var w = (self.frame.size.width * CGFloat(currentPosition)) + self.frame.size.height / 4
        
        if w > self.frame.size.width
        {
            w = self.frame.size.width
        }
        
        progressLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: w, height: self.frame.size.height / 2)).cgPath
        progressLayer.fillColor = progressLayerColor.cgColor
        progressLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    private func updateBufferLine()
    {
        let w = self.frame.size.width * CGFloat(currentBuffer)
        
        bufferLayer.path = UIBezierPath(rect: CGRect(x: 0, y: (self.frame.size.height / 2) - self.frame.size.height / 4, width: w, height: self.frame.size.height / 2)).cgPath
        bufferLayer.fillColor = bufferLayerColor.cgColor
        bufferLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    private func updatePositionRing()
    {
        var _x = self.frame.size.width * CGFloat(currentPosition)
        
        if _x > self.frame.size.width - self.frame.size.height
        {
            _x = self.frame.size.width - self.frame.size.height
        }
        
        positionRingLayer.path = UIBezierPath(ovalIn: CGRect(x: _x, y: 0, width: self.frame.size.height, height: self.frame.size.height)).cgPath
        positionRingLayer.fillColor = positionRingLayerColor.cgColor
        positionRingLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        super.continueTracking(touch, with: event)
        let point = touch.location(in: self)
        
        if (point.x < self.frame.size.width) && (point.x > 0)
        {
            currentPosition = Float(point.x / self.frame.size.width)
            self.setNeedsDisplay()
        }
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?){
        super.endTracking(touch, with: event)
        sendActions(for: .valueChanged)
    }
}
