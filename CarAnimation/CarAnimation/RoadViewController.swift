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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCarView()
        setupGestureRecognizer()
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
        carView.layer.add(calculateArcAnimationEndPoint(tapPoint: newPoint), forKey: nil)
    }
    
    func calculateAngle(firstVector: CGPoint, secondVector: CGPoint) -> CGFloat {
        return acos((firstVector.x * secondVector.x + firstVector.y * secondVector.y) / (sqrt(pow(firstVector.x, 2) + pow(firstVector.y, 2)) * sqrt(pow(secondVector.x, 2) + pow(secondVector.y, 2))))
    }
    
    func calculateArcAnimationEndPoint(tapPoint: CGPoint) -> CAKeyframeAnimation {
//        let carFrontCenterPoint = CGPoint(x: carView.frame.origin.x + carView.frame.width / 2.0, y: carView.frame.origin.y)
//        let carBackCenterPoint = CGPoint(x: carView.frame.origin.x + carView.frame.width / 2.0, y: carView.frame.origin.y + carView.frame.height)
//        let carCenterPoint = carView.center
//        let carViewCenterStraightCoefficient = (carFrontCenterPoint.y - carBackCenterPoint.y) / (carFrontCenterPoint.x - carBackCenterPoint.y)
//
//        // center of arc circle
//
//        let circleY = sqrt(pow(turnArcRadius, 2) / Double(pow(2 * carViewCenterStraightCoefficient - 1, 2) + 2 * carViewCenterStraightCoefficient)) + Double(carCenterPoint.y)
//        let circleX = (pow(turnArcRadius, 2) - pow(circleY - Double(carCenterPoint.y), 2) * pow(1 - Double(carViewCenterStraightCoefficient), 2)) / -2 * Double(carViewCenterStraightCoefficient) * (circleY - Double(carCenterPoint.y))
//
//        // center of tmp circle which to find end point
//
//        let tmpCircleY = (Double(tapPoint.y) + circleY) / 2.0
//        let tmpCircleX = (Double(tapPoint.x) + circleX) / 2.0
//
//        let tmpR = pow(Double(tapPoint.x) - tmpCircleX, 2) + pow(Double(tapPoint.y) - tmpCircleY, 2)
//        let r = pow(circleX - Double(carCenterPoint.x), 2) + pow(circleY - Double(carCenterPoint.y), 2)
//        let a = 2 * (circleX - tmpCircleX)
//        let b = 2 * (circleY - tmpCircleY)
//        let c = pow(tmpCircleX, 2) - pow(circleX, 2) + pow(tmpCircleY, 2) - pow(circleY, 2) - tmpR + r
//
//        let x0 = (-a * c) / (pow(a, 2) + pow(b, 2))
//        let y0 = (-b * c) / (pow(a, 2) + pow(b, 2))
//        let d = tmpR - (pow(c, 2) / (pow(a, 2) + pow(b, 2)))
//        let mult = sqrt(d / (pow(a, 2) + pow(b, 2)))
//        let fPointX = x0 + b * mult
//        let sPointX = x0 - b * mult
//        let fPointY = y0 - a * mult
//        let sPointY = y0 + a * mult
//
//
//        let circle = CGPoint(x: carCenterPoint.x + CGFloat(turnArcRadius), y: carCenterPoint.y + CGFloat(turnArcRadius))
//        let startAngle = calculateAngle(firstVector: CGPoint(x: carCenterPoint.x - circle.x, y: carCenterPoint.y - circle.y),
//                                        secondVector: CGPoint(x: circle.x + 10, y: circle.y))
//        let endAngle = calculateAngle(firstVector: CGPoint(x: 10, y: 0),
//                                      secondVector: CGPoint(x: fPointX - circleX, y: fPointY - circleY))
        
//        let path = CGMutablePath()
//        path.addArc(center: CGPoint(x: carCenterPoint.x + CGFloat(turnArcRadius), y: carCenterPoint.y + CGFloat(turnArcRadius)), radius: CGFloat(turnArcRadius), startAngle: startAngle, endAngle: .pi / -2.0, clockwise: false)
//        path.move(to: carCenterPoint)
        
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
