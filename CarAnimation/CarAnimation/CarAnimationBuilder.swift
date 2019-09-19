//
//  CarAnimationBuilder.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 16/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import UIKit
import Accelerate
import simd

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
    
    func angle(animation: AnimationType, endPoint: CGPoint,  carCenter: CGPoint, carFrame: CGRect) -> CGFloat {
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
        
        var angleToReachDestination: CGFloat = 0.0
        
        if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees < 90 {

            return angleWithDestination
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees < 90 {

            return -angleWithDestination
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees >= 90 {

            return -angleWithDestination
            
        } else if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees >= 90 {
            return angleWithDestination
        }
        
        return 0
    }
    
    func angle(endPoint: CGPoint, carCenter: CGPoint, carVector: Vector) -> Float {
//        let carVector = CGPoint(x: carFrame.minX + carFrame.width / 2.0 - carCenter.x, y: carFrame.minY - carCenter.y)
//        let transform = CGAffineTransform(rotationAngle: -.pi / 2.0)
        let destinationVector = Vector(x: endPoint.x - carCenter.x, y: endPoint.y - carCenter.y)
//        let perpendicularVectorX = transform.a * destinationVector.x + transform.c * destinationVector.y + transform.tx
//        let perpendicularVectorY = transform.b * destinationVector.x + transform.d * destinationVector.y + transform.ty
        let perpendicularVector = destinationVector.rotated(angle: -.pi / 2.0)
        let angleWithPerpendicular = carVector.angle(withVector: perpendicularVector)
        let angleWithDestination = carVector.angle(withVector: destinationVector)
        
        let angleWithPerpendecularDegrees = angleWithPerpendicular * 180 / .pi
        let angleWithDestinationDegrees = angleWithDestination * 180 / .pi
        
//        var angleToReachDestination: CGFloat = 0.0
        
        if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees < 90 {
            
            return angleWithDestination
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees < 90 {
            
            return -angleWithDestination
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees >= 90 {
            
            return -angleWithDestination
            
        } else if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees >= 90 {
            return angleWithDestination
        }
        
        return 0
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
    
    
    func buildAnimation(endPoint: CGPoint,  carCenter: CGPoint, carFrame: CGRect, layer: CALayer) {
//        let carVector = Vector(x: carFrame.minX + carFrame.width / 2.0 - carCenter.x, y: carFrame.minY - carCenter.y)
//        let transform = CGAffineTransform(rotationAngle: -.pi / 2.0)
//        let destinationVector = CGPoint(x: endPoint.x - carCenter.x, y: endPoint.y - carCenter.y)
//        let perpendicularVectorX = transform.a * destinationVector.x + transform.c * destinationVector.y + transform.tx
//        let perpendicularVectorY = transform.b * destinationVector.x + transform.d * destinationVector.y + transform.ty
//        let perpendicularVector = CGPoint(x: perpendicularVectorX, y: perpendicularVectorY)
//        let angleWithPerpendicular = calculateAngle(firstVector: carVector, secondVector: perpendicularVector)
//        let angleWithDestination = calculateAngle(firstVector: carVector, secondVector: destinationVector)
//
//        let angleWithPerpendecularDegrees = angleWithPerpendicular * 180 / .pi
//        let angleWithDestinationDegrees = angleWithDestination * 180 / .pi
//
//        var newAngleForCarVector: CGFloat = 0.0
//
//        if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees < 90 {
//            newAngleForCarVector = .pi / 2.0
//
//        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees < 90 {
//            newAngleForCarVector = -.pi / 2.0
//
//        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees >= 90 {
//            newAngleForCarVector = -.pi / 2.0
//
//        } else if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees >= 90 {
//            newAngleForCarVector = .pi / 2.0
//        }
//
//        let carRotateTransform = CGAffineTransform(rotationAngle: newAngleForCarVector)
//        let carVectorPerpendicularX = (carRotateTransform.a * carVector.x + carRotateTransform.c * carVector.y + carRotateTransform.tx) * 2.0
//        let carVectorPerpendicularY = (carRotateTransform.b * carVector.x + carRotateTransform.d * carVector.y + carRotateTransform.ty) * 2.0
//
//        let turnCircleCenter = CGPoint(x: carVectorPerpendicularX + carCenter.x, y: carVectorPerpendicularY + carCenter.y)
//        let r = sqrt(pow(turnCircleCenter.x - carCenter.x, 2) + pow(turnCircleCenter.y - carCenter.y, 2))
//        let vectorForCalculatingAngle = CGPoint(x: 10, y: 0)
//        let startAngle = calculateAngle(firstVector: vectorForCalculatingAngle, secondVector: CGPoint(x: carCenter.x - turnCircleCenter.x, y: carCenter.y - turnCircleCenter.y))
        
        
        
        
//        let tempCircleCenter = CGPoint(x: (turnCircleCenter.x + endPoint.x) / 2.0, y: (turnCircleCenter.y + endPoint.y) / 2.0)
//
//
//        let tmpR = sqrt(pow(tempCircleCenter.x - endPoint.x, 2) + pow(tempCircleCenter.y - endPoint.y, 2))
//        let r = sqrt(pow(turnCircleCenter.x - carCenter.x, 2) + pow(turnCircleCenter.y - carCenter.y, 2))
//        let a = 2 * (turnCircleCenter.x - tempCircleCenter.x)
//        let b = 2 * (turnCircleCenter.y - tempCircleCenter.y)
//        var c = pow(tempCircleCenter.x, 2) - pow(turnCircleCenter.x, 2) + pow(tempCircleCenter.y, 2) - pow(turnCircleCenter.y, 2) - tmpR*tmpR + r*r
//
//        let x0 = -((a * c) / (pow(a, 2) + pow(b, 2)))
//        let y0 = -((b * c) / (pow(a, 2) + pow(b, 2)))
//        let d = sqrt(r*r - (pow(c, 2) / (pow(a, 2) + pow(b, 2))))
//        let mult = sqrt(d*d / (pow(a, 2) + pow(b, 2)))
//        let firstPoint = CGPoint(x: x0 + b * mult, y: y0 - a * mult)
//        let secondPoint = CGPoint(x: x0 - b * mult, y: y0 + a * mult)
//
//        let firstPointAngle = calculateAngle(firstVector: carVector, secondVector: CGPoint(x: firstPoint.x - carCenter.x, y: firstPoint.y - carCenter.y))
//        let secondPointAngle = calculateAngle(firstVector: carVector, secondVector: CGPoint(x: secondPoint.x - carCenter.x, y: secondPoint.y - carCenter.y))

//        let finishAngle: CGFloat = 0.0
//        if firstPointAngle <= secondPointAngle {
//            finishAngle = calculateAngle(firstVector: CGPoint(x: firstPoint.x - turnCircleCenter.x, y: firstPoint.y - turnCircleCenter.y),
//                                         secondVector: <#T##CGPoint#>)
//        } else {
//            
//        }
    }
}
