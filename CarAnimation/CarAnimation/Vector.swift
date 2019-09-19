//
//  Vector.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 17/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import simd
import CoreGraphics

class Vector {
    
    private var vector: simd_float2
    var x: Float {
        return vector.x
    }
    
    var y: Float {
        return vector.y
    }
    
    init(x: CGFloat, y: CGFloat) {
        vector = simd_float2(x: Float(x), y: Float(y))
    }
    
    init(x: Float, y: Float) {
        vector = simd_float2(x: x, y: y)
    }
    
    convenience init(firstPoint: CGPoint, secondPoint: CGPoint) {
        self.init(x: secondPoint.x - firstPoint.x, y: secondPoint.y - firstPoint.y)
    }
    
    func length() -> Float {
        return simd_length(vector)
    }
    
    func destination(toVector: Vector) -> Float {
        return sqrt(simd_distance_squared(toVector.vector, vector))
    }
    
    func angle(withVector: Vector) -> Float {
        return acos((vector.x * withVector.vector.x + vector.y * withVector.vector.y) / (sqrt(pow(vector.x, 2) + pow(vector.y, 2)) * sqrt(pow(withVector.vector.x, 2) + pow(withVector.vector.y, 2))))
    }
    
    func rotated(angle: CGFloat) -> Vector {
        let rotationTransform = CGAffineTransform(rotationAngle: angle)
        return Vector(x: Float(rotationTransform.a) * vector.x + Float(rotationTransform.c) * vector.y + Float(rotationTransform.tx),
                      y: Float(rotationTransform.b) * vector.x + Float(rotationTransform.d) * vector.y + Float(rotationTransform.ty))
    }
}
