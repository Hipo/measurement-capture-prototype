//
//  Notification+Keyboard.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

extension Notification {

    var keyboardBeginFrame: CGRect? {
        return userInfo?[UIResponder.keyboardFrameBeginUserInfoKey].flatMap { ($0 as? NSValue)?.cgRectValue } ?? nil
    }

    var keyboardEndFrame: CGRect? {
        return userInfo?[UIResponder.keyboardFrameEndUserInfoKey].flatMap { ($0 as? NSValue)?.cgRectValue } ?? nil
    }

    var keyboardHeight: CGFloat? {
        return keyboardEndFrame?.height
    }

    var keyboardAnimationDuration: TimeInterval {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey].flatMap { $0 as? TimeInterval } ?? 0.25    }

    var keyboardAnimationCurve: UIView.AnimationCurve {
        guard let animationCurveRaw = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
            return .linear
        }
        return UIView.AnimationCurve(rawValue: animationCurveRaw) ?? .linear
    }
}
