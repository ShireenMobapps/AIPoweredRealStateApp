//
//  TenantFiltersVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class TenantFiltersVC: UIViewController {

    var criteria = PropertySearchCriteria()
    var onApply: ((PropertySearchCriteria) -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        title = "Filters"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(applyTapped))
        navigationController?.navigationBar.tintColor = .darkThemeColor
        buildLayout()
        reloadChips()
    }

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 22
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    private func addSection(_ title: String, options: [String], selected: String?, action: Selector, multi: Bool = false) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)

        let row = UIScrollView()
        row.showsHorizontalScrollIndicator = false
        row.tag = title.hashValue
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: row.topAnchor),
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -4),
            stack.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: 36),
            row.heightAnchor.constraint(equalToConstant: 36)
        ])
        stack.accessibilityIdentifier = title

        for option in options {
            let isOn: Bool
            if multi {
                isOn = criteria.amenities.contains(option)
            } else {
                isOn = option == selected
            }
            let button = CommonMethods.makeFilterChip(title: option, selected: isOn)
            button.addTarget(self, action: action, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        let section = UIStackView(arrangedSubviews: [label, row])
        section.axis = .vertical
        section.spacing = 10
        contentStack.addArrangedSubview(section)
    }

    private func reloadChips() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addSection("Location", options: ["Any"] + PropertyStore.locations, selected: criteria.location ?? "Any", action: #selector(locationTapped(_:)))
        addSection("Property Type", options: ["Any"] + PropertyStore.propertyTypes, selected: criteria.propertyType ?? "Any", action: #selector(typeTapped(_:)))
        addSection("Price Range", options: ["Any", "Up to $1,500", "Up to $5,000", "Up to $300k", "Up to $500k", "$500k+"], selected: priceTitle(), action: #selector(priceTapped(_:)))
        addSection("Bedrooms", options: ["Any", "1+", "2+", "3+", "4+"], selected: bedsTitle(), action: #selector(bedsTapped(_:)))
        addSection("Bathrooms", options: ["Any", "1+", "2+", "3+"], selected: bathsTitle(), action: #selector(bathsTapped(_:)))
        addSection("Property Size", options: ["Any", "80+ m²", "150+ m²", "300+ m²"], selected: areaTitle(), action: #selector(areaTapped(_:)))
        addSection("Furnished", options: ["Any", "Yes", "No"], selected: furnishedTitle(), action: #selector(furnishedTapped(_:)))
        addSection("Amenities", options: PropertyStore.amenityOptions, selected: nil, action: #selector(amenityTapped(_:)), multi: true)

        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        applyButton.setTitleColor(.white, for: .normal)
        CommonMethods.stylePrimaryButton(applyButton)
        applyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(applyButton)
    }

    @objc private func locationTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        criteria.location = title == "Any" ? nil : title
        reloadChips()
    }

    @objc private func typeTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        criteria.propertyType = title == "Any" ? nil : title
        reloadChips()
    }

    @objc private func priceTapped(_ sender: UIButton) {
        switch sender.configuration?.title {
        case "Up to $1,500":
            criteria.minPrice = nil
            criteria.maxPrice = 1_500
        case "Up to $5,000":
            criteria.minPrice = nil
            criteria.maxPrice = 5_000
        case "Up to $300k":
            criteria.minPrice = nil
            criteria.maxPrice = 300_000
        case "Up to $500k":
            criteria.minPrice = nil
            criteria.maxPrice = 500_000
        case "$500k+":
            criteria.minPrice = 500_000
            criteria.maxPrice = nil
        default:
            criteria.minPrice = nil
            criteria.maxPrice = nil
        }
        reloadChips()
    }

    @objc private func bedsTapped(_ sender: UIButton) {
        criteria.minBedrooms = intPrefix(sender.configuration?.title)
        reloadChips()
    }

    @objc private func bathsTapped(_ sender: UIButton) {
        criteria.minBathrooms = intPrefix(sender.configuration?.title)
        reloadChips()
    }

    @objc private func areaTapped(_ sender: UIButton) {
        switch sender.configuration?.title {
        case "80+ m²": criteria.minArea = 80; criteria.maxArea = nil
        case "150+ m²": criteria.minArea = 150; criteria.maxArea = nil
        case "300+ m²": criteria.minArea = 300; criteria.maxArea = nil
        default: criteria.minArea = nil; criteria.maxArea = nil
        }
        reloadChips()
    }

    @objc private func furnishedTapped(_ sender: UIButton) {
        switch sender.configuration?.title {
        case "Yes": criteria.furnished = true
        case "No": criteria.furnished = false
        default: criteria.furnished = nil
        }
        reloadChips()
    }

    @objc private func amenityTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        if criteria.amenities.contains(title) {
            criteria.amenities.remove(title)
        } else {
            criteria.amenities.insert(title)
        }
        reloadChips()
    }

    @objc private func resetTapped() {
        criteria.resetFilters()
        reloadChips()
    }

    @objc private func applyTapped() {
        onApply?(criteria)
        dismiss(animated: true)
    }

    private func intPrefix(_ title: String?) -> Int? {
        guard let title, title != "Any" else { return nil }
        return Int(title.replacingOccurrences(of: "+", with: ""))
    }

    private func priceTitle() -> String {
        if criteria.minPrice == 500_000 { return "$500k+" }
        switch criteria.maxPrice {
        case 1_500: return "Up to $1,500"
        case 5_000: return "Up to $5,000"
        case 300_000: return "Up to $300k"
        case 500_000: return "Up to $500k"
        default: return "Any"
        }
    }

    private func bedsTitle() -> String {
        guard let value = criteria.minBedrooms else { return "Any" }
        return "\(value)+"
    }

    private func bathsTitle() -> String {
        guard let value = criteria.minBathrooms else { return "Any" }
        return "\(value)+"
    }

    private func areaTitle() -> String {
        switch criteria.minArea {
        case 80: return "80+ m²"
        case 150: return "150+ m²"
        case 300: return "300+ m²"
        default: return "Any"
        }
    }

    private func furnishedTitle() -> String {
        switch criteria.furnished {
        case true: return "Yes"
        case false: return "No"
        default: return "Any"
        }
    }
}
