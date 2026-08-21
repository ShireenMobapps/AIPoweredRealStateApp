//
//  RegistartionVC.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 18/08/26.
//

import UIKit

class RegistartionVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoContainerView: CustomView!
    @IBOutlet weak var formCardView: CustomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var firstNameTextField: CustomTextField!
    @IBOutlet weak var lastNameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var agencyTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomTextField!
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var createAccountButton: CustomButton!

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
        CommonMethods.updateGradientFrame(for: createAccountButton)
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.applyHeaderGradient(on: headerView, cornerRadius: 32)
        CommonMethods.styleLogoContainer(logoContainerView)
        CommonMethods.styleFormCard(formCardView)
        CommonMethods.stylePrimaryButton(createAccountButton)

        [firstNameTextField, lastNameTextField, emailTextField, phoneTextField, agencyTextField, passwordTextField, confirmPasswordTextField].forEach {
            if let field = $0 {
                CommonMethods.styleTextField(field)
            }
        }

        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        termsSwitch.onTintColor = .darkThemeColor
        errorLabel.text = nil

        let isAgent = selectedRole == .agent
        let roleTitle = isAgent ? "Agent" : "Tenant"
        titleLabel.text = "Create Account"
        subtitleLabel.text = "Register to continue as \(roleTitle)"
        agencyTextField.isHidden = !isAgent
        agencyTextField.placeholder = "Agency / Company name"
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        errorLabel.text = nil

        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        let agency = agencyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorLabel.text = "Please enter first and last name."
            return
        }
        guard !email.isEmpty else {
            errorLabel.text = "Please enter your email address."
            return
        }
        guard !phone.isEmpty else {
            errorLabel.text = "Please enter your phone number."
            return
        }
        if selectedRole == .agent, agency.isEmpty {
            errorLabel.text = "Please enter your agency name."
            return
        }
        guard !password.isEmpty, password == confirmPassword else {
            errorLabel.text = "Passwords do not match."
            return
        }
        guard termsSwitch.isOn else {
            errorLabel.text = "Please accept the terms and conditions."
            return
        }

        TenantAccount.shared.name = "\(firstName) \(lastName)"
        TenantAccount.shared.email = email
        TenantAccount.shared.phone = phone
        if selectedRole == .agent {
            AgentAccount.shared.name = "\(firstName) \(lastName)"
            AgentAccount.shared.agency = agency.isEmpty ? "Independent Agent" : agency
            AgentAccount.shared.email = email
            AgentAccount.shared.phone = phone
        }
        openOTP(email: email)
    }

    private func openOTP(email: String) {
        guard let otpVC = storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as? OTPVerificationVC else {
            return
        }
        otpVC.selectedRole = selectedRole
        otpVC.email = email
        otpVC.purpose = .accountVerification
        navigationController?.pushViewController(otpVC, animated: true)
    }

    @IBAction func backToLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
