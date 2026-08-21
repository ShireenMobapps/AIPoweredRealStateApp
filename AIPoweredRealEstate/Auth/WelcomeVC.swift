//
//  WelcomeVC.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 18/08/26.
//

import UIKit

enum UserRole {
    case tenant
    case agent
}

class WelcomeVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var logoContainerView: CustomView!
    @IBOutlet weak var tenantCardView: CustomView!
    @IBOutlet weak var agentCardView: CustomView!
    @IBOutlet weak var tenantIconView: CustomView!
    @IBOutlet weak var agentIconView: CustomView!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyWelcomeStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: headerView)
        CommonMethods.updateGradientFrame(for: tenantIconView)
        CommonMethods.updateGradientFrame(for: agentIconView)
    }

    private func applyWelcomeStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.applyHeaderGradient(on: headerView, cornerRadius: 36)
        styleLogoContainer()
        style(card: tenantCardView)
        style(card: agentCardView)
        style(iconView: tenantIconView)
        style(iconView: agentIconView)
    }

    private func styleLogoContainer() {
        logoContainerView.backgroundColor = .white
        logoContainerView.layer.cornerRadius = 22
        logoContainerView.layer.shadowColor = UIColor.black.cgColor
        logoContainerView.layer.shadowOpacity = 0.14
        logoContainerView.layer.shadowRadius = 12
        logoContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func style(card: CustomView) {
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.cardBorderColor.cgColor
        card.layer.shadowColor = UIColor.darkThemeColor.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowRadius = 14
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
    }

    private func style(iconView: CustomView) {
        iconView.backgroundColor = .darkThemeColor
        iconView.layer.cornerRadius = 16
        CommonMethods.gradientOverView(view: iconView)
        iconView.clipsToBounds = true
    }

    @IBAction func tenantTapped(_ sender: UIButton) {
        openLogin(for: .tenant)
    }

    @IBAction func agentTapped(_ sender: UIButton) {
        openLogin(for: .agent)
    }

    private func openLogin(for role: UserRole) {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else {
            return
        }
        loginVC.selectedRole = role
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
