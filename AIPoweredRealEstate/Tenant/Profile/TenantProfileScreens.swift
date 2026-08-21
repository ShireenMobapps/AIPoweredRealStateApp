//
//  TenantProfileScreens.swift
//  AIPoweredRealEstate
//

import UIKit
import PhotosUI

private func stylePushed(_ controller: UIViewController, title: String) {
    controller.view.backgroundColor = .screenBackgroundColor
    controller.title = title
    controller.navigationController?.navigationBar.tintColor = .darkThemeColor
}

final class TenantEditProfileVC: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let photoHolder = UIView()
    private let photoView = UIImageView()
    private let cameraButton = UIButton(type: .custom)
    private let nameField = CustomTextField()
    private let emailField = CustomTextField()
    private let phoneField = CustomTextField()
    private let addressField = CustomTextField()
    private let saveButton = CustomButton(type: .custom)
    private var pendingPhoto: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: "Edit Profile")
        build()
        fill()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoHolder.layer.cornerRadius = photoHolder.bounds.width / 2
        photoView.layer.cornerRadius = photoView.bounds.width / 2
        cameraButton.layer.cornerRadius = cameraButton.bounds.width / 2
        CommonMethods.updateGradientFrame(for: saveButton)
        view.bringSubviewToFront(cameraButton)
        view.bringSubviewToFront(saveButton)
        saveButton.bringSubviewToFront(saveButton.titleLabel ?? saveButton)
    }

    private func build() {
        photoHolder.backgroundColor = .white
        photoHolder.clipsToBounds = true
        photoHolder.layer.borderWidth = 3
        photoHolder.layer.borderColor = UIColor.white.cgColor

        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.masksToBounds = true
        photoView.backgroundColor = UIColor.cardBorderColor
        photoView.isUserInteractionEnabled = true
        photoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        cameraButton.setImage(
            UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)),
            for: .normal
        )
        cameraButton.tintColor = .white
        cameraButton.backgroundColor = .darkThemeColor
        cameraButton.clipsToBounds = true
        cameraButton.layer.borderWidth = 3
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)

        let card = UIView()
        CommonMethods.styleFormCard(card)

        [nameField, emailField, phoneField, addressField].forEach { field in
            field.leftPadding = 14
            field.cornerRadious = 12
            field.clipsToBounds = true
            field.borderStyle = .none
            field.heightAnchor.constraint(equalToConstant: 48).isActive = true
            CommonMethods.styleTextField(field)
            field.backgroundColor = UIColor.screenBackgroundColor
        }
        nameField.placeholder = "Full name"
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        phoneField.placeholder = "Phone"
        phoneField.keyboardType = .phonePad
        addressField.placeholder = "Address"
        let mapButton = UIButton(type: .system)
        mapButton.setImage(
            UIImage(systemName: "map.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)),
            for: .normal
        )
        mapButton.tintColor = .darkThemeColor
        mapButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        mapButton.addTarget(self, action: #selector(mapTapped), for: .touchUpInside)
        addressField.rightView = mapButton
        addressField.rightViewMode = .always

        let fields = UIStackView(arrangedSubviews: [
            labeled("Full name", nameField),
            labeled("Email", emailField),
            labeled("Phone", phoneField),
            labeled("Address", addressField)
        ])
        fields.axis = .vertical
        fields.spacing = 14
        fields.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(fields)

        saveButton.setTitle("Save", for: .normal)
        saveButton.cornerRadious = 14
        saveButton.backgroundColor = .darkThemeColor
        CommonMethods.stylePrimaryButton(saveButton)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        [photoHolder, photoView, cameraButton, card, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(photoHolder)
        photoHolder.addSubview(photoView)
        view.addSubview(card)
        view.addSubview(saveButton)
        view.addSubview(cameraButton)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            photoHolder.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            photoHolder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoHolder.widthAnchor.constraint(equalToConstant: 120),
            photoHolder.heightAnchor.constraint(equalToConstant: 120),

            photoView.topAnchor.constraint(equalTo: photoHolder.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: photoHolder.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: photoHolder.trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: photoHolder.bottomAnchor),

            cameraButton.widthAnchor.constraint(equalToConstant: 38),
            cameraButton.heightAnchor.constraint(equalToConstant: 38),
            cameraButton.trailingAnchor.constraint(equalTo: photoHolder.trailingAnchor, constant: 4),
            cameraButton.bottomAnchor.constraint(equalTo: photoHolder.bottomAnchor, constant: 4),

            card.topAnchor.constraint(equalTo: photoHolder.bottomAnchor, constant: 28),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            fields.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            fields.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            fields.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            fields.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func labeled(_ title: String, _ field: UIView) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 73/255, green: 80/255, blue: 87/255, alpha: 1)
        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func fill() {
        photoView.image = TenantAccount.shared.profileImage
        nameField.text = TenantAccount.shared.name
        emailField.text = TenantAccount.shared.email
        phoneField.text = TenantAccount.shared.phone
        addressField.text = TenantAccount.shared.address
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func mapTapped() {
        let query = (addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap {
            $0.isEmpty ? nil : $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        } ?? "Punta%20Cana"
        guard let url = URL(string: "http://maps.apple.com/?q=\(query)") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func changePhotoTapped() {
        let sheet = UIAlertController(title: "Profile Photo", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default) { [weak self] _ in
            self?.openLibrary()
        })
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.openCamera()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = cameraButton
            popover.sourceRect = cameraButton.bounds
        }
        present(sheet, animated: true)
    }

    private func openLibrary() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            present(picker, animated: true)
            return
        }
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.apply(image)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        if let image { apply(image) }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func apply(_ image: UIImage) {
        pendingPhoto = image
        photoView.image = image
    }

    @objc private func saveTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else { return }
        TenantAccount.shared.name = name
        TenantAccount.shared.email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        TenantAccount.shared.phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        TenantAccount.shared.address = addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if let pendingPhoto {
            TenantAccount.shared.saveProfileImage(pendingPhoto)
        }
        navigationController?.popViewController(animated: true)
    }
}

