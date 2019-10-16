//
//  MeasurementResultCell.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

class MeasurementResultCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: UICollectionViewCell.self)

    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()

    let defaultHorizontalInset: CGFloat = 10.0
    let defaultVerticalInset: CGFloat = 4.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        prepareLayout()

        layer.borderWidth = 3.0
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareLayout() {
        prepareTitleLabelLayout()
        prepareSubtitleLabelLayout()
    }

    private func prepareTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.textColor = .black

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(defaultHorizontalInset)
        }
    }

    private func prepareSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.textColor = .black

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(defaultVerticalInset)
            make.leading.trailing.equalToSuperview().inset(defaultHorizontalInset)
            make.bottom.equalToSuperview().inset(defaultVerticalInset)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}

extension MeasurementResultCell {
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    var subTitle: String? {
        get {
            return subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
        }
    }
}
