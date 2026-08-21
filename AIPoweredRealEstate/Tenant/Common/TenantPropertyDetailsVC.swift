//
//  TenantPropertyDetailsVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantPropertyDetailsVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageContainerView: CustomView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var typeBadgeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var specsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var agentAgencyLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCircle: UIView!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var contactButton: CustomButton!

    var property: PropertyItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateFavoriteTitle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: contactButton)
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        imageContainerView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        CommonMethods.stylePrimaryButton(contactButton)
        style(action: compareButton)
        typeBadgeLabel.layer.cornerRadius = 10
        typeBadgeLabel.clipsToBounds = true
        favoriteCircle.backgroundColor = .white
        favoriteCircle.layer.cornerRadius = 18
        favoriteCircle.clipsToBounds = true
        favoriteButton.backgroundColor = .clear
        favoriteButton.setTitle(nil, for: .normal)
    }

    private func style(action button: UIButton) {
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkThemeColor.cgColor
        button.setTitleColor(.darkThemeColor, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }

    private func populate() {
        guard let property else { return }
        titleLabel.text = property.title
        priceLabel.text = property.priceText
        locationLabel.text = "\(property.location)  ·  \(property.source)"
        specsLabel.text = property.detailSpecsText
        descriptionLabel.text = property.summary
        amenitiesLabel.text = property.amenities.joined(separator: "  ·  ")
        agentNameLabel.text = property.agentName
        agentAgencyLabel.text = property.agentAgency
        typeBadgeLabel.text = "  \(property.listingType) · \(property.propertyType)  "
        photoImageView.image = UIImage(named: property.imageName)
        updateFavoriteTitle()
    }

    private func updateFavoriteTitle() {
        guard let property else { return }
        let saved = PropertyStore.shared.isFavorite(property.id)
        let heartRed = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        let heartName = saved ? "heart.fill" : "heart"
        let heartColor: UIColor = saved ? heartRed : UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        favoriteButton.setImage(
            UIImage(systemName: heartName)?.withTintColor(heartColor, renderingMode: .alwaysOriginal),
            for: .normal
        )
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func favoriteTapped(_ sender: UIButton) {
        guard let property else { return }
        PropertyStore.shared.toggleFavorite(property.id)
        updateFavoriteTitle()
    }

    @IBAction func compareTapped(_ sender: UIButton) {
        guard let property else { return }
        let message = PropertyStore.shared.addToCompare(property.id)
        let alert = UIAlertController(title: "Compare", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func contactTapped(_ sender: UIButton) {
        guard let contactVC = storyboard?.instantiateViewController(withIdentifier: "TenantContactAgentVC") as? TenantContactAgentVC else {
            return
        }
        contactVC.property = property
        navigationController?.pushViewController(contactVC, animated: true)
    }
}
