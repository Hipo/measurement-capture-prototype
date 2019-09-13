//
//  UIViewController+Navigation.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

extension UIViewController {
    @objc
    func popToRootViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
}
