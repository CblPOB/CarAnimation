//
//  AnimationBuilder.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 23/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import UIKit

class AnimationBuilder: CarAnimating {
    func animation(dataObjects: [AnimationParametersDataObject]?, delegate: CAAnimationDelegate?) -> CarAnimationObject? {
        
        guard let dataObjects = dataObjects else {
            return nil
        }
        
        var animations = [CAAnimation]()
        var endPosition: CGPoint = .zero
        var endAngle: CGFloat = 0.0
        
        for dataObject in dataObjects {
            switch dataObject.type {
            case let .positionWithNaturalTurn(start, end, arcCenter, arcRadius, startAngle, endAngle, clockwise):
                let animation = buildPositionWithNaturalTurnAnimation(start: start, destination: end, arcCenter: arcCenter, arcRadius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
                animation.duration = dataObject.duration
                animation.delegate = delegate
                endPosition = end
                animations.append(animation)
                break
            case let .rotate(startAngle, rotateAngle):
                let animation = buildRotationAnimation(startAngle: startAngle, endAngle: rotateAngle)
                animation.duration = dataObject.duration
                animations.append(animation)
                endAngle = CGFloat(rotateAngle)
                break
            }
        }
        
        return CarAnimationObject(animations: animations, endPosition: endPosition, endAngle: endAngle)
    }
    
    private func buildPositionWithNaturalTurnAnimation(start: CGPoint, destination: CGPoint, arcCenter: CGPoint, arcRadius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) -> CAAnimation {
        let path = UIBezierPath()
        path.move(to: start)
        path.addArc(withCenter: arcCenter, radius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        path.addLine(to: destination)
        
        let arcAnimation = CAKeyframeAnimation(keyPath: "position")
        arcAnimation.path = path.cgPath
        arcAnimation.fillMode = .forwards
        arcAnimation.isRemovedOnCompletion = false
        return arcAnimation
    }
    
    private func buildRotationAnimation(startAngle: Float, endAngle: Float) -> CAAnimation {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = startAngle
        rotation.toValue = endAngle
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        return rotation
    }
}
