//
//  OTPVerificationVC.swift
//  AIPoweredRealEstate
//

import UIKit

enum OTPPurpose {
    case accountVerification
    case passwordReset
}

class OTPVerificationVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoContainerView: CustomView!
    @IBOutlet weak var formCardView: CustomView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var otpTextField: CustomTextField!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var verifyButton: CustomButton!

    var selectedRole: UserRole = .tenant
    var email: String = ""
    var purpose: OTPPurpose = .accountVerification

    private var secondsRemaining = 60
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        startTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: headerView)
        CommonMethods.updateGradientFrame(for: verifyButton)
    }

    deinit {
        timer?.invalidate()
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.applyHeaderGradient(on: headerView, cornerRadius: 32)
        CommonMethods.styleLogoContainer(logoContainerView)
        CommonMethods.styleFormCard(formCardView)
        CommonMethods.styleTextField(otpTextField)
        CommonMethods.stylePrimaryButton(verifyButton)

        titleLabel.text = "Verify OTP"
        subtitleLabel.text = email.isEmpty
            ? "Enter the OTP sent to your email"
            : "Enter the OTP sent to \(email)"
        errorLabel.text = nil
        otpTextField.keyboardType = .numberPad
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func verifyTapped(_ sender: UIButton) {
        errorLabel.text = nil
        let otp = otpTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard otp.count >= 4 else {
            errorLabel.text = "Please enter a valid OTP."
            return
        }

        switch purpose {
        case .accountVerification:
            popToLogin()
        case .passwordReset:
            openResetPassword(otp: otp)
        }
    }

    @IBAction func resendTapped(_ sender: UIButton) {
        errorLabel.text = nil
        secondsRemaining = 60
        startTimer()
    }

    private func openResetPassword(otp: String) {
        guard let resetVC = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC else {
            return
        }
        resetVC.selectedRole = selectedRole
        resetVC.email = email
        resetVC.otp = otp
        navigationController?.pushViewController(resetVC, animated: true)
    }

    private func popToLogin() {
        if let loginVC = navigationController?.viewControllers.first(where: { $0 is LoginVC }) {
            navigationController?.popToViewController(loginVC, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func startTimer() {
        timer?.invalidate()
        countdownLabel.text = "Resend in \(secondsRemaining)s"
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.secondsRemaining = max(self.secondsRemaining - 1, 0)
            self.countdownLabel.text = self.secondsRemaining > 0
                ? "Resend in \(self.secondsRemaining)s"
                : "You can resend now."
            if self.secondsRemaining == 0 {
                timer.invalidate()
            }
        }
    }
}
