//
//  ForgotPasswordVC.swift
//  AIPoweredRealEstate
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoContainerView: CustomView!
    @IBOutlet weak var formCardView: CustomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var sendButton: CustomButton!

    var selectedRole: UserRole = .tenant

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
        CommonMethods.updateGradientFrame(for: sendButton)
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.applyHeaderGradient(on: headerView, cornerRadius: 32)
        CommonMethods.styleLogoContainer(logoContainerView)
        CommonMethods.styleFormCard(formCardView)
        CommonMethods.styleTextField(emailTextField)
        CommonMethods.stylePrimaryButton(sendButton)

        titleLabel.text = "Forgot Password"
        subtitleLabel.text = "Enter your email to receive a reset link"
        errorLabel.text = nil
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func sendResetTapped(_ sender: UIButton) {
        errorLabel.text = nil
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !email.isEmpty else {
            errorLabel.text = "Please enter your email address."
            return
        }

        openOTP(email: email)
    }

    private func openOTP(email: String) {
        guard let otpVC = storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as? OTPVerificationVC else {
            return
        }
        otpVC.selectedRole = selectedRole
        otpVC.email = email
        otpVC.purpose = .passwordReset
        navigationController?.pushViewController(otpVC, animated: true)
    }

    @IBAction func backToLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
