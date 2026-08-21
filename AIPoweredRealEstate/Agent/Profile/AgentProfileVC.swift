//
//  AgentProfileVC.swift
//  AIPoweredRealEstate
//

import UIKit
import PhotosUI

final class AgentProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private enum Row: CaseIterable {
        case edit, leads, notifications, clients, help, logout

        var title: String {
            switch self {
            case .edit: return "Edit Profile"
            case .leads: return "Leads"
            case .notifications: return "Notifications"
            case .clients: return "Client searches"
            case .help: return "Help & Support"
            case .logout: return "Logout"
            }
        }

        var icon: String {
            switch self {
            case .edit: return "pencil"
            case .leads: return "person.badge.plus"
            case .notifications: return "bell.fill"
            case .clients: return "person.2.fill"
            case .help: return "questionmark.circle.fill"
            case .logout: return "rectangle.portrait.and.arrow.right"
            }
        }
    }

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var agencyLabel: UILabel!
    @IBOutlet weak var profileCardView: CustomView!
    @IBOutlet weak var tableView: UITableView!
    private let rows = Row.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.styleFormCard(profileCardView)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.identifier)
        tableView.tableFooterView = UIView()
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        nameLabel.text = AgentAccount.shared.name
        agencyLabel.text = "\(AgentAccount.shared.agency)  ·  \(AgentAccount.shared.email)"
        photoView.image = AgentAccount.shared.profileImage
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoView.layer.cornerRadius = photoView.bounds.width / 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.identifier, for: indexPath) as? ProfileMenuCell else {
            return UITableViewCell()
        }
        let row = rows[indexPath.row]
        let subtitle: String?
        switch row {
        case .leads: subtitle = "\(AgentStore.shared.openLeadCount) open"
        case .notifications:
            let unread = AgentStore.shared.unreadCount
            subtitle = unread == 0 ? nil : "\(unread) unread"
        default: subtitle = nil
        }
        cell.configure(icon: row.icon, title: row.title, subtitle: subtitle, isDestructive: row == .logout)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .edit:
            push(AgentStoryboard.load("AgentEditProfileVC"))
        case .leads:
            push(AgentStoryboard.load("AgentLeadsVC"))
        case .notifications:
            push(AgentStoryboard.load("AgentNotificationsVC"))
        case .clients:
            AgentStore.pendingSavedSection = 1
            tabBarController?.selectedIndex = 2
        case .help:
            push(TenantTextPageVC(titleText: "Help & Support", body: TenantLegalContent.help))
        case .logout:
            logout()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 54 }

    private func push(_ controller: UIViewController) {
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func logout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            let welcome = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeVC")
            let nav = UINavigationController(rootViewController: welcome)
            nav.setNavigationBarHidden(true, animated: false)
            CommonMethods.setRootViewController(nav)
        })
        present(alert, animated: true)
    }
}

final class AgentEditProfileVC: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameField: CustomTextField!
    @IBOutlet weak var agencyField: CustomTextField!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var phoneField: CustomTextField!
    @IBOutlet weak var saveButton: CustomButton!
    @IBOutlet weak var formCardView: CustomView!
    private var pendingPhoto: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.isUserInteractionEnabled = true
        photoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhoto)))
        [nameField, agencyField, emailField, phoneField].forEach { CommonMethods.styleTextField($0) }
        CommonMethods.styleFormCard(formCardView)
        CommonMethods.stylePrimaryButton(saveButton)
        fill()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoView.layer.cornerRadius = photoView.bounds.width / 2
        CommonMethods.updateGradientFrame(for: saveButton)
    }

    private func fill() {
        photoView.image = AgentAccount.shared.profileImage
        nameField.text = AgentAccount.shared.name
        agencyField.text = AgentAccount.shared.agency
        emailField.text = AgentAccount.shared.email
        phoneField.text = AgentAccount.shared.phone
    }

    @objc private func changePhoto() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.pendingPhoto = image
                self?.photoView.image = image
            }
        }
    }

    @IBAction func saveTapped(_ sender: Any) {
        let account = AgentAccount.shared
        if let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            account.name = name
        }
        if let agency = agencyField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !agency.isEmpty {
            account.agency = agency
        }
        if let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
            account.email = email
        }
        if let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty {
            account.phone = phone
        }
        if let pendingPhoto { account.saveProfileImage(pendingPhoto) }
        navigationController?.popViewController(animated: true)
    }
}
