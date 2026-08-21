//
//  PropertyCardCell.swift
//  AIPoweredRealEstate
//

import UIKit

final class PropertyCardCell: UICollectionViewCell {

    static let identifier = "PropertyCardCell"
    static var nib: UINib { UINib(nibName: identifier, bundle: nil) }

    var onFavorite: (() -> Void)?

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var typeBadge: UILabel!
    @IBOutlet weak var favoriteCircle: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var specsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyChrome()
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }

    func configure(with property: PropertyItem, isFavorite: Bool, showsSource: Bool = false) {
        titleLabel.text = property.title
        locationLabel.text = showsSource ? "\(property.location)  ·  \(property.source)" : property.location
        priceLabel.text = property.priceText
        specsLabel.text = property.specsText
        typeBadge.text = " \(property.listingType) · \(property.propertyType) "
        photoImageView.image = UIImage(named: property.imageName)
        let heartRed = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
        let heartName = isFavorite ? "heart.fill" : "heart"
        let heartColor: UIColor = isFavorite ? heartRed : UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        favoriteButton.setImage(
            UIImage(systemName: heartName)?.withTintColor(heartColor, renderingMode: .alwaysOriginal),
            for: .normal
        )
    }

    private func applyChrome() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.darkThemeColor.cgColor
        cardView.layer.shadowOpacity = 0.10
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.masksToBounds = false

        imageContainer.layer.cornerRadius = 18
        imageContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageContainer.clipsToBounds = true

        typeBadge.layer.cornerRadius = 10
        typeBadge.clipsToBounds = true

        favoriteCircle.layer.cornerRadius = 18
        favoriteCircle.clipsToBounds = true
    }

    @objc private func favoriteTapped() {
        onFavorite?()
    }
}
