//
//  AgentStoryboard.swift
//  AIPoweredRealEstate
//

import UIKit

enum AgentStoryboard {
    static let board = UIStoryboard(name: "AgentSB", bundle: nil)

    static func tabBar() -> UIViewController {
        board.instantiateViewController(withIdentifier: "AgentTabBarController")
    }

    static func load<T: UIViewController>(_ identifier: String) -> T {
        board.instantiateViewController(withIdentifier: identifier) as! T
    }
}
