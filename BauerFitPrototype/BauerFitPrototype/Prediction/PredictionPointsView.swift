//
//  PoseView.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 15/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit


class PredictionPointsView: UIView {

    struct constants {
        static let pointLabels = [
            "head",
            "right wrist",
            "left wrist",
            "right ankle",
            "left ankle",
        ]
        
        static var colors: [UIColor] = [
            .red,
            .green,
            .blue,
            .yellow,
            .magenta,
        ]
    }
    
    private var keypointLabelBGViews: [UIView] = []

    public var bodyPoints: [PredictedPoint] = [] {
        didSet {
            self.setNeedsDisplay()
            self.drawKeypoints(with: bodyPoints)
        }
    }
    
    private func setUpLabels(with keypointsCount: Int) {
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        let pointSize = CGSize(width: 12, height: 12)

        keypointLabelBGViews = (0..<keypointsCount).map { index in
            let color = PredictionPointsView.constants.colors[index % PredictionPointsView.constants.colors.count]
            let view = UIView(frame: CGRect(x: 0, y: 0, width: pointSize.width, height: pointSize.height))

            view.backgroundColor = color
            view.clipsToBounds = false
            view.layer.cornerRadius = 3
            view.layer.borderColor = UIColor.black.cgColor
            view.layer.borderWidth = 1.4

            let label = UILabel(frame: CGRect(x: pointSize.width * 1.4, y: 0, width: 100, height: pointSize.height))

            label.text = PredictionPointsView.constants.pointLabels[index % PredictionPointsView.constants.colors.count]
            label.textColor = color
            label.font = UIFont.preferredFont(forTextStyle: .caption2)

            view.addSubview(label)

            self.addSubview(view)

            return view
        }
    }
    
    private func drawKeypoints(with n_kpoints: [PredictedPoint]) {
        let imageFrame = self.frame.size
        
        if n_kpoints.count != keypointLabelBGViews.count {
            setUpLabels(with: n_kpoints.count)
        }
        
        for (index, kp) in n_kpoints.enumerated() {
            let x = kp.maxPoint.x * imageFrame.width
            let y = kp.maxPoint.y * imageFrame.height

            keypointLabelBGViews[index].center = CGPoint(x: x, y: y)
            keypointLabelBGViews[index].alpha = 1.0
        }
    }
}
