//
//  TenantContactAgentVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantContactAgentVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var formCardView: CustomView!
    @IBOutlet weak var agentLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var messageTextField: CustomTextField!
    @IBOutlet weak var sendButton: CustomButton!
    @IBOutlet weak var errorLabel: UILabel!

    var property: PropertyItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: sendButton)
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.styleFormCard(formCardView)
        CommonMethods.styleTextField(nameTextField)
        CommonMethods.styleTextField(emailTextField)
        CommonMethods.styleTextField(phoneTextField)
        CommonMethods.styleTextField(messageTextField)
        CommonMethods.stylePrimaryButton(sendButton)
        errorLabel.text = nil
    }

    private func populate() {
        guard let property else { return }
        agentLabel.text = "\(property.agentName) · \(property.agentAgency)"
        propertyLabel.text = property.title
        messageTextField.text = "I'm interested in \(property.title) in \(property.location)."
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func sendTapped(_ sender: UIButton) {
        errorLabel.text = nil
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty, !email.isEmpty else {
            errorLabel.text = "Please enter your name and email."
            return
        }
        guard let property else { return }

        PropertyStore.shared.addEnquiry(
            property: property,
            name: name,
            email: email,
            phone: phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            message: messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )

        let alert = UIAlertController(
            title: "Enquiry Submitted",
            message: "The agent will contact you about this property.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
