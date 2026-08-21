//
//  TenantSavedVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantSavedVC: UIViewController {

    private enum Section: Int {
        case properties, searches, compare
    }

    private var section: Section = .properties
    private var favorites: [PropertyItem] = []
    private var candidates: [PropertyItem] = []

    private let segment = UISegmentedControl(items: ["Properties", "Searches", "Compare"])
    private let addButton = UIButton(type: .system)
    private let emptyLabel = UILabel()
    private let compareButton = UIButton(type: .system)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        CommonMethods.updateGradientFrame(for: compareButton)
        view.bringSubviewToFront(compareButton)
    }

    private func buildLayout() {
        let titleLabel = UILabel()
        titleLabel.text = "Saved"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)

        let plus = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        addButton.setImage(plus, for: .normal)
        addButton.tintColor = .darkThemeColor
        addButton.addTarget(self, action: #selector(addSearchTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        let headerRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), addButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center

        segment.selectedSegmentIndex = 0
        segment.selectedSegmentTintColor = .darkThemeColor
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .semibold)], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.darkThemeColor, .font: UIFont.systemFont(ofSize: 13, weight: .medium)], for: .normal)
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segment.heightAnchor.constraint(equalToConstant: 34).isActive = true

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SavedSearchCell.self, forCellReuseIdentifier: SavedSearchCell.identifier)
        tableView.register(CompareSelectCell.self, forCellReuseIdentifier: CompareSelectCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        compareButton.setTitle("Compare", for: .normal)
        compareButton.setTitleColor(.white, for: .normal)
        compareButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        CommonMethods.stylePrimaryButton(compareButton)
        compareButton.addTarget(self, action: #selector(openComparison), for: .touchUpInside)
        compareButton.translatesAutoresizingMaskIntoConstraints = false

        let topStack = UIStackView(arrangedSubviews: [headerRow, segment])
        topStack.axis = .vertical
        topStack.spacing = 14
        topStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStack)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(compareButton)

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 14),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emptyLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 48),

            compareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            compareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            compareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            compareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func reloadContent() {
        favorites = PropertyStore.shared.favoriteProperties()
        candidates = PropertyStore.shared.compareCandidates()
        addButton.isHidden = section != .searches
        collectionView.isHidden = section != .properties
        tableView.isHidden = section == .properties
        compareButton.isHidden = section != .compare

        switch section {
        case .properties:
            emptyLabel.text = "Tap the heart on a listing to shortlist it here."
            emptyLabel.isHidden = !favorites.isEmpty
            collectionView.reloadData()
        case .searches:
            emptyLabel.text = "Save a search from the Search tab to get alerts."
            emptyLabel.isHidden = !PropertyStore.shared.savedSearches.isEmpty
            tableView.contentInset.bottom = 8
            tableView.reloadData()
        case .compare:
            let count = PropertyStore.shared.compareIDs.count
            emptyLabel.isHidden = true
            compareButton.setTitle("Compare (\(count))", for: .normal)
            compareButton.alpha = count >= 2 ? 1 : 0.45
            compareButton.isEnabled = count >= 2
            tableView.contentInset.bottom = 70
            tableView.verticalScrollIndicatorInsets.bottom = 70
            tableView.reloadData()
        }
    }

    @objc private func segmentChanged() {
        section = Section(rawValue: segment.selectedSegmentIndex) ?? .properties
        reloadContent()
    }

    @objc private func addSearchTapped() {
        openSavedSearch(nil)
    }

    @objc private func openComparison() {
        let selected = PropertyStore.shared.comparedProperties()
        guard selected.count >= 2 else { return }
        openCompare(selected)
    }
}

extension TenantSavedVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favorites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PropertyCardCell.identifier,
            for: indexPath
        ) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = favorites[indexPath.item]
        cell.configure(with: property, isFavorite: true)
        cell.onFavorite = { [weak self] in
            PropertyStore.shared.toggleFavorite(property.id)
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

extension TenantSavedVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section == .searches ? PropertyStore.shared.savedSearches.count : candidates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if section == .searches {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedSearchCell.identifier, for: indexPath) as? SavedSearchCell else {
                return UITableViewCell()
            }
            let search = PropertyStore.shared.savedSearches[indexPath.row]
            cell.configure(search)
            cell.onAlertChange = { isOn in
                PropertyStore.shared.setAlert(id: search.id, isOn: isOn)
            }
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompareSelectCell.identifier, for: indexPath) as? CompareSelectCell else {
            return UITableViewCell()
        }
        let property = candidates[indexPath.row]
        cell.configure(property, selected: PropertyStore.shared.isCompared(property.id))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if section == .searches {
            openSavedSearch(PropertyStore.shared.savedSearches[indexPath.row])
            return
        }
            let property = candidates[indexPath.row]
            if !PropertyStore.shared.isCompared(property.id), PropertyStore.shared.compareIDs.count >= 3 {
                let alert = UIAlertController(title: "Compare", message: "You can compare up to 3 properties.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            PropertyStore.shared.toggleCompare(property.id)
            reloadContent()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard section == .searches else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            let store = PropertyStore.shared
            guard store.savedSearches.indices.contains(indexPath.row) else {
                done(false)
                return
            }
            store.deleteSearch(id: store.savedSearches[indexPath.row].id)
            self?.reloadContent()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        section == .compare ? 76 : 78
    }
}

final class SavedSearchCell: UITableViewCell {
    static let identifier = "SavedSearchCell"
    var onAlertChange: ((Bool) -> Void)?

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let alertSwitch = UISwitch()
    private let bellView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        subtitleLabel.numberOfLines = 2
        bellView.tintColor = .darkThemeColor
        alertSwitch.onTintColor = .darkThemeColor
        alertSwitch.addTarget(self, action: #selector(alertChanged), for: .valueChanged)
        let text = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        text.axis = .vertical
        text.spacing = 4
        let row = UIStackView(arrangedSubviews: [bellView, text, alertSwitch])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            bellView.widthAnchor.constraint(equalToConstant: 20),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ search: SavedSearch) {
        titleLabel.text = search.title
        subtitleLabel.text = search.subtitle
        alertSwitch.isOn = search.alertOn
        bellView.image = UIImage(systemName: search.alertOn ? "bell.fill" : "bell.slash")
    }

    @objc private func alertChanged() {
        bellView.image = UIImage(systemName: alertSwitch.isOn ? "bell.fill" : "bell.slash")
        onAlertChange?(alertSwitch.isOn)
    }
}

final class CompareSelectCell: UITableViewCell {
    static let identifier = "CompareSelectCell"

    private let photoView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.cornerRadius = 10
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        let text = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        text.axis = .vertical
        text.spacing = 3
        let row = UIStackView(arrangedSubviews: [photoView, text, checkView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            photoView.widthAnchor.constraint(equalToConstant: 56),
            photoView.heightAnchor.constraint(equalToConstant: 56),
            checkView.widthAnchor.constraint(equalToConstant: 24),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ property: PropertyItem, selected: Bool) {
        photoView.image = UIImage(named: property.imageName)
        titleLabel.text = property.title
        subtitleLabel.text = "\(property.location)  ·  \(property.priceText)"
        checkView.image = UIImage(systemName: selected ? "checkmark.circle.fill" : "circle")
        checkView.tintColor = selected ? .darkThemeColor : UIColor(white: 0.75, alpha: 1)
    }
}
