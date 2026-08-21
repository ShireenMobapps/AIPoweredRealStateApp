//
//  TenantSearchVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantSearchVC: UIViewController {

    private var criteria = PropertySearchCriteria()
    private var results: [PropertyItem] = []

    private let keywordField = CustomTextField()
    private let buyButton = UIButton(type: .system)
    private let rentButton = UIButton(type: .system)
    private let filtersButton = UIButton(type: .system)
    private let sortButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let saveSearchButton = UIButton(type: .system)
    private let emptyLabel = UILabel()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        buildLayout()
        runSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let pending = PropertyStore.shared.consumePendingCriteria() {
            criteria = pending
            keywordField.text = pending.keyword
            runSearch()
        }
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func buildLayout() {
        let titleLabel = UILabel()
        titleLabel.text = "Search"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)

        let aiButton = UIButton(type: .system)
        let sparkles = UIImage(systemName: "sparkles", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold))
        aiButton.setImage(sparkles, for: .normal)
        aiButton.tintColor = .darkThemeColor
        aiButton.addTarget(self, action: #selector(aiSearchTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            aiButton.widthAnchor.constraint(equalToConstant: 40),
            aiButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        let headerRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), aiButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 8

        keywordField.placeholder = "Location or keyword"
        keywordField.returnKeyType = .search
        keywordField.delegate = self
        keywordField.leftPadding = 14
        keywordField.cornerRadious = 12
        keywordField.clipsToBounds = true
        keywordField.borderStyle = .none
        keywordField.addTarget(self, action: #selector(keywordChanged), for: .editingChanged)
        CommonMethods.styleTextField(keywordField)
        keywordField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        CommonMethods.styleFilterChip(buyButton, title: "Buy", selected: false, compact: true)
        CommonMethods.styleFilterChip(rentButton, title: "Rent", selected: false, compact: true)
        CommonMethods.styleFilterChip(filtersButton, title: "Filters", selected: false, compact: true)
        CommonMethods.styleFilterChip(sortButton, title: "Sort", selected: false, compact: true)
        buyButton.addTarget(self, action: #selector(listingTapped(_:)), for: .touchUpInside)
        rentButton.addTarget(self, action: #selector(listingTapped(_:)), for: .touchUpInside)
        filtersButton.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)

        let chipsRow = UIStackView(arrangedSubviews: [buyButton, rentButton, filtersButton, sortButton])
        chipsRow.axis = .horizontal
        chipsRow.spacing = 6
        chipsRow.distribution = .fillEqually
        chipsRow.alignment = .fill
        chipsRow.heightAnchor.constraint(equalToConstant: 36).isActive = true

        countLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        countLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        saveSearchButton.setTitle("Save search", for: .normal)
        saveSearchButton.setTitleColor(.darkThemeColor, for: .normal)
        saveSearchButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        saveSearchButton.addTarget(self, action: #selector(saveSearchTapped), for: .touchUpInside)
        let countRow = UIStackView(arrangedSubviews: [countLabel, UIView(), saveSearchButton])
        countRow.axis = .horizontal
        countRow.alignment = .center

        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        collectionView.keyboardDismissMode = .onDrag

        emptyLabel.text = "No properties match your search."
        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        let topStack = UIStackView(arrangedSubviews: [headerRow, keywordField, chipsRow, countRow])
        topStack.axis = .vertical
        topStack.spacing = 12
        topStack.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStack)
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 40)
        ])
    }

    private func runSearch() {
        criteria.keyword = keywordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        results = PropertyStore.shared.search(criteria)
        countLabel.text = "\(results.count) properties"
        emptyLabel.isHidden = !results.isEmpty
        refreshToolButtons()
        collectionView.reloadData()
    }

    private func refreshToolButtons() {
        CommonMethods.styleFilterChip(buyButton, title: "Buy", selected: criteria.listingType == "Buy", compact: true)
        CommonMethods.styleFilterChip(rentButton, title: "Rent", selected: criteria.listingType == "Rent", compact: true)
        let filterTitle = criteria.activeFilterCount == 0 ? "Filters" : "Filters (\(criteria.activeFilterCount))"
        CommonMethods.styleFilterChip(filtersButton, title: filterTitle, selected: criteria.activeFilterCount > 0, compact: true)
        CommonMethods.styleFilterChip(sortButton, title: sortChipTitle, selected: criteria.sort != .recommended, compact: true)
    }

    private var sortChipTitle: String {
        switch criteria.sort {
        case .recommended: return "Sort"
        case .priceLowToHigh: return "Low–High"
        case .priceHighToLow: return "High–Low"
        case .newest: return "Newest"
        }
    }

    @objc private func saveSearchTapped() {
        criteria.keyword = keywordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        PropertyStore.shared.saveSearch(from: criteria)
        let alert = UIAlertController(
            title: "Search Saved",
            message: "Find it on the Saved tab to edit preferences and alerts.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func keywordChanged() {
        runSearch()
    }

    @objc private func aiSearchTapped() {
        openAISearch()
    }

    @objc private func listingTapped(_ sender: UIButton) {
        let value = sender == buyButton ? "Buy" : "Rent"
        criteria.listingType = criteria.listingType == value ? nil : value
        runSearch()
    }

    @objc private func filtersTapped() {
        let filters = TenantFiltersVC()
        filters.criteria = criteria
        filters.onApply = { [weak self] updated in
            guard let self else { return }
            self.criteria.location = updated.location
            self.criteria.propertyType = updated.propertyType
            self.criteria.minPrice = updated.minPrice
            self.criteria.maxPrice = updated.maxPrice
            self.criteria.minBedrooms = updated.minBedrooms
            self.criteria.minBathrooms = updated.minBathrooms
            self.criteria.minArea = updated.minArea
            self.criteria.maxArea = updated.maxArea
            self.criteria.furnished = updated.furnished
            self.criteria.amenities = updated.amenities
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

    @objc private func sortTapped() {
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
}

extension TenantSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        runSearch()
        return true
    }
}

extension TenantSearchVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PropertyCardCell.identifier,
            for: indexPath
        ) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = results[indexPath.item]
        cell.configure(with: property, isFavorite: PropertyStore.shared.isFavorite(property.id))
        cell.onFavorite = { [weak self] in
            PropertyStore.shared.toggleFavorite(property.id)
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
