//
//  AnimationDataObject.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 23/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

enum AnimationType {
    case rotate(startAngle: Float, rotateAngle: Float)
    case positionWithNaturalTurn(start: CGPoint, end: CGPoint, arcCenter: CGPoint, arcRadius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    case simplePosition(start: CGPoint, end: CGPoint)
}

struct AnimationParametersDataObject {
    let type: AnimationType
    let duration: Double
}
