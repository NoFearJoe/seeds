//
//  GradientView.swift
//  Seeds
//
//  Created by Илья Харабет on 15.06.2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import UIKit

@IBDesignable final class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .white {
        didSet { updateColors() }
    }
    @IBInspectable var endColor: UIColor = .white {
        didSet { updateColors() }
    }
    @IBInspectable var startLocation: CGFloat = 0 {
        didSet { updateLocations() }
    }
    @IBInspectable var endLocation: CGFloat = 1 {
        didSet { updateLocations() }
    }
    
    @IBInspectable var startPoint: CGPoint = .zero {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0, y: 1) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLocations()
    }
}
