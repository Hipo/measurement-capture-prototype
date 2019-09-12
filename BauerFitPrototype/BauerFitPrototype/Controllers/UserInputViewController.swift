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

    private var testFieldCharacterLimit = 3
    private var draft = ImageMeasurementDraft()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        configureAppearance()
        prepareLayout()
        linkInteractors()

        validateForm()
        ageField.becomeFirstResponder()
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

        ageField.addTarget(self, action: #selector(ageFieldDidEditValue), for: .editingChanged)
        heightField.addTarget(self, action: #selector(heightFieldDidEditValue), for: .editingChanged)

        ageField.delegate = self
        heightField.delegate = self
    }

    // MARK: - Appearance

    private func configureAgeFieldAppearance() {
        ageField.layer.borderColor = UIColor.black.cgColor
        ageField.layer.borderWidth = 3
        ageField.textAlignment = .center
        ageField.keyboardType = .numberPad
        ageField.autocorrectionType = .no
        ageField.placeholder = "AGE"
    }

    private func configureHeightFieldAppearance() {
        heightField.layer.borderColor = UIColor.black.cgColor
        heightField.layer.borderWidth = 3
        heightField.textAlignment = .center
        heightField.keyboardType = .numberPad
        heightField.autocorrectionType = .no
        heightField.placeholder = "HEIGHT"
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
    private func ageFieldDidEditValue() {
        validateForm()

        if let age = ageField.text {
            draft.age = Int(age)
        }
    }

    @objc
    private func heightFieldDidEditValue() {
        validateForm()

        if let height = heightField.text {
            draft.height = Int(height)
        }
    }

    @objc
    private func selectMaleGender(_ sender: UIButton) {
        draft.gender = .male

        presentCameraCaptureController(withGender: .male)
    }
    
    @objc
    private func selectFemaleGender(_ sender: UIButton) {
        draft.gender = .female

        presentCameraCaptureController(withGender: .female)
    }

    // MARK: - Navigation
    
    func presentCameraCaptureController(withGender gender: Gender) {
        let cameraViewController = CameraViewController(captureMode: .front, draft: draft)
        
        navigationController?.pushViewController(cameraViewController, animated: true)
    }
}

// MARK: - Validation

extension UserInputViewController {
    private var isFormValid: Bool {
        return isAgeValid && isHeightValid
    }

    private var isAgeValid: Bool {
        guard let text = ageField.text else { return false }
        return !(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private var isHeightValid: Bool {
        return !(heightField.text?.isEmpty ?? true)
    }

    private func validateForm() {
        setHeightButton(enabled: isAgeValid)
        setGenderButtons(enabled: isAgeValid && isHeightValid)
    }
}

// MARK: - Enability

extension UserInputViewController {
    private func setHeightButton(enabled: Bool) {
        let color = enabled
            ? UIColor.black
            : UIColor.lightGray.withAlphaComponent(0.5)

        heightField.isEnabled = enabled
        heightField.layer.borderColor = color.cgColor
    }

    private func setGenderButtons(enabled: Bool) {
        let color = enabled
            ? UIColor.black
            : UIColor.lightGray.withAlphaComponent(0.5)

        maleGenderButton.isEnabled = enabled
        maleGenderButton.layer.borderColor = color.cgColor
        maleGenderButton.setTitleColor(color, for: .normal)
        femaleGenderButton.isEnabled = enabled
        femaleGenderButton.layer.borderColor = color.cgColor
        femaleGenderButton.setTitleColor(color, for: .normal)
    }
}

// MARK: - UITextFieldDelegate

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
}
