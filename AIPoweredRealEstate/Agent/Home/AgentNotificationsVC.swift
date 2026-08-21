//
//  AgentNotificationsVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentNotificationsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        tableView.backgroundColor = .screenBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AgentStore.shared.markAllRead()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AgentStore.shared.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = AgentStore.shared.notifications[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.image = UIImage(systemName: item.icon)
        config.imageProperties.tintColor = .darkThemeColor
        config.text = item.title
        config.secondaryText = item.body
        config.textProperties.font = .systemFont(ofSize: 16, weight: item.isRead ? .medium : .semibold)
        config.secondaryTextProperties.color = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        config.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = config
        cell.backgroundColor = .white
        cell.accessoryType = item.title.lowercased().contains("lead") || item.title.lowercased().contains("enquiry")
            ? .disclosureIndicator : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = AgentStore.shared.notifications[indexPath.row].title.lowercased()
        if title.contains("lead") || title.contains("enquiry") {
            navigationController?.pushViewController(AgentStoryboard.load("AgentLeadsVC") as AgentLeadsVC, animated: true)
        }
    }
}
