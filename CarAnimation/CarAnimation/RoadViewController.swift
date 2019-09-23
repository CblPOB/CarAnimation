//
//  RoadViewController.swift
//  CarAnimation
//
//  Created by Syrov Nikita on 15/09/2019.
//  Copyright © 2019 Syrov Nikita. All rights reserved.
//

import UIKit

protocol CarAnimating {
    func animation(dataObjects: [AnimationParametersDataObject]?, delegate: CAAnimationDelegate?) -> CarAnimationObject?
}

class RoadViewController: UIViewController {
    var viewModel: RoadViewModel?
    private var animationService: CarAnimating?
    private var carControlRecognizer: UITapGestureRecognizer?
    private var carView: CarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCarView()
        setupGestureRecognizer()
        animationService = viewModel?.animationService()
    }
    
    func setupCarView() {
        let viewHeight = view.frame.size.height / 10.0
        let viewWidth = viewHeight * 0.5
        carView = CarView()
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
        carView.configure(animationObject: animationService?.animation(dataObjects: viewModel?.configureAnimations(start: carView.center, destination: newPoint, carFrame: carView.frame), delegate: self))
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
