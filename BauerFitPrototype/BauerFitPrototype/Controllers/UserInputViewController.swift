//
//  GenderSelectViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit

class UserInputViewController: UIViewController {
    private lazy var maleGenderButton = UIButton(frame: .zero)
    private lazy var femaleGenderButton = UIButton(frame: .zero)
    private let genderButtonSize = CGSize(width: 132.0, height: 66.0)
    
    override func viewDidLoad() {
        configureAppearance()
        prepareLayout()
        linkInteractors()
    }

    private func configureAppearance() {
        configureMaleGenderButtonAppearance()
        configureFemaleGenderButtonAppearance()
    }

    private func prepareLayout() {
        prepareMaleGenderButtonLayout()
        prepareFemaleGenderButtonLayout()
    }

    private func linkInteractors() {
        maleGenderButton.addTarget(self, action: #selector(selectMaleGender(_:)), for: .touchUpInside)
        femaleGenderButton.addTarget(self, action: #selector(selectFemaleGender(_:)), for: .touchUpInside)
    }

    private func configureMaleGenderButtonAppearance() {
        maleGenderButton.layer.borderColor = UIColor.black.cgColor
        maleGenderButton.layer.borderWidth = 3
        maleGenderButton.backgroundColor = .white
        maleGenderButton.translatesAutoresizingMaskIntoConstraints = false
        maleGenderButton.setTitle("MALE", for: .normal)
        maleGenderButton.setTitleColor(.black, for: .normal)
    }

    private func configureFemaleGenderButtonAppearance() {
        femaleGenderButton.layer.borderColor = UIColor.black.cgColor
        femaleGenderButton.layer.borderWidth = 3
        femaleGenderButton.backgroundColor = .white
        femaleGenderButton.translatesAutoresizingMaskIntoConstraints = false
        femaleGenderButton.setTitle("FEMALE", for: .normal)
        femaleGenderButton.setTitleColor(.black, for: .normal)
    }

    private func prepareMaleGenderButtonLayout() {
        view.addSubview(maleGenderButton)

        NSLayoutConstraint.activate([
            maleGenderButton.widthAnchor.constraint(equalToConstant: genderButtonSize.width),
            maleGenderButton.heightAnchor.constraint(equalToConstant: genderButtonSize.height),
            maleGenderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maleGenderButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -genderButtonSize.height),
        ])
    }

    private func prepareFemaleGenderButtonLayout() {
        view.addSubview(femaleGenderButton)

        NSLayoutConstraint.activate([
            femaleGenderButton.widthAnchor.constraint(equalToConstant: genderButtonSize.width),
            femaleGenderButton.heightAnchor.constraint(equalToConstant: genderButtonSize.height),
            femaleGenderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            femaleGenderButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: genderButtonSize.height),
        ])
    }
    
    @objc
    private func selectMaleGender(_ sender: UIButton) {
        presentCameraCaptureController(withGender: .male)
    }
    
    @objc
    private func selectFemaleGender(_ sender: UIButton) {
        presentCameraCaptureController(withGender: .female)
    }
    
    func presentCameraCaptureController(withGender gender: Gender) {
        let captureProfile = CaptureProfile(gender: gender, frontPhoto: nil, sidePhoto: nil)
        let cameraViewController = CameraViewController(captureMode: .front, captureProfile: captureProfile)
        
        navigationController?.pushViewController(cameraViewController, animated: true)
    }
}
