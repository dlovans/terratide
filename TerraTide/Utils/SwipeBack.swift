//
//  SwipeBack.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-04.
//

import SwiftUI

// Allows swipe back when toolbar or navigationbackbutton is hidden.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
