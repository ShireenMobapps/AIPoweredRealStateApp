//
//  AgentTabBarController.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTabBarStyle()
        viewControllers?.forEach { controller in
            (controller as? UINavigationController)?.setNavigationBarHidden(true, animated: false)
        }
    }

    private func applyTabBarStyle() {
        tabBar.tintColor = .darkThemeColor
        tabBar.unselectedItemTintColor = UIColor(white: 0.58, alpha: 1)
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.darkThemeColor.withAlphaComponent(0.12)

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = .darkThemeColor
        selected.titleTextAttributes = [
            .foregroundColor: UIColor.darkThemeColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor(white: 0.58, alpha: 1)
        normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.58, alpha: 1),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]

        appearance.inlineLayoutAppearance = appearance.stackedLayoutAppearance
        appearance.compactInlineLayoutAppearance = appearance.stackedLayoutAppearance
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
