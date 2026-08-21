//
//  LoginVC.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 18/08/26.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoContainerView: CustomView!
    @IBOutlet weak var formCardView: CustomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var showPasswordButton: UIButton!

    var selectedRole: UserRole = .tenant

    override func viewDidLoad() {
        super.viewDidLoad()
        applyLoginStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: headerView)
        CommonMethods.updateGradientFrame(for: loginButton)
    }

    private func applyLoginStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.applyHeaderGradient(on: headerView, cornerRadius: 32)

        let roleTitle = selectedRole == .tenant ? "Tenant" : "Agent"
        titleLabel.text = "Login"
        subtitleLabel.text = "Login to continue as \(roleTitle)"
        errorLabel.text = nil

        logoContainerView.backgroundColor = .white
        logoContainerView.layer.cornerRadius = 18
        logoContainerView.layer.shadowColor = UIColor.black.cgColor
        logoContainerView.layer.shadowOpacity = 0.12
        logoContainerView.layer.shadowRadius = 10
        logoContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)

        formCardView.backgroundColor = .white
        formCardView.layer.cornerRadius = 20
        formCardView.layer.shadowColor = UIColor.darkThemeColor.cgColor
        formCardView.layer.shadowOpacity = 0.10
        formCardView.layer.shadowRadius = 16
        formCardView.layer.shadowOffset = CGSize(width: 0, height: 8)

        style(field: emailTextField)
        style(field: passwordTextField)
        passwordTextField.isSecureTextEntry = true
        CommonMethods.stylePrimaryButton(loginButton)
    }

    private func style(field: CustomTextField) {
        field.backgroundColor = .screenBackgroundColor
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.cardBorderColor.cgColor
        field.font = .systemFont(ofSize: 16, weight: .regular)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func togglePasswordVisibilityTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        errorLabel.text = nil
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            errorLabel.text = "Please enter email and password."
            return
        }

        openHome(for: selectedRole)
    }

    private func openHome(for role: UserRole) {
        switch role {
        case .tenant:
            let storyboard = UIStoryboard(name: "TenantSB", bundle: nil)
            guard let tabBar = storyboard.instantiateViewController(
                withIdentifier: "TenantTabBarController"
            ) as? TenantTabBarController else {
                return
            }
            CommonMethods.setRootViewController(tabBar)
        case .agent:
            CommonMethods.setRootViewController(AgentStoryboard.tabBar())
        }
    }

    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        guard let forgotVC = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC else {
            return
        }
        forgotVC.selectedRole = selectedRole
        navigationController?.pushViewController(forgotVC, animated: true)
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        guard let registerVC = storyboard?.instantiateViewController(withIdentifier: "RegistartionVC") as? RegistartionVC else {
            return
        }
        registerVC.selectedRole = selectedRole
        navigationController?.pushViewController(registerVC, animated: true)
    }
}
