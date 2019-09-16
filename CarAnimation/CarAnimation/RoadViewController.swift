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
//        carView.layer.add(arcAnimation(tapPoint: newPoint), forKey: nil)
//        let positionAnimation = CarAnimationBuilder.build(animation: .position, endPoint: newPoint, carCenter: carView.center, carFrame: carView.frame)
//        let rotateAnimation = CarAnimationBuilder.build(animation: .rotate, endPoint: newPoint, carCenter: carView.center, carFrame: carView.frame)
//        carView.layer.add(positionAnimation, forKey: nil)
//        carView.layer.add(rotateAnimation, forKey: nil)
        animationBuilder?.build(animation: .position, endPoint: newPoint, carCenter: carView.center, carFrame: carView.frame, layer: carView.layer)
    }
    
    func calculateAngle(firstVector: CGPoint, secondVector: CGPoint) -> CGFloat {
        return acos((firstVector.x * secondVector.x + firstVector.y * secondVector.y) / (sqrt(pow(firstVector.x, 2) + pow(firstVector.y, 2)) * sqrt(pow(secondVector.x, 2) + pow(secondVector.y, 2))))
    }
    
    func arcAnimation(tapPoint: CGPoint) -> CAKeyframeAnimation {
        let path = UIBezierPath()
        path.move(to: carView.center)
        path.addQuadCurve(to: tapPoint, controlPoint: calculateArcPoint(finishLocation: tapPoint))
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path.cgPath
        pathAnimation.duration = 2.0
        return pathAnimation
    }
    
    func calculateArcPoint(finishLocation: CGPoint) -> CGPoint {
        let currentPoint = carView.center
        let carVector = CGPoint(x: carView.frame.minX + carView.frame.width / 2.0 - currentPoint.x, y: carView.frame.minY - currentPoint.y)
        let transform = CGAffineTransform(rotationAngle: -.pi / 2.0)
        let destinationVector = CGPoint(x: finishLocation.x - currentPoint.x, y: finishLocation.y - currentPoint.y)
        let perpendicularVectorX = transform.a * destinationVector.x + transform.c * destinationVector.y + transform.tx
        let perpendicularVectorY = transform.b * destinationVector.x + transform.d * destinationVector.y + transform.ty
        let perpendicularVector = CGPoint(x: perpendicularVectorX, y: perpendicularVectorY)
        let angleWithPerpendicular = calculateAngle(firstVector: carVector, secondVector: perpendicularVector)
        let angleWithDestination = calculateAngle(firstVector: carVector, secondVector: destinationVector)
        
        let angleWithPerpendecularDegrees = angleWithPerpendicular * 180 / .pi
        let angleWithDestinationDegrees = angleWithDestination * 180 / .pi
        
        var newAngleForCarVector: CGFloat = 0.0
        
        if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees < 90 {
            newAngleForCarVector = angleWithDestination / 2.0
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees < 90 {
            newAngleForCarVector = -angleWithDestination / 2.0
            
        } else if angleWithPerpendecularDegrees >= 90, angleWithDestinationDegrees >= 90 {
            newAngleForCarVector = -(.pi - angleWithPerpendicular) / 2.0
            
        } else if angleWithPerpendecularDegrees < 90, angleWithDestinationDegrees >= 90 {
            newAngleForCarVector = angleWithPerpendicular / 2.0
        }
        
        let transformForNewCarPosition = CGAffineTransform(rotationAngle: newAngleForCarVector)
        let newCarCoordinateX = 1.5 * (transformForNewCarPosition.a * carVector.x + transformForNewCarPosition.c * carVector.y + transformForNewCarPosition.tx) + carView.center.x
        let newCarCoordinateY = 1.5 * (transformForNewCarPosition.b * carVector.x + transformForNewCarPosition.d * carVector.y + transformForNewCarPosition.ty) + carView.center.y
        
        return CGPoint(x: newCarCoordinateX, y: newCarCoordinateY)
    }
    
    func calculateDestination(firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        return sqrt(pow(secondPoint.x - firstPoint.x, 2) + pow(secondPoint.y - firstPoint.y, 2))
    }
}
