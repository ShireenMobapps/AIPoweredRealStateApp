//
//  AgentLeadsVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentLeadsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        tableView.backgroundColor = .screenBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "lead")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        emptyLabel.isHidden = !AgentStore.shared.leads.isEmpty
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AgentStore.shared.leads.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lead", for: indexPath)
        let lead = AgentStore.shared.leads[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = "\(lead.clientName) · \(lead.status.rawValue)"
        config.secondaryText = "\(lead.propertyTitle)\n\(lead.message)"
        config.secondaryTextProperties.numberOfLines = 3
        config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc: AgentLeadDetailVC = AgentStoryboard.load("AgentLeadDetailVC")
        vc.leadID = AgentStore.shared.leads[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class AgentLeadDetailVC: UIViewController {

    var leadID: String = ""
    @IBOutlet weak var status: UISegmentedControl!
    @IBOutlet weak var body: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        status.selectedSegmentTintColor = .darkThemeColor
        status.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        status.setTitleTextAttributes([.foregroundColor: UIColor.darkThemeColor], for: .normal)
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func populate() {
        guard let lead = AgentStore.shared.leads.first(where: { $0.id == leadID }) else { return }
        status.selectedSegmentIndex = AgentLeadStatus.allCases.firstIndex(of: lead.status) ?? 0
        body.text = """
        \(lead.clientName)
        \(lead.email)
        \(lead.phone)

        Property: \(lead.propertyTitle)

        \(lead.message)
        """
    }

    @IBAction func statusChanged(_ sender: UISegmentedControl) {
        let value = AgentLeadStatus.allCases[sender.selectedSegmentIndex]
        AgentStore.shared.setLeadStatus(id: leadID, status: value)
    }
}
