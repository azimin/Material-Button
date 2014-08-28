//
//  MaterialTouch.swift
//  MaterialSelection
//
//  Created by Alex Zimin on 04/08/14.
//  Copyright (c) 2014 Alex. All rights reserved.
//

import UIKit
import QuartzCore

enum MaterialButtonState {
    case In, Out
}

class MaterialTouch: UIButton {

    private var materialState: MaterialButtonState = .In
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        layer.cornerRadius = 10;

        if let image = self.imageForState(UIControlState.Normal) {
            setImage(image, forState: UIControlState.Highlighted)
            createMask(image)
        }
    }
    
    // MARK: Work with image
    
    override func setImage(image: UIImage!, forState state: UIControlState) {
        super.setImage(image, forState: state)
        
        if (state == .Normal) {
            setImage(image, forState: UIControlState.Highlighted)
            createMask(image)
        }
    }
    
    private func createMask(var image: UIImage!) {
        let maskForSelection = CALayer()
        maskForSelection.contents = image.CGImage
        maskForSelection.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        
        self.layer.mask = maskForSelection
        self.layer.masksToBounds = true
    }
    
    // MARK: Touch methods
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        
        materialState = .In
        
        var touch = touches.anyObject() as UITouch
        var touchPoint = touch.locationInView(self)
        materialAnimationFromPoint(touchPoint)
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
    {
        super.touchesMoved(touches, withEvent: event)
        
        var touch = touches.anyObject() as UITouch
        var touchPoint = touch.locationInView(self)
        
        if CGRectContainsPoint(self.bounds, touchPoint) {
            if materialState != MaterialButtonState.In {
                materialState = .In
                materialAnimationGoAbroadInPoint(touchPoint, state: materialState)
            }
        } else {
            if materialState != MaterialButtonState.Out {
                materialState = .Out
                materialAnimationGoAbroadInPoint(touchPoint, state: materialState)
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)  {
        super.touchesEnded(touches, withEvent: event)
        touchCircle?.removeFromSuperlayer()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        touchCircle?.removeFromSuperlayer()
    }
    
    // MARK: Circle animation methods
    
    var touchCircle: CAShapeLayer!
    
    private func materialAnimationFromPoint(point: CGPoint) {
        touchCircle?.removeFromSuperlayer()
        
        touchCircle = CAShapeLayer()
        let radius = sqrt(bounds.size.width * bounds.size.width + bounds.size.height * bounds.size.height)
        
        touchCircle.backgroundColor = UIColor.blackColor().CGColor
        touchCircle.opacity = 0.25
        touchCircle.frame = CGRectMake(0, 0, radius * 2, radius * 2)
        touchCircle.position = point
        touchCircle.cornerRadius = radius
        
        var animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.3
        
        animation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0))
        animation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        
        touchCircle.addAnimation(animation, forKey: "zoom")
        self.layer.addSublayer(touchCircle)
    }
    
    private func materialAnimationGoAbroadInPoint(point: CGPoint, state: MaterialButtonState) {
        
        touchCircle?.position = point
        
        if (state == MaterialButtonState.Out) {
            touchCircle?.opacity = 0.0
        } else {
            touchCircle?.opacity = 0.35
        }
        
        var transformValueOne = NSValue(CATransform3D: CATransform3DIdentity)
        var transformValueTwo = NSValue(CATransform3D: CATransform3DMakeScale(0.0, 0.0, 1.0))
        var opacityValueOne = NSNumber(float: 0.35)
        var opacityValueTwo = NSNumber(float: 0.0)
        
        var transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        if (state == MaterialButtonState.Out) {
            transformAnimation.fromValue = transformValueOne
            transformAnimation.toValue = transformValueTwo
        } else {
            transformAnimation.fromValue = transformValueTwo
            transformAnimation.toValue = transformValueOne
        }
        
        var opacityAnimation = CABasicAnimation(keyPath: "opacity")
        if (state == MaterialButtonState.Out) {
            opacityAnimation.fromValue = opacityValueOne
            opacityAnimation.toValue = opacityValueTwo
        } else {
            opacityAnimation.fromValue = opacityValueTwo
            opacityAnimation.toValue = opacityValueOne
        }
        
        var animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.3
        animationGroup.animations = [transformAnimation, opacityAnimation]
        
        touchCircle?.addAnimation(animationGroup, forKey: "animation")
    }

}
