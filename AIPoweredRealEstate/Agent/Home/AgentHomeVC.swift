//
//  AgentHomeVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentHomeVC: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var agencyLabel: UILabel!
    @IBOutlet weak var bellButton: UIButton!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var metricsLabel: UILabel!
    @IBOutlet weak var aiSearchCardView: CustomView!
    @IBOutlet weak var quickSearchCardView: CustomView!
    @IBOutlet weak var compareCardView: CustomView!
    @IBOutlet weak var marketingCardView: CustomView!
    @IBOutlet weak var reportCardView: CustomView!
    @IBOutlet weak var leadsCardView: CustomView!
    @IBOutlet weak var recentHost: UIStackView!
    @IBOutlet weak var savedTitleLabel: UILabel!
    @IBOutlet weak var savedCollection: UICollectionView!
    @IBOutlet weak var savedTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var savedCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var savedCollectionTop: NSLayoutConstraint!
    @IBOutlet weak var recommendedAfterSaved: NSLayoutConstraint!
    @IBOutlet weak var recommendedCollection: UICollectionView!
    @IBOutlet weak var clientHost: UIStackView!

    private var saved: [PropertyItem] = []
    private var recommended: [PropertyItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        setupCollections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        savedCollection.collectionViewLayout.invalidateLayout()
        recommendedCollection.collectionViewLayout.invalidateLayout()
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        [aiSearchCardView, quickSearchCardView, compareCardView, marketingCardView, reportCardView, leadsCardView].forEach {
            if let card = $0 { CommonMethods.styleFormCard(card) }
        }
        badgeLabel.clipsToBounds = true
        badgeLabel.layer.cornerRadius = 8
    }

    private func setupCollections() {
        [savedCollection, recommendedCollection].forEach { collection in
            collection?.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
            collection?.dataSource = self
            collection?.delegate = self
            collection?.showsHorizontalScrollIndicator = false
            collection?.backgroundColor = .clear
            if let layout = collection?.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 12
            }
        }
    }

    private func reload() {
        nameLabel.text = AgentAccount.shared.name
        agencyLabel.text = AgentAccount.shared.agency
        profileImageView.image = AgentAccount.shared.profileImage
        saved = AgentStore.shared.favoriteProperties()
        recommended = Array(PropertyStore.shared.all.prefix(6))
        metricsLabel.text = "\(PropertyStore.sources.count) portals  ·  \(PropertyStore.shared.all.count) listings  ·  \(AgentStore.shared.openLeadCount) open leads  ·  \(saved.count) saved"
        updateSavedSectionVisibility()
        savedCollection.reloadData()
        recommendedCollection.reloadData()
        rebuildRecent()
        rebuildClients()
        let unread = AgentStore.shared.unreadCount
        badgeLabel.isHidden = unread == 0
        badgeLabel.text = "\(unread)"
    }

    private func rebuildRecent() {
        recentHost.arrangedSubviews.forEach { $0.removeFromSuperview() }
        AgentStore.shared.recentSearches.forEach { query in
            let chip = CommonMethods.makeFilterChip(title: query, selected: false)
            chip.addTarget(self, action: #selector(recentSearchTapped(_:)), for: .touchUpInside)
            recentHost.addArrangedSubview(chip)
        }
    }

    private func rebuildClients() {
        clientHost.arrangedSubviews.forEach { $0.removeFromSuperview() }
        AgentStore.shared.clientSearches.prefix(4).forEach { item in
            let card = UIControl()
            card.backgroundColor = .white
            card.layer.cornerRadius = 14
            CommonMethods.styleFormCard(card)
            let name = UILabel()
            name.text = item.client
            name.font = .systemFont(ofSize: 14, weight: .semibold)
            let query = UILabel()
            query.text = item.query
            query.font = .systemFont(ofSize: 13, weight: .regular)
            query.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
            query.numberOfLines = 2
            let text = UIStackView(arrangedSubviews: [name, query])
            text.axis = .vertical
            text.spacing = 2
            text.isUserInteractionEnabled = false
            text.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(text)
            NSLayoutConstraint.activate([
                card.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
                text.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                text.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                text.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                text.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
            ])
            card.accessibilityLabel = item.query
            card.addTarget(self, action: #selector(clientSearchTapped(_:)), for: .touchUpInside)
            clientHost.addArrangedSubview(card)
        }
    }

    @IBAction func notificationsTapped(_ sender: Any) {
        let vc: AgentNotificationsVC = AgentStoryboard.load("AgentNotificationsVC")
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func aiSearchTapped(_ sender: Any) {
        openAISearch()
    }

    @IBAction func compareTapped(_ sender: Any) {
        AgentStore.pendingSavedSection = 2
        tabBarController?.selectedIndex = 2
    }

    @IBAction func marketingTapped(_ sender: Any) {
        let vc: AgentMarketingVC = AgentStoryboard.load("AgentMarketingVC")
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func reportTapped(_ sender: Any) {
        let compared = AgentStore.shared.comparedProperties()
        let listings = compared.count >= 2 ? compared : Array(PropertyStore.shared.all.prefix(3))
        let vc: AgentReportVC = AgentStoryboard.load("AgentReportVC")
        vc.properties = listings
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func leadsTapped(_ sender: Any) {
        let vc: AgentLeadsVC = AgentStoryboard.load("AgentLeadsVC")
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func updateSavedSectionVisibility() {
        let hasSaved = !saved.isEmpty
        savedTitleLabel.isHidden = !hasSaved
        savedCollection.isHidden = !hasSaved
        savedTitleHeight.constant = hasSaved ? 22 : 0
        savedCollectionHeight.constant = hasSaved ? 268 : 0
        savedCollectionTop.constant = hasSaved ? 8 : 0
        recommendedAfterSaved.constant = hasSaved ? 20 : 0
    }

    @objc private func recentSearchTapped(_ sender: UIButton) {
        openAISearch(prefilled: sender.configuration?.title)
    }

    @objc private func clientSearchTapped(_ sender: UIControl) {
        openAISearch(prefilled: sender.accessibilityLabel)
    }
}

extension AgentHomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == savedCollection ? saved.count : recommended.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PropertyCardCell.identifier,
            for: indexPath
        ) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = collectionView == savedCollection ? saved[indexPath.item] : recommended[indexPath.item]
        cell.configure(with: property, isFavorite: AgentStore.shared.isFavorite(property.id), showsSource: true)
        cell.onFavorite = { [weak self] in
            AgentStore.shared.toggleFavorite(property.id)
            self?.reload()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let property = collectionView == savedCollection ? saved[indexPath.item] : recommended[indexPath.item]
        openPropertyDetails(property)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 236, height: collectionView.bounds.height)
    }
}
