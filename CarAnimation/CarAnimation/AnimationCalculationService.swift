//
//  AnimationCalculationService.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 23/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

class AnimationCalculationService: CarAnimationCalculating {
    private var angle: Float = 0.0
    private let eps: Float = .pi / 40.0
    private let speed: Float = 150.0
    private let turnSpeed: Float = .pi
    private let simpleRotationDuration = 0.2
    
    func calculateAnimation(start: CGPoint, destination: CGPoint, carFrame: CGRect, type: AnimationMethod) -> [AnimationParametersDataObject]? {
        switch type {
        case .difficult:
            return calculateDifficultAnimation(start: start, destination: destination, carFrame: carFrame)
        case .simple:
            return calculateSimpleAnimation(start: start, destination: destination)
        }
    }
    
    func calculateDifficultAnimation(start: CGPoint, destination: CGPoint, carFrame: CGRect) -> [AnimationParametersDataObject]? {
        let carFrontPoint = CGPoint(x: carFrame.minX + carFrame.width / 2.0, y: carFrame.minY)
        var carVector = Vector(firstPoint: start, secondPoint: carFrontPoint).rotated(angle: CGFloat(angle)) // вектор повернут на угол, заданный предыдущим поворотом
        var destinationVector = Vector(x: destination.x - start.x, y: destination.y - start.y)
        
        /// второй верктор, перпендикулярный вектору к конечной точке, нужен для того, чтобы по двум углам (вектора машины с конеченой точкой и с destinationVectorPerpendicular) определить, в какую сторону направлен вектор автомобиля относительно endPoint и затем на основе этого выбрать, в какую сторону нужно отложить окружность для поворота
        
        let destinationVectorPerpendicular = destinationVector.rotated(angle: -.pi / 2.0)
        let angleWithPerpendicular = destinationVectorPerpendicular.angle(withVector: carVector)
        let angleWithDestination = destinationVector.angle(withVector: carVector)
        let angleWithPerpendicularDegrees = angleWithPerpendicular * 180 / .pi
        let angleWithDestinationDegrees = angleWithDestination * 180 / .pi
        
        
        var newAngleForCarVector: CGFloat = 0.0
        var clockwise = false
        if angleWithPerpendicularDegrees < 90, angleWithDestinationDegrees < 90 {
            newAngleForCarVector = .pi / 2.0
            clockwise = true
        } else if angleWithPerpendicularDegrees >= 90, angleWithDestinationDegrees < 90 {
            newAngleForCarVector = -.pi / 2.0
        } else if angleWithPerpendicularDegrees >= 90, angleWithDestinationDegrees >= 90 {
            newAngleForCarVector = -.pi / 2.0
        } else if angleWithPerpendicularDegrees < 90, angleWithDestinationDegrees >= 90 {
            newAngleForCarVector = .pi / 2.0
            clockwise = true
        }
        
        let carVectorPerpendicular = carVector.rotated(angle: newAngleForCarVector) /// для получения координат центра окружности используется вектор, перпендикулярный вектору автомобиля
        let turnCircleCenter = CGPoint(x: CGFloat(carVectorPerpendicular.x) + start.x, y: CGFloat(carVectorPerpendicular.y) + start.y)
        let turnCircleRadius = carVectorPerpendicular.length()
        
        let vectorToCarFromCenter = Vector(x: start.x - turnCircleCenter.x, y: start.y - turnCircleCenter.y)
        
        let startAngle = Float(atan2(Double(vectorToCarFromCenter.y), Double(vectorToCarFromCenter.x)))
        var endAngle = startAngle
        var newPositionX: Float = 0.0
        var newPositionY: Float = 0.0
        var newVector = vectorToCarFromCenter
        
        /// поиск угла, до которого будет происходить поворот по дуге
        
        while carVector.angle(withVector: destinationVector) >= 2 * eps {
            newVector = newVector.rotated(angle: CGFloat((clockwise ? eps: -eps)))
            newPositionX = newVector.x + Float(turnCircleCenter.x)
            newPositionY = newVector.y + Float(turnCircleCenter.y)
            let newCarVector = Vector(x: Float(turnCircleCenter.x) - newPositionX, y: Float(turnCircleCenter.y) - newPositionY).rotated(angle: clockwise ? -.pi / 2.0: .pi / 2.0)
            destinationVector = Vector(x: Float(destination.x) - newPositionX, y: Float(destination.y) - newPositionY)
            carVector = newCarVector
            endAngle += clockwise ? eps: -eps
        }
        
        let angleForTurn = endAngle - startAngle
        let timeInTurn = angleForTurn / turnSpeed
        let timeInRide = Vector(firstPoint: start, secondPoint: destination).length() / speed
        
        /// поиск кратчайшего поворота до конечного угла
        
        let firstValue = abs((Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0)) - angle)
        let secondValue = abs((Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0) - 2 * .pi) - angle)
        var endValue: Float = 0.0
        if firstValue <= secondValue {
            endValue = Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0)
        } else {
            endValue = Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0) - 2 * .pi
        }
        
        let animationRotateObject = AnimationParametersDataObject(type: .rotate(startAngle: angle, rotateAngle: endValue), duration: Double(timeInTurn + timeInRide))
        let animationPositionObject = AnimationParametersDataObject(type: .positionWithNaturalTurn(start: start, end: destination, arcCenter: turnCircleCenter, arcRadius: CGFloat(turnCircleRadius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise), duration: Double(timeInTurn + timeInRide))
        angle = endValue
        return [animationRotateObject, animationPositionObject]
    }
    
    
    func calculateSimpleAnimation(start: CGPoint, destination: CGPoint) -> [AnimationParametersDataObject]? {
        let destinationVector = Vector(x: destination.x - start.x, y: destination.y - start.y)
        let rotateAngle = Float(atan2(Double(destinationVector.y), Double(destinationVector.x))) + Float(.pi / 2.0)
        let timeInRide = Vector(firstPoint: start, secondPoint: destination).length() / speed
        let animationPositionObject = AnimationParametersDataObject(type: .simplePosition(start: start, end: destination), duration: Double(timeInRide))
        let animationRotationObject = AnimationParametersDataObject(type: .rotate(startAngle: angle, rotateAngle: rotateAngle), duration: simpleRotationDuration)
        angle = rotateAngle
        return [animationPositionObject, animationRotationObject]
    }
}
