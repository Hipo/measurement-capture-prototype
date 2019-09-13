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

    private lazy var listView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width, height: 50.0)
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        return view
    }()

    // MARK: - Properties

    private let measurements: ImageMeasurementResult.Measurements

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

    // MARK: - Setup

    private func configureAppearance() {
        view.backgroundColor = UIColor.white
        listView.backgroundColor = UIColor.white
    }

    private func prepareLayout() {
        view.addSubview(listView)

        listView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
