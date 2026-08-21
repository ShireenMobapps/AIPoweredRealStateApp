//
//  AgentSearchVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentSearchVC: UIViewController {

    @IBOutlet weak var keywordField: CustomTextField!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var rentButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var saveClientButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var sourceStack: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!

    private var criteria = PropertySearchCriteria()
    private var results: [PropertyItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        keywordField.delegate = self
        keywordField.addTarget(self, action: #selector(keywordChanged), for: .editingChanged)
        CommonMethods.styleTextField(keywordField)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        runSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func rebuildSourceChips() {
        sourceStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        (["All"] + PropertyStore.sources).forEach { name in
            let selected = (name == "All" && criteria.source == nil) || criteria.source == name
            let button = CommonMethods.makeFilterChip(title: name, selected: selected)
            button.addTarget(self, action: #selector(sourceTapped(_:)), for: .touchUpInside)
            sourceStack.addArrangedSubview(button)
        }
    }

    private func runSearch() {
        criteria.keyword = keywordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        results = PropertyStore.shared.search(criteria)
        countLabel.text = "\(results.count) listings · \(criteria.source ?? "All portals")"
        emptyLabel.isHidden = !results.isEmpty
        refreshToolButtons()
        collectionView.reloadData()
    }

    private func refreshToolButtons() {
        CommonMethods.styleFilterChip(buyButton, title: "Buy", selected: criteria.listingType == "Buy", compact: true)
        CommonMethods.styleFilterChip(rentButton, title: "Rent", selected: criteria.listingType == "Rent", compact: true)
        let extra = criteria.activeFilterCount - (criteria.source == nil ? 0 : 1)
        CommonMethods.styleFilterChip(filtersButton, title: extra == 0 ? "Filters" : "Filters (\(extra))", selected: extra > 0, compact: true)
        CommonMethods.styleFilterChip(sortButton, title: sortChipTitle, selected: criteria.sort != .recommended, compact: true)
        rebuildSourceChips()
    }

    private var sortChipTitle: String {
        switch criteria.sort {
        case .recommended: return "Sort"
        case .priceLowToHigh: return "Low–High"
        case .priceHighToLow: return "High–Low"
        case .newest: return "Newest"
        }
    }

    @objc private func sourceTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        criteria.source = title == "All" ? nil : title
        runSearch()
    }

    @objc private func keywordChanged() { runSearch() }

    @IBAction func aiSearchTapped(_ sender: Any) { openAISearch() }

    @IBAction func listingTapped(_ sender: UIButton) {
        let value = sender == buyButton ? "Buy" : "Rent"
        criteria.listingType = criteria.listingType == value ? nil : value
        runSearch()
    }

    @IBAction func saveForClientTapped(_ sender: Any) {
        let query = keywordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? [criteria.listingType, criteria.location, criteria.source].compactMap { $0 }.joined(separator: " ")
        let alert = UIAlertController(title: "Save client search", message: "Store this brief under a client name.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Client name" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            AgentStore.shared.addClientSearch(client: name, query: query.isEmpty ? "Filtered inventory search" : query)
            self?.presentSimpleAlert(title: "Saved", message: "Find it on the Workspace tab under Clients.")
        })
        present(alert, animated: true)
    }

    @IBAction func filtersTapped(_ sender: Any) {
        let filters = TenantFiltersVC()
        filters.criteria = criteria
        filters.onApply = { [weak self] updated in
            guard let self else { return }
            let source = self.criteria.source
            self.criteria = updated
            self.criteria.source = source
            self.criteria.keyword = self.keywordField.text ?? ""
            self.runSearch()
        }
        let nav = UINavigationController(rootViewController: filters)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    @IBAction func sortTapped(_ sender: Any) {
        let sheet = UIAlertController(title: "Sort", message: nil, preferredStyle: .actionSheet)
        PropertySort.allCases.forEach { option in
            sheet.addAction(UIAlertAction(title: option.rawValue, style: .default) { [weak self] _ in
                self?.criteria.sort = option
                self?.runSearch()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sortButton
            popover.sourceRect = sortButton.bounds
        }
        present(sheet, animated: true)
    }

    private func presentSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AgentSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runSearch()
        return true
    }
}

extension AgentSearchVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { results.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyCardCell.identifier, for: indexPath) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = results[indexPath.item]
        cell.configure(with: property, isFavorite: AgentStore.shared.isFavorite(property.id), showsSource: true)
        cell.onFavorite = { [weak self] in
            AgentStore.shared.toggleFavorite(property.id)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openPropertyDetails(results[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: 268)
    }
}
