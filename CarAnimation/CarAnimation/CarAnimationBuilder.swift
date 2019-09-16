//
//  CarAnimationBuilder.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 16/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import UIKit

enum AnimationType {
    case position, rotate
}

class CarAnimationBuilder {
    
    private var carAngle: CGFloat = 0.0
    private let speed: CGFloat = 100.0
    
    func build(animation: AnimationType, endPoint: CGPoint,  carCenter: CGPoint, carFrame: CGRect, layer: CALayer) -> CAAnimation {
        let carVector = CGPoint(x: carFrame.minX + carFrame.width / 2.0 - carCenter.x, y: carFrame.minY - carCenter.y)
        let transform = CGAffineTransform(rotationAngle: -.pi / 2.0)
        let destinationVector = CGPoint(x: endPoint.x - carCenter.x, y: endPoint.y - carCenter.y)
        let perpendicularVectorX = transform.a * destinationVector.x + transform.c * destinationVector.y + transform.tx
        let perpendicularVectorY = transform.b * destinationVector.x + transform.d * destinationVector.y + transform.ty
        let perpendicularVector = CGPoint(x: perpendicularVectorX, y: perpendicularVectorY)
        let angleWithPerpendicular = calculateAngle(firstVector: carVector, secondVector: perpendicularVector)
        let angleWithDestination = calculateAngle(firstVector: carVector, secondVector: destinationVector)
        
        let angleWithPerpendecularDegrees = angleWithPerpendicular * 180 / .pi
        let angleWithDestinationDegrees = angleWithDestination * 180 / .pi
        
        var newAngleForCarVector: CGFloat = 0.0
        var angleToReachDestination: CGFloat = 0.0
        
        if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees < 90 {
            newAngleForCarVector = angleWithDestination
            angleToReachDestination = angleWithDestination
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees < 90 {
            newAngleForCarVector = -angleWithDestination
            angleToReachDestination = -angleWithDestination
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees >= 90 {
            newAngleForCarVector = -(.pi - angleWithPerpendicular)
            angleToReachDestination = -angleWithDestination
            
        } else if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees >= 90 {
            newAngleForCarVector = angleWithPerpendicular
            angleToReachDestination = angleWithDestination
        }
        
        newAngleForCarVector /= 2.0
        
        let transformForNewCarPosition = CGAffineTransform(rotationAngle: newAngleForCarVector)
        let newCarCoordinateX = 1.5 * (transformForNewCarPosition.a * carVector.x + transformForNewCarPosition.c * carVector.y + transformForNewCarPosition.tx) + carCenter.x
        let newCarCoordinateY = 1.5 * (transformForNewCarPosition.b * carVector.x + transformForNewCarPosition.d * carVector.y + transformForNewCarPosition.ty) + carCenter.y
        
        let path = UIBezierPath()
        path.move(to: carCenter)
        path.addQuadCurve(to: endPoint, controlPoint: CGPoint(x: newCarCoordinateX, y: newCarCoordinateY))
        
        let animationDuration = calculateDestination(firstPoint: carCenter, secondPoint: endPoint) / speed
        
        let arc = arcAnimation(path: path.cgPath, duration: animationDuration)
        let rotation = rotateAnimation(angles: [0, newAngleForCarVector, angleToReachDestination], duration: animationDuration)
        
        carAngle += angleToReachDestination

        CATransaction.setDisableActions(true)
        layer.position = endPoint
        layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: carAngle))
        layer.add(arc, forKey: nil)
//        layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        layer.add(rotation, forKey: nil)
        switch animation {
        case .position:
            return arcAnimation(path: path.cgPath, duration: animationDuration)
        case .rotate:
            return rotateAnimation(angles: [carAngle, carAngle + newAngleForCarVector, carAngle + angleToReachDestination], duration: animationDuration)
        }
    }
    
    private func arcAnimation(path: CGPath, duration: CGFloat) -> CAKeyframeAnimation {
        let arcAnimation = CAKeyframeAnimation(keyPath: "position")
        arcAnimation.path = path
        arcAnimation.duration = Double(duration)
        arcAnimation.fillMode = .forwards
        arcAnimation.isRemovedOnCompletion = false
        return arcAnimation
    }
    
    private func rotateAnimation(angles: [CGFloat], duration: CGFloat) -> CAKeyframeAnimation {

        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
//        rotation.keyTimes = [0,0.4,1]
        rotation.values = angles
        rotation.duration = Double(duration) * 0.6
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        return rotation
    }
    
    private func calculateAngle(firstVector: CGPoint, secondVector: CGPoint) -> CGFloat {
        return acos((firstVector.x * secondVector.x + firstVector.y * secondVector.y) / (sqrt(pow(firstVector.x, 2) + pow(firstVector.y, 2)) * sqrt(pow(secondVector.x, 2) + pow(secondVector.y, 2))))
    }
    
    private func calculateDestination(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        return sqrt(pow(secondPoint.x - firstPoint.x, 2) + pow(secondPoint.y - firstPoint.y, 2))
    }
}
