//
//  KeyboardController.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardControllerDataSource: class {

    func firstResponder(for keyboardController: KeyboardController) -> UIView?

    func containerView(for keyboardController: KeyboardController) -> UIView

    /*
     Bottom inset to specified first responding element in the scroll view.
     */
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat

    /*
     Generally, you can return either 0 for view controller with a permanent input accessory view or the bottom inset
     of the safe area of view controller.
     */
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat

    var scrollView: UIScrollView { get }
}

struct Keyboard {
    var height: CGFloat?
    var animationDuration: TimeInterval = 0.25
    var animationCurve: Int = UIView.AnimationCurve.linear.rawValue
}

class KeyboardController {

    typealias UserInfo = (height: CGFloat,
        animationDuration: TimeInterval,
        animationCurve: Int)

    typealias KeyboardNotificationHandler = (UserInfo) -> Void

    // These handlers will override the default implementation if they are not nil.
    var notificationHandlerWhenKeyboardShown: KeyboardNotificationHandler?
    var notificationHandlerWhenKeyboardHidden: KeyboardNotificationHandler?

    weak var dataSource: KeyboardControllerDataSource?

    var isKeyboardVisible: Bool {
        return keyboard.height != nil
    }

    fileprivate var keyboard = Keyboard()

    // MARK: Initialization

    deinit {
        endTracking()
    }

    // MARK: Notification

    @objc
    fileprivate func didReceive(keyboardWillShow notification: Notification) {

        guard let kbHeight = notification.keyboardHeight else {
            return
        }

        let keyboardHasAlreadyBeingShown = isKeyboardVisible

        keyboard.height = kbHeight
        keyboard.animationDuration = notification.keyboardAnimationDuration
        keyboard.animationCurve = notification.keyboardAnimationCurve.rawValue

        if let handler = notificationHandlerWhenKeyboardShown {
            handler(
                (height: kbHeight,
                 animationDuration: keyboard.animationDuration,
                 animationCurve: keyboard.animationCurve)
            )

            return
        }

        updateContentInsetWithKeyboard()
        scrollEditingFieldToVisibleIfNeeded(animated: !keyboardHasAlreadyBeingShown)
    }

    @objc
    fileprivate func didReceive(keyboardWillHide notification: Notification) {

        keyboard.height = nil

        if let handler = notificationHandlerWhenKeyboardHidden {

            handler(
                (height: 0.0,
                 animationDuration: keyboard.animationDuration,
                 animationCurve: keyboard.animationCurve)
            )

            return
        }

        updateContentInsetWithoutKeyboard()
    }
}

extension KeyboardController {

    func updateContentInsetWithKeyboard() {
        guard
            let kbHeight = keyboard.height,
            let dataSource = dataSource
            else {
                return
        }
        let scrollView = dataSource.scrollView

        let contentHeightAfterKeyboardAppeared =
            scrollView.contentSize.height +
                scrollView.contentInset.top +
        kbHeight
        let height = scrollView.bounds.height
        let bottomInset = contentHeightAfterKeyboardAppeared > height ? kbHeight : 0.0

        var contentInset = scrollView.contentInset
        contentInset.bottom = bottomInset + dataSource.bottomInsetWhenKeyboardPresented(for: self)

        scrollView.contentInset = contentInset

        var scrollIndicatorInsets = scrollView.scrollIndicatorInsets
        scrollIndicatorInsets.bottom = bottomInset

        scrollView.scrollIndicatorInsets = scrollIndicatorInsets
    }

    func updateContentInsetWithoutKeyboard() {
        guard let dataSource = dataSource else {
            return
        }
        let scrollView = dataSource.scrollView

        var contentInset = scrollView.contentInset
        contentInset.bottom = dataSource.bottomInsetWhenKeyboardDismissed(for: self)

        scrollView.contentInset = contentInset

        var scrollIndicatorInsets = scrollView.scrollIndicatorInsets
        scrollIndicatorInsets.bottom = dataSource.bottomInsetWhenKeyboardDismissed(for: self)

        scrollView.scrollIndicatorInsets = scrollIndicatorInsets
    }
}

// MARK: Public
extension KeyboardController {

    func beginTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillHide:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    func endTracking() {
        NotificationCenter
            .default
            .removeObserver(self)
    }

    func scrollEditingFieldToVisibleIfNeeded(animated: Bool) {

        if !isKeyboardVisible {
            return
        }

        guard
            let dataSource = dataSource,
            let respondingView = dataSource.firstResponder(for: self) else {
                return
        }
        let scrollView = dataSource.scrollView

        scrollView.layoutIfNeeded()
        updateContentInsetWithKeyboard()

        let containerView = dataSource.containerView(for: self)
        let editingRect = respondingView.frame
        /// <warning> editingRectInView won't be enough to show the writing text in a text view over the keyboard.
        let editingRectInView = respondingView.superview?.convert(editingRect, to: containerView) ?? .zero

        guard var visibleRect = containerView.superview?.bounds else {
            return
        }
        visibleRect.size.height -= keyboard.height ?? 0.0
        visibleRect.size.height -= dataSource.bottomInsetWhenKeyboardPresented(for: self)

        if visibleRect.contains(editingRectInView) {
            return
        }
        var contentOffset = scrollView.contentOffset

        if editingRectInView.height > visibleRect.height {
            contentOffset.y += editingRectInView.maxY - visibleRect.maxY // Always invisible area down visible rect.
        } else {
            if editingRectInView.maxY > visibleRect.maxY { // Invisible area down visible rect.
                contentOffset.y += editingRectInView.maxY - visibleRect.maxY
            } else if visibleRect.minY > editingRectInView.minY { // Invisible area up visible rect.
                contentOffset.y += editingRectInView.minY - visibleRect.minY
            }
        }
        if !animated {
            scrollView.contentOffset = contentOffset
            return
        }
        UIView.animate(
            withDuration: keyboard.animationDuration,
            delay: 0.0,
            options: UIView.AnimationOptions(rawValue: UInt(keyboard.animationCurve >> 16)),
            animations: {
                scrollView.contentOffset = contentOffset
        },
            completion: nil
        )
    }
}
