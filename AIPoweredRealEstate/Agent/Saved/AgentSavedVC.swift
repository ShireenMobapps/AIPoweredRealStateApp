//
//  AgentSavedVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentSavedVC: UIViewController {

    private enum Section: Int {
        case properties, clients, compare
    }

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var compareButton: CustomButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!

    private var section: Section = .properties
    private var favorites: [PropertyItem] = []
    private var candidates: [PropertyItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        segment.selectedSegmentTintColor = .darkThemeColor
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .semibold)], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.darkThemeColor, .font: UIFont.systemFont(ofSize: 13, weight: .medium)], for: .normal)
        CommonMethods.stylePrimaryButton(compareButton)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "client")
        tableView.register(CompareSelectCell.self, forCellReuseIdentifier: CompareSelectCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let pending = AgentStore.pendingSavedSection {
            segment.selectedSegmentIndex = pending
            section = Section(rawValue: pending) ?? .properties
            AgentStore.pendingSavedSection = nil
        }
        reloadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        CommonMethods.updateGradientFrame(for: compareButton)
    }

    private func reloadContent() {
        favorites = AgentStore.shared.favoriteProperties()
        candidates = AgentStore.shared.compareCandidates()
        addButton.isHidden = section != .clients
        collectionView.isHidden = section != .properties
        tableView.isHidden = section == .properties
        compareButton.isHidden = section != .compare
        reportButton.isHidden = section != .compare

        switch section {
        case .properties:
            emptyLabel.text = "Shortlist listings with the heart to build your working set."
            emptyLabel.isHidden = !favorites.isEmpty
            collectionView.reloadData()
        case .clients:
            emptyLabel.text = "Save a search for a client from Inventory."
            emptyLabel.isHidden = !AgentStore.shared.clientSearches.isEmpty
            tableView.contentInset.bottom = 8
            tableView.reloadData()
        case .compare:
            let count = AgentStore.shared.compareIDs.count
            emptyLabel.isHidden = true
            compareButton.setTitle("Compare (\(count))", for: .normal)
            compareButton.alpha = count >= 2 ? 1 : 0.45
            compareButton.isEnabled = count >= 2
            reportButton.alpha = count >= 2 ? 1 : 0.45
            reportButton.isEnabled = count >= 2
            tableView.contentInset.bottom = 110
            tableView.reloadData()
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        section = Section(rawValue: sender.selectedSegmentIndex) ?? .properties
        reloadContent()
    }

    @IBAction func addClientTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Client search", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Client name" }
        alert.addTextField { $0.placeholder = "What they are looking for" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let query = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty, !query.isEmpty else { return }
            AgentStore.shared.addClientSearch(client: name, query: query)
            self?.reloadContent()
        })
        present(alert, animated: true)
    }

    @IBAction func openComparison(_ sender: Any) {
        let selected = AgentStore.shared.comparedProperties()
        guard selected.count >= 2 else { return }
        openCompare(selected)
    }

    @IBAction func openReport(_ sender: Any) {
        let selected = AgentStore.shared.comparedProperties()
        guard selected.count >= 2 else { return }
        let vc: AgentReportVC = AgentStoryboard.load("AgentReportVC")
        vc.properties = selected
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AgentSavedVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { favorites.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyCardCell.identifier, for: indexPath) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = favorites[indexPath.item]
        cell.configure(with: property, isFavorite: true, showsSource: true)
        cell.onFavorite = { [weak self] in
            AgentStore.shared.toggleFavorite(property.id)
            self?.reloadContent()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openPropertyDetails(favorites[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: 268)
    }
}

extension AgentSavedVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section == .clients ? AgentStore.shared.clientSearches.count : candidates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if section == .clients {
            let item = AgentStore.shared.clientSearches[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "client", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = item.client
            config.secondaryText = item.query
            config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
            config.secondaryTextProperties.color = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
            cell.contentConfiguration = config
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CompareSelectCell.identifier, for: indexPath) as? CompareSelectCell ?? CompareSelectCell()
        let property = candidates[indexPath.row]
        cell.configure(property, selected: AgentStore.shared.isCompared(property.id))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if section == .clients {
            openAISearch(prefilled: AgentStore.shared.clientSearches[indexPath.row].query)
            return
        }
            let property = candidates[indexPath.row]
            _ = AgentStore.shared.toggleCompare(property.id)
            reloadContent()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard section == .clients else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            let store = AgentStore.shared
            guard store.clientSearches.indices.contains(indexPath.row) else {
                done(false)
                return
            }
            store.deleteClientSearch(id: store.clientSearches[indexPath.row].id)
            self?.reloadContent()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        section == .compare ? 76 : 72
    }
}