final class TenantPreferencesVC: UIViewController {
    private var types: Set<String> = TenantAccount.shared.preferredTypes
    private var locations: Set<String> = TenantAccount.shared.preferredLocations
    private var budgetMax: Int? = TenantAccount.shared.budgetMax
    private var minBedrooms: Int? = TenantAccount.shared.minBedrooms
    private var amenities: Set<String> = TenantAccount.shared.preferredAmenities
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: "My Preferences")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 22
        contentStack.translatesAutoresizingMaskIntoConstraints = false
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
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func reload() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        addSection("Property Type", options: PropertyStore.propertyTypes, selected: types, action: #selector(typeTapped(_:)))
        addSection("Preferred Locations", options: PropertyStore.locations, selected: locations, action: #selector(locationTapped(_:)))
        addSection("Budget", options: ["Any", "Up to $1,500", "Up to $5,000", "Up to $300k", "Up to $500k", "$500k+"], selected: budgetTitle(), action: #selector(budgetTapped(_:)), multi: false)
        addSection("Bedrooms", options: ["Any", "1+", "2+", "3+", "4+"], selected: bedsTitle(), action: #selector(bedsTapped(_:)), multi: false)
        addSection("Amenities", options: PropertyStore.amenityOptions, selected: amenities, action: #selector(amenityTapped(_:)))
    }

    private func addSection(_ title: String, options: [String], selected: Set<String>, action: Selector) {
        addSection(title, options: options, selected: nil, action: action, multi: true, selectedSet: selected)
    }

    private func addSection(_ title: String, options: [String], selected: String, action: Selector, multi: Bool) {
        addSection(title, options: options, selected: selected, action: action, multi: false, selectedSet: [])
    }

    private func addSection(_ title: String, options: [String], selected: String?, action: Selector, multi: Bool, selectedSet: Set<String>) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        let row = UIScrollView()
        row.showsHorizontalScrollIndicator = false
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
        for option in options {
            let isOn = multi ? selectedSet.contains(option) : option == selected
            let button = CommonMethods.makeFilterChip(title: option, selected: isOn)
            button.addTarget(self, action: action, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        let section = UIStackView(arrangedSubviews: [label, row])
        section.axis = .vertical
        section.spacing = 10
        contentStack.addArrangedSubview(section)
    }

    @objc private func typeTapped(_ sender: UIButton) {
        let current = types
        types = toggled(current, chipTitle(sender))
        reload()
    }

    @objc private func locationTapped(_ sender: UIButton) {
        let current = locations
        locations = toggled(current, chipTitle(sender))
        reload()
    }

    @objc private func amenityTapped(_ sender: UIButton) {
        let current = amenities
        amenities = toggled(current, chipTitle(sender))
        reload()
    }

    private func chipTitle(_ sender: UIButton) -> String? {
        sender.configuration?.title ?? sender.title(for: .normal)
    }

    @objc private func budgetTapped(_ sender: UIButton) {
        switch sender.configuration?.title {
        case "Up to $1,500": budgetMax = 1_500
        case "Up to $5,000": budgetMax = 5_000
        case "Up to $300k": budgetMax = 300_000
        case "Up to $500k": budgetMax = 500_000
        case "$500k+": budgetMax = 900_000
        default: budgetMax = nil
        }
        reload()
    }

    @objc private func bedsTapped(_ sender: UIButton) {
        let title = sender.configuration?.title ?? ""
        minBedrooms = title == "Any" ? nil : Int(title.replacingOccurrences(of: "+", with: ""))
        reload()
    }

    @objc private func saveTapped() {
        TenantAccount.shared.preferredTypes = types
        TenantAccount.shared.preferredLocations = locations
        TenantAccount.shared.budgetMax = budgetMax
        TenantAccount.shared.minBedrooms = minBedrooms
        TenantAccount.shared.preferredAmenities = amenities
        navigationController?.popViewController(animated: true)
    }

    private func toggled(_ current: Set<String>, _ value: String?) -> Set<String> {
        guard let value, !value.isEmpty else { return current }
        var next = current
        if next.contains(value) {
            next.remove(value)
        } else {
            next.insert(value)
        }
        return next
    }

    private func budgetTitle() -> String {
        switch budgetMax {
        case 1_500: return "Up to $1,500"
        case 5_000: return "Up to $5,000"
        case 300_000: return "Up to $300k"
        case 500_000: return "Up to $500k"
        case 900_000: return "$500k+"
        default: return "Any"
        }
    }

    private func bedsTitle() -> String {
        guard let minBedrooms else { return "Any" }
        return "\(minBedrooms)+"
    }
}

final class TenantNotificationsVC: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let items: [(title: String, detail: String)] = [
        ("New Matching Properties", "When a listing matches your preferences"),
        ("Saved Property Updates", "Price or status changes on saved homes"),
        ("Search Alerts", "New results for saved searches"),
        ("Agent Enquiries", "Replies to your contact requests")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: "Notifications")
        tableView.backgroundColor = .screenBackgroundColor
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension TenantNotificationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = items[indexPath.row].title
        config.secondaryText = items[indexPath.row].detail
        config.textProperties.font = .systemFont(ofSize: 16, weight: .medium)
        config.secondaryTextProperties.color = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        cell.contentConfiguration = config
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        let toggle = UISwitch()
        toggle.onTintColor = .darkThemeColor
        toggle.isOn = value(for: indexPath.row)
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(changed(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        return cell
    }

    private func value(for index: Int) -> Bool {
        switch index {
        case 0: return TenantAccount.shared.notifyMatching
        case 1: return TenantAccount.shared.notifySavedUpdates
        case 2: return TenantAccount.shared.notifySearchAlerts
        default: return TenantAccount.shared.notifyEnquiries
        }
    }

    @objc private func changed(_ sender: UISwitch) {
        switch sender.tag {
        case 0: TenantAccount.shared.notifyMatching = sender.isOn
        case 1: TenantAccount.shared.notifySavedUpdates = sender.isOn
        case 2: TenantAccount.shared.notifySearchAlerts = sender.isOn
        default: TenantAccount.shared.notifyEnquiries = sender.isOn
        }
    }
}

final class TenantProfileSearchesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: "Saved Searches")
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SavedSearchCell.self, forCellReuseIdentifier: SavedSearchCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        emptyLabel.text = "No saved searches yet."
        emptyLabel.isHidden = !PropertyStore.shared.savedSearches.isEmpty
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PropertyStore.shared.savedSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openSavedSearch(PropertyStore.shared.savedSearches[indexPath.row])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 78 }
}

final class TenantEnquiryHistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: "Enquiry History")
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "You haven't contacted an agent yet."
        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        emptyLabel.isHidden = !PropertyStore.shared.enquiries.isEmpty
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PropertyStore.shared.enquiries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = PropertyStore.shared.enquiries[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.propertyTitle
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        config.secondaryText = "\(item.agentName)  ·  \(formatter.string(from: item.date))\n\(item.message)"
        config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        config.secondaryTextProperties.numberOfLines = 3
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}

