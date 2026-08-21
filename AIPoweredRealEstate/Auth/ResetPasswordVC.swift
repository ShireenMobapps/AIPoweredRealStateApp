//
//  ResetPasswordVC.swift
//  AIPoweredRealEstate
//

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoContainerView: CustomView!
    @IBOutlet weak var formCardView: CustomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var resetButton: CustomButton!

    var selectedRole: UserRole = .tenant
    var email: String = ""
    var otp: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: headerView)
        CommonMethods.updateGradientFrame(for: resetButton)
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.applyHeaderGradient(on: headerView, cornerRadius: 32)
        CommonMethods.styleLogoContainer(logoContainerView)
        CommonMethods.styleFormCard(formCardView)
        CommonMethods.styleTextField(passwordTextField)
        CommonMethods.styleTextField(confirmPasswordTextField)
        CommonMethods.stylePrimaryButton(resetButton)

        titleLabel.text = "Reset Password"
        subtitleLabel.text = "Create a new password for your account"
        errorLabel.text = nil
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func resetTapped(_ sender: UIButton) {
        errorLabel.text = nil
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""

        guard !password.isEmpty else {
            errorLabel.text = "Please enter a new password."
            return
        }
        guard password.count >= 8 else {
            errorLabel.text = "Password must be at least 8 characters."
            return
        }
        guard password == confirmPassword else {
            errorLabel.text = "Passwords do not match."
            return
        }

        popToLogin()
    }

    @IBAction func backToLoginTapped(_ sender: UIButton) {
        popToLogin()
    }

    private func popToLogin() {
        if let loginVC = navigationController?.viewControllers.first(where: { $0 is LoginVC }) {
            navigationController?.popToViewController(loginVC, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
