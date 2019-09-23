//
//  CarViewModel.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 23/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

protocol CarAnimationCalculating {
    func calculateAnimation(start: CGPoint, destination: CGPoint, carFrame: CGRect) -> [AnimationParametersDataObject]?
}

class RoadViewModel {
    private let animationCalculationService: CarAnimationCalculating?
    
    init(animationService: CarAnimationCalculating?) {
        animationCalculationService = animationService
    }
    
    func animationService() -> CarAnimating {
        return AnimationBuilder()
    }
    
    func configureAnimations(start: CGPoint, destination: CGPoint, carFrame: CGRect) -> [AnimationParametersDataObject]? {
        return animationCalculationService?.calculateAnimation(start: start, destination: destination, carFrame: carFrame)
    }
}
