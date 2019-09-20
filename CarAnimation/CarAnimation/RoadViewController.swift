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
    private var angle: Float = 0.0
    private let eps: Float = .pi / 40.0
    private let speed: Float = 100.0
    private let turnSpeed: Float = .pi
    
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
        animate(endPoint: newPoint, carCenter: carView.center, carFrame: carView.frame)
    }
    
    func animate(endPoint: CGPoint,  carCenter: CGPoint, carFrame: CGRect) {
        
        let carFrontPoint = CGPoint(x: carFrame.minX + carFrame.width / 2.0, y: carFrame.minY)
        var carVector = Vector(firstPoint: carCenter, secondPoint: carFrontPoint).rotated(angle: CGFloat(angle)) // вектор повернут на угол, заданный предыдущим поворотом
        var destinationVector = Vector(x: endPoint.x - carCenter.x, y: endPoint.y - carCenter.y)
        
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
        let turnCircleCenter = CGPoint(x: CGFloat(carVectorPerpendicular.x) + carCenter.x, y: CGFloat(carVectorPerpendicular.y) + carCenter.y)
        let turnCircleRadius = carVectorPerpendicular.length()
        
        let vectorToCarFromCenter = Vector(x: carCenter.x - turnCircleCenter.x, y: carCenter.y - turnCircleCenter.y)

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
            destinationVector = Vector(x: Float(endPoint.x) - newPositionX, y: Float(endPoint.y) - newPositionY)
            carVector = newCarVector
            endAngle += clockwise ? eps: -eps
        }
        
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
        arcAnimation.delegate = self
        
        /// поиск кратчайшего поворота до конечного угла
        
        let firstValue = abs((Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0)) - angle)
        let secondValue = abs((Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0) - 2 * .pi) - angle)
        var endValue: Float = 0.0
        if firstValue <= secondValue {
            endValue = Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0)
        } else {
            endValue = Float(atan2(Double(carVector.y), Double(carVector.x))) + Float(.pi / 2.0) - 2 * .pi
        }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = angle
        rotation.toValue = endValue
        rotation.duration = Double(timeInTurn + timeInRide)
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        
        angle = endValue
        CATransaction.setDisableActions(true)
        carView.center = endPoint
        carView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        carView.layer.add(arcAnimation, forKey: nil)
        carView.layer.add(rotation, forKey: nil)
    }
}

extension RoadViewController: CAAnimationDelegate {
    
    func animationDidStart(_ anim: CAAnimation) {
        guard let recognizer = carControlRecognizer else {
            return
        }
        
        view.removeGestureRecognizer(recognizer)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let recognizer = carControlRecognizer else {
            return
        }
        
        if flag {
            view.addGestureRecognizer(recognizer)
        }
        
    }
}
