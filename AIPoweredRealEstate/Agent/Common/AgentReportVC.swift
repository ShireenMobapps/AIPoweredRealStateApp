//
//  AgentReportVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentReportVC: UIViewController {

    var properties: [PropertyItem] = []

    @IBOutlet weak var clientField: CustomTextField!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var shareButton: CustomButton!
    @IBOutlet weak var reportCardView: CustomView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        CommonMethods.styleTextField(clientField)
        CommonMethods.stylePrimaryButton(shareButton)
        CommonMethods.styleFormCard(reportCardView)
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        clientField.text = AgentStore.shared.clientSearches.first?.client ?? "Client"
        clientField.addTarget(self, action: #selector(refresh), for: .editingChanged)
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: shareButton)
    }

    @objc func refresh() {
        let name = clientField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        bodyLabel.text = AgentMarketingCopy.clientReport(for: properties, client: (name?.isEmpty == false) ? name! : "Client")
    }

    @IBAction func shareTapped(_ sender: Any) {
        refresh()
        present(UIActivityViewController(activityItems: [bodyLabel.text ?? ""], applicationActivities: nil), animated: true)
    }
}
