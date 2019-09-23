//
//  CarView.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 23/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import UIKit

class CarView: UIView {
    func configure(animationObject: CarAnimationObject?) {
        guard let animationObject = animationObject else {
            return
        }
        
        CATransaction.setDisableActions(true)
        center = animationObject.endPosition
        transform = CGAffineTransform(rotationAngle: animationObject.endAngle)
        
        for animation in animationObject.animations {
            layer.add(animation, forKey: nil)
        }
    }
}
