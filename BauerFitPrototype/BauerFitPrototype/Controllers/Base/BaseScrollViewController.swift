//
//  BaseScrollViewController.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit
import SnapKit

class BaseScrollViewController: UIViewController {
    var shouldIgnoreTopLayoutGuide = false {
        didSet {
            if !isViewLoaded {
                return
            }
            if shouldIgnoreTopLayoutGuide == oldValue {
                return
            }
            updateScrollViewLayout()
        }
    }

    var shouldIgnoreBottomLayoutGuide = true {
        didSet {
            if !isViewLoaded {
                return
            }
            if shouldIgnoreBottomLayoutGuide == oldValue {
                return
            }

            updateScrollViewLayout()
        }
    }

    private let keyboardController = KeyboardController()

    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    private(set) lazy var contentView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        observeNotifications()
    }

    deinit {
        keyboardController.endTracking()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setListeners()
        prepareLayout()
    }

    func observeNotifications() {
        keyboardController.beginTracking()
    }

    func prepareLayout() {
        addScrollView()
        addContentView()
    }

    func setListeners() {
        keyboardController.dataSource = self
    }

    func updateScrollViewLayout() {
        scrollView.snp.remakeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.trailing.equalToSuperview()

            if shouldIgnoreTopLayoutGuide {
                maker.top.equalToSuperview()
            } else {
                maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }

            if shouldIgnoreBottomLayoutGuide {
                maker.bottom.equalToSuperview()
            } else {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }
        }
    }


    // MARK: - KeyboardControllerDataSource

    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return nil
    }

    func containerView(for keyboardController: KeyboardController) -> UIView {
        return view
    }

    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 10.0
    }

    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 0.0
    }
}

extension BaseScrollViewController {
    private func addScrollView() {
        view.addSubview(scrollView)

        updateScrollViewLayout()
    }

    private func addContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.leading.equalTo(view)
            maker.trailing.equalTo(view)
        }
    }
}

extension BaseScrollViewController: KeyboardControllerDataSource {
}