final class TenantRecentlyViewedVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let emptyLabel = UILabel()
    private var items: [PropertyItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: "Recently Viewed")
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Properties you open will appear here."
        emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        items = PropertyStore.shared.recentlyViewed
        emptyLabel.isHidden = !items.isEmpty
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PropertyCardCell.identifier, for: indexPath) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = items[indexPath.item]
        cell.configure(with: property, isFavorite: PropertyStore.shared.isFavorite(property.id))
        cell.onFavorite = { [weak self] in
            PropertyStore.shared.toggleFavorite(property.id)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openPropertyDetails(items[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: 268)
    }
}

final class TenantOptionPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let titleText: String
    private let options: [String]
    private var selected: String
    private let onSelect: (String) -> Void
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(titleText: String, options: [String], selected: String, onSelect: @escaping (String) -> Void) {
        self.titleText = titleText
        self.options = options
        self.selected = selected
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: titleText)
        tableView.backgroundColor = .screenBackgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let value = options[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = value
        cell.contentConfiguration = config
        cell.accessoryType = value == selected ? .checkmark : .none
        cell.tintColor = .darkThemeColor
        cell.backgroundColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = options[indexPath.row]
        onSelect(selected)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}

final class TenantTextPageVC: UIViewController {
    private let titleText: String
    private let body: String

    init(titleText: String, body: String) {
        self.titleText = titleText
        self.body = body
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        stylePushed(self, title: titleText)
        let label = UILabel()
        label.text = body
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        label.numberOfLines = 0
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(label)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

enum TenantLegalContent {
    static let help = """
    Need help finding a home or using the app?

    • Search by location or keyword, or tap the sparkles icon for AI Search.
    • Save listings with the heart and compare up to 3 properties.
    • Turn on search alerts from Saved Searches to hear about new matches.

    Contact support: support@aipoweredrealestate.com
    """

    static let terms = """
    Terms & Conditions

    By using AI Powered Real Estate you agree to use listing data for personal property search only. Prices, availability, and details are provided by agents and portals and may change without notice.

    Enquiries you send are shared with the listing agent so they can contact you about that property.
    """

    static let privacy = """
    Privacy Policy

    We store your profile, saved searches, favorites, and enquiry history on this device to personalize search and alerts. We do not sell your contact details.

    You can update or remove your information from Edit Profile, or log out at any time.
    """
}
