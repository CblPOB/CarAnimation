//
//  RoadViewController.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 15/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import UIKit

class RoadViewController: UIViewController {
    
    private var carControlRecognizer: UITapGestureRecognizer?
    private var carView: UIView!
    private let turnArcRadius: Double = 50.0
    private var animationBuilder: CarAnimationBuilder?
    private var angle: Float = 0.0
    private let eps: Float = .pi / 40.0
    private let speed: Float = 70.0
    private let turnSpeed: Float = .pi / 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCarView()
        setupGestureRecognizer()
        animationBuilder = CarAnimationBuilder()
    }
    
    func setupCarView() {
        let viewHeight = view.frame.size.height / 10.0
        let viewWidth = viewHeight * 0.5
        carView = UIView()
        carView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        carView.center = view.center
        carView.backgroundColor = .clear
        let carImageView = UIImageView(image: UIImage(named: "carIcon"))
        carImageView.frame = CGRect(origin: .zero, size: carView.frame.size)
        carView.addSubview(carImageView)
        view.addSubview(carView)
    }
    
    func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        view.addGestureRecognizer(tapRecognizer)
        carControlRecognizer = tapRecognizer
    }
    
    @objc func tapAction(_ sender: UIGestureRecognizer) {
        let newPoint = sender.location(in: view)
        
//        animationBuilder?.buildAnimation(endPoint: newPoint, carCenter: carView.center, carFrame: carView.frame, layer: carView.layer)
        animate(endPoint: newPoint, carCenter: carView.center, carFrame: carView.frame)
        
//
//        UIView.animate(withDuration: 0.2, animations: {
//            self.carView.transform = CGAffineTransform(rotationAngle: self.animationBuilder!.angle(animation: .position, endPoint: newPoint, carCenter: self.carView.center, carFrame: self.carView.frame))
//        }) { (_) in
//            self.carView.center = newPoint;
//        }
    }
    
    func animate(endPoint: CGPoint,  carCenter: CGPoint, carFrame: CGRect) {
        let carFrontPoint = CGPoint(x: carFrame.minX + carFrame.width / 2.0, y: carFrame.minY)
        var carVector = Vector(firstPoint: carCenter, secondPoint: carFrontPoint).rotated(angle: CGFloat(angle))
        var destinationVector = Vector(x: endPoint.x - carCenter.x, y: endPoint.y - carCenter.y)
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
        
        let carVectorPerpendicular = carVector.rotated(angle: newAngleForCarVector)
        let turnCircleCenter = CGPoint(x: CGFloat(carVectorPerpendicular.x) + carCenter.x, y: CGFloat(carVectorPerpendicular.y) + carCenter.y)
        let turnCircleRadius = carVectorPerpendicular.length()
        
        var vectorToCarFromCenter = Vector(x: carCenter.x - turnCircleCenter.x, y: carCenter.y - turnCircleCenter.y)
        
        let carPath = UIBezierPath()
        carPath.move(to: carCenter)
        carPath.addLine(to: CGPoint(x: CGFloat(carVector.x) + carCenter.x, y: CGFloat(carVector.y) + carCenter.y))
        carPath.addLine(to: .zero)
        
        let startAngle = Float(atan2(Double(vectorToCarFromCenter.y), Double(vectorToCarFromCenter.x)))
        var endAngle = startAngle
        var angles = [Float(atan2(Double(carVector.y), Double(carVector.x))) + .pi / 2.0]
        var newPositionX: Float = 0.0
        var newPositionY: Float = 0.0
        var newVector = vectorToCarFromCenter
        while carVector.angle(withVector: destinationVector) > eps {
//            if (step < 0) {
//                newPositionX = turnCircleRadius * tan(endAngle + step) + Float(turnCircleCenter.x)
//                newPositionY = turnCircleRadius * atan(endAngle + step) + Float(turnCircleCenter.y)
//            } else {
//                newPositionX = turnCircleRadius * cosf(endAngle + step) + Float(turnCircleCenter.x)
//                newPositionY = turnCircleRadius * sinf(endAngle + step) + Float(turnCircleCenter.y)
//            }
            newVector = newVector.rotated(angle: CGFloat((clockwise ? eps: -eps)))
            newPositionX = newVector.x + Float(turnCircleCenter.x)
            newPositionY = newVector.y + Float(turnCircleCenter.y)
            let newCarVector = Vector(x: Float(turnCircleCenter.x) - newPositionX, y: Float(turnCircleCenter.y) - newPositionY).rotated(angle: clockwise ? -.pi / 2.0: .pi / 2.0)
            destinationVector = Vector(x: Float(endPoint.x) - newPositionX, y: Float(endPoint.y) - newPositionY)
            carVector = newCarVector
            let angle = carVector.angle(withVector: destinationVector)
            angles.append(clockwise ? angles.last! + eps: angles.last! - eps)
            endAngle += clockwise ? eps: -eps
        }
        
        angles.append(-carVector.angle(withVector: destinationVector))
        
        let angleForTurn = endAngle - startAngle
        let timeInTurn = angleForTurn / turnSpeed
        let timeInRide = Vector(firstPoint: carCenter, secondPoint: endPoint).length() / speed
        
        let path = UIBezierPath()
        path.move(to: carCenter)
        path.addArc(withCenter: turnCircleCenter, radius: CGFloat(turnCircleRadius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise)
        path.addLine(to: endPoint)
        
        let arcAnimation = CAKeyframeAnimation(keyPath: "position")
        arcAnimation.path = path.cgPath
        arcAnimation.duration = Double(timeInTurn + timeInRide)
        arcAnimation.fillMode = .forwards
        arcAnimation.isRemovedOnCompletion = false
        
//        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
//        rotation.values = angles
//        rotation.duration = 2.0
//        rotation.fillMode = .forwards
//        rotation.isRemovedOnCompletion = false

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
//        rotation.values = angles
        rotation.toValue = animationBuilder?.angle(animation: .rotate, endPoint: endPoint, carCenter: carCenter, carFrame: carFrame)
        rotation.duration = Double(timeInTurn)
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        
        angle = Float(atan2(Double(carVector.y), Double(carVector.x))) + .pi / 2.0
        
        CATransaction.setDisableActions(true)
        carView.center = endPoint
        carView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        carView.layer.add(arcAnimation, forKey: nil)
        carView.layer.add(rotation, forKey: nil)
    }
}
