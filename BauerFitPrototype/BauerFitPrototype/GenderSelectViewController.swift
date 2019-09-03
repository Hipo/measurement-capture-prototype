//
//  GenderSelectViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import Foundation
import UIKit


class GenderSelectViewController: UIViewController {
    
    override func viewDidLoad() {
        
        let genderButtonSize = CGSize(width: 132.0, height: 66.0)
        let maleGenderButton = UIButton(frame: .zero)
        
        maleGenderButton.backgroundColor = .white
        maleGenderButton.translatesAutoresizingMaskIntoConstraints = false
        maleGenderButton.setTitle("MALE", for: .normal)
        maleGenderButton.setTitleColor(.black, for: .normal)
        
        view.addSubview(maleGenderButton)
        
        maleGenderButton.layer.borderColor = UIColor.black.cgColor
        maleGenderButton.layer.borderWidth = 3
        
        NSLayoutConstraint.activate([
            maleGenderButton.widthAnchor.constraint(equalToConstant: genderButtonSize.width),
            maleGenderButton.heightAnchor.constraint(equalToConstant: genderButtonSize.height),
            maleGenderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maleGenderButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -genderButtonSize.height),
        ])
        
        maleGenderButton.addTarget(self, action: #selector(selectMaleGender(_:)), for: .touchUpInside)
        
        let femaleGenderButton = UIButton(frame: .zero)
        
        femaleGenderButton.backgroundColor = .white
        femaleGenderButton.translatesAutoresizingMaskIntoConstraints = false
        femaleGenderButton.setTitle("FEMALE", for: .normal)
        femaleGenderButton.setTitleColor(.black, for: .normal)

        view.addSubview(femaleGenderButton)
        
        femaleGenderButton.layer.borderColor = UIColor.black.cgColor
        femaleGenderButton.layer.borderWidth = 3
        
        NSLayoutConstraint.activate([
            femaleGenderButton.widthAnchor.constraint(equalToConstant: genderButtonSize.width),
            femaleGenderButton.heightAnchor.constraint(equalToConstant: genderButtonSize.height),
            femaleGenderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            femaleGenderButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: genderButtonSize.height),
        ])
        
        femaleGenderButton.addTarget(self, action: #selector(selectFemaleGender(_:)), for: .touchUpInside)
    }
    
    @objc func selectMaleGender(_ sender: UIButton) {
        presentCameraCaptureController(withGender: .male)
    }
    
    @objc func selectFemaleGender(_ sender: UIButton) {
        presentCameraCaptureController(withGender: .female)
    }
    
    func presentCameraCaptureController(withGender gender: Gender) {
        let captureProfile = CaptureProfile(gender: gender, frontPhoto: nil, sidePhoto: nil)
        let cameraViewController = CameraViewController(captureMode: .front, captureProfile: captureProfile)
        
        navigationController?.pushViewController(cameraViewController, animated: true)
    }

}
