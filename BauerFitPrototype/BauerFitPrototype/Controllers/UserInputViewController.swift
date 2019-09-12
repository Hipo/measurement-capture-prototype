//
//  GenderSelectViewController.swift
//  BauerFitPrototype
//
//  Created by Taylan Pince on 2019-09-03.
//  Copyright © 2019 Hipo. All rights reserved.
//

import SnapKit
import UIKit

class UserInputViewController: UIViewController {

    // MARK: - Subviews

    private lazy var ageField = UITextField(frame: CGRect.zero)
    private lazy var heightField = UITextField(frame: CGRect.zero)
    private lazy var maleGenderButton = UIButton(frame: .zero)
    private lazy var femaleGenderButton = UIButton(frame: .zero)
    private let defaultInputSize = CGSize(width: 132.0, height: 66.0)
    private let defaultVerticalOffset: CGFloat = 10.0

    // MARK: - Properties

    var testFieldCharacterLimit = 3

    // MARK: - View lifecycle

    override func viewDidLoad() {
        configureAppearance()
        prepareLayout()
        linkInteractors()
    }

    // MARK: - Setup

    private func configureAppearance() {
        configureAgeFieldAppearance()
        configureHeightFieldAppearance()
        configureMaleGenderButtonAppearance()
        configureFemaleGenderButtonAppearance()
    }

    private func prepareLayout() {
        prepareFemaleGenderButtonLayout()
        prepareMaleGenderButtonLayout()
        prepareHeightFieldLayout()
        prepareAgeFieldLayout()
    }

    private func linkInteractors() {
        maleGenderButton.addTarget(self, action: #selector(selectMaleGender(_:)), for: .touchUpInside)
        femaleGenderButton.addTarget(self, action: #selector(selectFemaleGender(_:)), for: .touchUpInside)

        ageField.delegate = self
        heightField.delegate = self
    }

    // MARK: - Appearance

    private func configureAgeFieldAppearance() {
        ageField.layer.borderColor = UIColor.black.cgColor
        ageField.layer.borderWidth = 3
        ageField.textAlignment = .center
        ageField.keyboardType = .numberPad
    }

    private func configureHeightFieldAppearance() {
        heightField.layer.borderColor = UIColor.black.cgColor
        heightField.layer.borderWidth = 3
        heightField.textAlignment = .center
        heightField.keyboardType = .numberPad
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

    // MARK: - Layout

    private func prepareAgeFieldLayout() {
        view.addSubview(ageField)

        ageField.snp.makeConstraints { make in
            make.size.equalTo(defaultInputSize)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(heightField.snp.top).inset(-defaultVerticalOffset)
        }
    }

    private func prepareHeightFieldLayout() {
        view.addSubview(heightField)

        heightField.snp.makeConstraints { make in
            make.size.equalTo(defaultInputSize)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(maleGenderButton.snp.top).inset(-defaultVerticalOffset)
        }
    }

    private func prepareMaleGenderButtonLayout() {
        view.addSubview(maleGenderButton)

        maleGenderButton.snp.makeConstraints { make in
            make.size.equalTo(defaultInputSize)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(femaleGenderButton.snp.top).inset(-defaultVerticalOffset)
        }
    }

    private func prepareFemaleGenderButtonLayout() {
        view.addSubview(femaleGenderButton)

        femaleGenderButton.snp.makeConstraints { make in
            make.size.equalTo(defaultInputSize)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.centerY)
        }
    }

    // MARK: - Actions
    
    @objc
    private func selectMaleGender(_ sender: UIButton) {
        presentCameraCaptureController(withGender: .male)
    }
    
    @objc
    private func selectFemaleGender(_ sender: UIButton) {
        presentCameraCaptureController(withGender: .female)
    }

    // MARK: - Navigation
    
    func presentCameraCaptureController(withGender gender: Gender) {
        let captureProfile = CaptureProfile(gender: gender, frontPhoto: nil, sidePhoto: nil)
        let cameraViewController = CameraViewController(captureMode: .front, captureProfile: captureProfile)
        
        navigationController?.pushViewController(cameraViewController, animated: true)
    }
}

extension UserInputViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
        if testFieldCharacterLimit == 0 {
            return true
        }

        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let resultText = currentText.replacingCharacters(in: stringRange, with: string)
        return resultText.count <= testFieldCharacterLimit
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
        if testFieldCharacterLimit == 0 {
            return true
        }

        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: textView.text ?? "") else { return false }

        let resultText = currentText.replacingCharacters(in: stringRange, with: text)
        return resultText.count <= testFieldCharacterLimit
    }

}
