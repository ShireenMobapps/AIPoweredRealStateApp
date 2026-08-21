//
//  TenantHomeVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantHomeVC: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var aiSearchCardView: CustomView!
    @IBOutlet weak var quickSearchStack: UIStackView!
    @IBOutlet weak var recommendedCollection: UICollectionView!
    @IBOutlet weak var recentlyCollection: UICollectionView!

    private var selectedFilter: String?
    private var recommended: [PropertyItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        setupCollections()
        setupQuickSearch()
        reloadProperties()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadProperties()
        showTenantProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        recommendedCollection.collectionViewLayout.invalidateLayout()
        recentlyCollection.collectionViewLayout.invalidateLayout()
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.styleFormCard(aiSearchCardView)
        showTenantProfile()
    }

    private func showTenantProfile() {
        nameLabel.text = TenantAccount.shared.name
        addressLabel.text = TenantAccount.shared.address
        profileImageView.image = TenantAccount.shared.profileImage
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 24
    }

    private func setupCollections() {
        [recommendedCollection, recentlyCollection].forEach { collection in
            collection?.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
            collection?.dataSource = self
            collection?.delegate = self
            collection?.showsHorizontalScrollIndicator = false
            collection?.backgroundColor = .clear
            collection?.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            if let layout = collection?.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 12
            }
        }
    }

    private func setupQuickSearch() {
        quickSearchStack.arrangedSubviews
            .compactMap { $0 as? UIButton }
            .forEach { button in
                styleChip(button, selected: false)
            }
    }

    private func styleChip(_ button: UIButton, selected: Bool) {
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        if selected {
            button.backgroundColor = .darkThemeColor
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.darkThemeColor, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.darkThemeColor.withAlphaComponent(0.25).cgColor
        }
    }

    private func reloadProperties() {
        recommended = PropertyStore.shared.recommended(filter: selectedFilter)
        recommendedCollection.reloadData()
        recentlyCollection.reloadData()
    }

    @IBAction func aiSearchTapped(_ sender: UIButton) {
        guard let aiVC = storyboard?.instantiateViewController(withIdentifier: "TenantAISearchVC") as? TenantAISearchVC else {
            return
        }
        aiVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(aiVC, animated: true)
    }

    @IBAction func quickSearchTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal) ?? ""
        if selectedFilter == title {
            selectedFilter = nil
        } else {
            selectedFilter = title
        }
        quickSearchStack.arrangedSubviews
            .compactMap { $0 as? UIButton }
            .forEach { button in
                styleChip(button, selected: button.title(for: .normal) == selectedFilter)
            }
        reloadProperties()
    }
}

extension TenantHomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == recommendedCollection
            ? recommended.count
            : PropertyStore.shared.recentlyViewed.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PropertyCardCell.identifier,
            for: indexPath
        ) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = collectionView == recommendedCollection
            ? recommended[indexPath.item]
            : PropertyStore.shared.recentlyViewed[indexPath.item]
        cell.configure(with: property, isFavorite: PropertyStore.shared.isFavorite(property.id))
        cell.onFavorite = { [weak self] in
            PropertyStore.shared.toggleFavorite(property.id)
            self?.reloadProperties()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let property = collectionView == recommendedCollection
            ? recommended[indexPath.item]
            : PropertyStore.shared.recentlyViewed[indexPath.item]
        openPropertyDetails(property)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 236, height: collectionView.bounds.height)
    }
}
