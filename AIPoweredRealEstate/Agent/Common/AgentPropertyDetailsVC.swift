//
//  AgentPropertyDetailsVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentPropertyDetailsVC: UIViewController {

    var property: PropertyItem?

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var marketingButton: CustomButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var specsLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!
    @IBOutlet weak var listedByLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.cornerRadius = 18
        CommonMethods.stylePrimaryButton(marketingButton)
        styleOutline(compareButton)
        styleOutline(reportButton)
        typeLabel.layer.cornerRadius = 8
        typeLabel.clipsToBounds = true
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        refreshActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: marketingButton)
    }

    private func styleOutline(_ button: UIButton) {
        button.setTitleColor(.darkThemeColor, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkThemeColor.cgColor
    }

    private func populate() {
        guard let property else { return }
        photoView.image = UIImage(named: property.imageName)
        typeLabel.text = "  \(property.listingType) · \(property.propertyType) · \(property.source)  "
        priceLabel.text = property.priceText
        titleLabel.text = property.title
        locationLabel.text = "\(property.location)  ·  \(property.source)"
        specsLabel.text = "\(property.detailSpecsText)  ·  \(property.costPerSquareMeterText)"
        summaryLabel.text = property.summary
        amenitiesLabel.text = "Amenities: \(property.amenities.joined(separator: " · "))"
        listedByLabel.text = "Listed with \(property.agentName) · \(property.agentAgency)"
        refreshActions()
    }

    private func refreshActions() {
        guard let property else { return }
        let saved = AgentStore.shared.isFavorite(property.id)
        favoriteButton.setImage(
            UIImage(systemName: saved ? "heart.fill" : "heart")?.withTintColor(
                saved ? UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1) : UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1),
                renderingMode: .alwaysOriginal
            ),
            for: .normal
        )
        compareButton.setTitle(AgentStore.shared.isCompared(property.id) ? "In compare" : "Add to compare", for: .normal)
    }

    @IBAction func favoriteTapped(_ sender: Any) {
        guard let property else { return }
        AgentStore.shared.toggleFavorite(property.id)
        refreshActions()
    }

    @IBAction func compareTapped(_ sender: Any) {
        guard let property else { return }
        let message = AgentStore.shared.toggleCompare(property.id)
        refreshActions()
        let alert = UIAlertController(title: "Compare", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func marketingTapped(_ sender: Any) {
        guard let property else { return }
        let vc: AgentMarketingVC = AgentStoryboard.load("AgentMarketingVC")
        vc.property = property
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func reportTapped(_ sender: Any) {
        guard let property else { return }
        let vc: AgentReportVC = AgentStoryboard.load("AgentReportVC")
        vc.properties = [property]
        navigationController?.pushViewController(vc, animated: true)
    }
}
