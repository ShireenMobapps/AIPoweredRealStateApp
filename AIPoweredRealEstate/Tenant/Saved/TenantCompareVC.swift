//
//  TenantCompareVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class TenantCompareVC: UIViewController {

    var properties: [PropertyItem] = []

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        title = "Compare"
        navigationController?.navigationBar.tintColor = .darkThemeColor
        buildLayout()
        populate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    private func populate() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(headerRow())
        rows().forEach { title, values in
            contentStack.addArrangedSubview(divider())
            contentStack.addArrangedSubview(valueRow(title: title, values: values))
        }
        contentStack.addArrangedSubview(spacer(16))
        contentStack.addArrangedSubview(summaryCard())
    }

    private func headerRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        row.addArrangedSubview(columnLabel(" ", bold: true))
        properties.forEach { property in
            let photo = UIImageView(image: UIImage(named: property.imageName))
            photo.contentMode = .scaleAspectFill
            photo.clipsToBounds = true
            photo.layer.cornerRadius = 10
            photo.heightAnchor.constraint(equalToConstant: 72).isActive = true
            let name = UILabel()
            name.text = property.title
            name.font = .systemFont(ofSize: 12, weight: .semibold)
            name.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
            name.textAlignment = .center
            name.numberOfLines = 2
            let column = UIStackView(arrangedSubviews: [photo, name])
            column.axis = .vertical
            column.spacing = 6
            row.addArrangedSubview(column)
        }
        let padded = UIStackView(arrangedSubviews: [row])
        padded.isLayoutMarginsRelativeArrangement = true
        padded.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 12, right: 0)
        return padded
    }

    private func rows() -> [(String, [String])] {
        let amenityFlags = ["Power Backup", "Furnished", "Pool", "Parking", "Garden", "A/C", "Gym", "Security"]
        var items: [(String, [String])] = [
            ("Price", properties.map(\.priceText)),
            ("Location", properties.map(\.location)),
            ("Bedrooms", properties.map { "\($0.bedrooms)" }),
            ("Bathrooms", properties.map { "\($0.bathrooms)" }),
            ("Area", properties.map(\.area)),
            ("Cost / m²", properties.map(\.costPerSquareMeterText)),
            ("Amenities", properties.map { $0.amenities.joined(separator: ", ") })
        ]
        items.append(contentsOf: amenityFlags.map { name in
            (name, properties.map { property -> String in
                if name == "Furnished" { return property.isFurnished ? "Yes" : "No" }
                return property.hasAmenity(name) ? "Yes" : "No"
            })
        })
        return items
    }

    private func valueRow(title: String, values: [String]) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        row.alignment = .top
        row.addArrangedSubview(columnLabel(title, bold: true))
        values.forEach { row.addArrangedSubview(columnLabel($0, bold: false)) }
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return row
    }

    private func columnLabel(_ text: String, bold: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: bold ? .semibold : .regular)
        label.textColor = bold
            ? UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
            : UIColor(red: 73/255, green: 80/255, blue: 87/255, alpha: 1)
        label.numberOfLines = 0
        return label
    }

    private func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.cardBorderColor
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    private func spacer(_ height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }

    private func summaryCard() -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "sparkles"))
        icon.tintColor = .darkThemeColor
        let title = UILabel()
        title.text = "AI Summary"
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        let header = UIStackView(arrangedSubviews: [icon, title, UIView()])
        header.axis = .horizontal
        header.spacing = 8
        header.alignment = .center

        let body = UILabel()
        body.text = PropertyStore.shared.comparisonSummary(for: properties)
        body.font = .systemFont(ofSize: 15, weight: .regular)
        body.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        body.numberOfLines = 0

        let inner = UIStackView(arrangedSubviews: [header, body])
        inner.axis = .vertical
        inner.spacing = 10
        inner.translatesAutoresizingMaskIntoConstraints = false

        let card = UIView()
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        CommonMethods.styleFormCard(card)
        return card
    }
}
