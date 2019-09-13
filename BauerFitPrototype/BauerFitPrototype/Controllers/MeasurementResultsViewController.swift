//
//  MeasurementResultsViewController.swift
//  BauerFitPrototype
//
//  Created by Eray on 13.09.2019.
//  Copyright © 2019 Hipo. All rights reserved.
//

import UIKit

class MeasurementResultsViewController: UIViewController {

    // MARK: - Subviews

    private lazy var flowLayout = UICollectionViewFlowLayout()
    private lazy var listView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout
    )
    private lazy var resetButton = UIButton()

    // MARK: - Properties

    private let measurements: ImageMeasurementResult.Measurements
    private let defaultVerticalInset: CGFloat = 10.0
    private let defaultButtonSize = CGSize(width: 132.0, height: 66.0)

    // MARK: - Initialization

    init(result: ImageMeasurementResult) {
        self.measurements = result.measurements

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        prepareLayout()
        linkInteractors()
        registerCells()
        listView.reloadData()
    }

    // MARK: - Appearance

    private func configureAppearance() {
        view.backgroundColor = UIColor.white

        configureListViewAppearance()
        configureResetButtonAppearance()
    }

    private func configureListViewAppearance() {
        flowLayout.itemSize = CGSize(width: view.bounds.width, height: 50.0)
        listView.backgroundColor = UIColor.white
        listView.contentInset.bottom = defaultButtonSize.height + 2 * defaultVerticalInset
    }

    private func configureResetButtonAppearance() {
        resetButton.layer.borderColor = UIColor.black.cgColor
        resetButton.layer.borderWidth = 3
        resetButton.backgroundColor = .white
        resetButton.setTitle("RESET", for: .normal)
        resetButton.setTitleColor(.black, for: .normal)
    }

    // MARK: - Layout

    private func prepareLayout() {
        prepareListViewLayout()
        prepareResetButtonLayout()
    }

    private func prepareListViewLayout() {
        view.addSubview(listView)

        listView.snp.makeConstraints { make in
            make.top
                .equalTo(view.safeAreaLayoutGuide.snp.top)
                .inset(defaultVerticalInset)

            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func prepareResetButtonLayout() {
        view.addSubview(resetButton)

        resetButton.snp.makeConstraints { make in
            make.size.equalTo(defaultButtonSize)
            make.centerX.equalToSuperview()
            make.top
                .lessThanOrEqualTo(listView.snp.bottom)
                .inset(defaultVerticalInset)

            make.bottom
                .equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(defaultVerticalInset)
        }
    }

    private func registerCells() {
        listView.register(
            MeasurementResultCell.self,
            forCellWithReuseIdentifier: MeasurementResultCell.reuseIdentifier
        )
    }

    private func linkInteractors() {
        listView.dataSource = self
        resetButton.addTarget(self, action: #selector(popToRootViewController), for: .touchUpInside)
    }
}

extension MeasurementResultsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return measurements.list.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MeasurementResultCell.reuseIdentifier,
            for: indexPath
        ) as! MeasurementResultCell

        configure(cell, at: indexPath)

        return cell
    }
}

extension MeasurementResultsViewController {
    private func configure(_ cell: MeasurementResultCell, at indexPath: IndexPath) {
        let result = measurements.list[indexPath.item]

        cell.title = result.name

        if let value = result.value as? String {
            cell.subTitle = value
        } else if let value = result.value as? Int {
            cell.subTitle = String(value)
        }
    }
}
