//
//  TenantProfileVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantProfileVC: UIViewController {

    private enum Row {
        case preferences, notifications, savedSearches, enquiries, recentlyViewed
        case language, currency, help, terms, privacy, logout

        var title: String {
            switch self {
            case .preferences: return "My Preferences"
            case .notifications: return "Notifications"
            case .savedSearches: return "Saved Searches"
            case .enquiries: return "Contact / Enquiry History"
            case .recentlyViewed: return "Recently Viewed"
            case .language: return "Language"
            case .currency: return "Currency"
            case .help: return "Help & Support"
            case .terms: return "Terms & Conditions"
            case .privacy: return "Privacy Policy"
            case .logout: return "Logout"
            }
        }

        var icon: String {
            switch self {
            case .preferences: return "slider.horizontal.3"
            case .notifications: return "bell.fill"
            case .savedSearches: return "bookmark.fill"
            case .enquiries: return "envelope.fill"
            case .recentlyViewed: return "clock.fill"
            case .language: return "globe"
            case .currency: return "dollarsign.circle.fill"
            case .help: return "questionmark.circle.fill"
            case .terms: return "doc.text.fill"
            case .privacy: return "lock.fill"
            case .logout: return "rectangle.portrait.and.arrow.right"
            }
        }

        var subtitle: String? {
            switch self {
            case .language: return TenantAccount.shared.language
            case .currency: return TenantAccount.shared.currency
            default: return nil
            }
        }
    }

    private let rows: [Row] = [
        .preferences, .notifications, .savedSearches, .enquiries, .recentlyViewed,
        .language, .currency, .help, .terms, .privacy, .logout
    ]

    private let photoView = UIImageView()
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .screenBackgroundColor
        buildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        showTenantProfile()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoView.layer.cornerRadius = photoView.bounds.width / 2
        photoView.layer.masksToBounds = true
    }

    private func buildLayout() {
        let titleLabel = UILabel()
        titleLabel.text = "Profile"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)

        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = 28
        photoView.setContentHuggingPriority(.required, for: .horizontal)
        photoView.setContentHuggingPriority(.required, for: .vertical)
        photoView.setContentCompressionResistancePriority(.required, for: .horizontal)
        photoView.setContentCompressionResistancePriority(.required, for: .vertical)
        let card = UIControl()
        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        CommonMethods.styleFormCard(card)
        card.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)

        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        addressLabel.font = .systemFont(ofSize: 13, weight: .regular)
        addressLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        addressLabel.numberOfLines = 2
        let text = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        text.axis = .vertical
        text.spacing = 4
        text.isUserInteractionEnabled = false

        let edit = UILabel()
        edit.text = "Edit"
        edit.font = .systemFont(ofSize: 14, weight: .semibold)
        edit.textColor = .darkThemeColor
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(white: 0.7, alpha: 1)
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        photoView.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        edit.translatesAutoresizingMaskIntoConstraints = false
        chevron.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(photoView)
        card.addSubview(text)
        card.addSubview(edit)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            photoView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            photoView.widthAnchor.constraint(equalToConstant: 56),
            photoView.heightAnchor.constraint(equalToConstant: 56),
            card.heightAnchor.constraint(equalToConstant: 88),
            text.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 12),
            text.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            text.trailingAnchor.constraint(equalTo: edit.leadingAnchor, constant: -8),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            edit.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -4),
            edit.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 20)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()

        let topStack = UIStackView(arrangedSubviews: [titleLabel, card])
        topStack.axis = .vertical
        topStack.spacing = 16
        topStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStack)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func showTenantProfile() {
        nameLabel.text = TenantAccount.shared.name
        addressLabel.text = TenantAccount.shared.address
        photoView.image = TenantAccount.shared.profileImage
    }

    @objc private func editProfileTapped() {
        push(TenantEditProfileVC())
    }

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

extension TenantProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.identifier, for: indexPath) as? ProfileMenuCell else {
            return UITableViewCell()
        }
        let row = rows[indexPath.row]
        cell.configure(icon: row.icon, title: row.title, subtitle: row.subtitle, isDestructive: row == .logout)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .preferences: push(TenantPreferencesVC())
        case .notifications: push(TenantNotificationsVC())
        case .savedSearches: push(TenantProfileSearchesVC())
        case .enquiries: push(TenantEnquiryHistoryVC())
        case .recentlyViewed: push(TenantRecentlyViewedVC())
        case .language:
            push(TenantOptionPickerVC(titleText: "Language", options: TenantAccount.languages, selected: TenantAccount.shared.language) { value in
                TenantAccount.shared.language = value
            })
        case .currency:
            push(TenantOptionPickerVC(titleText: "Currency", options: TenantAccount.currencies, selected: TenantAccount.shared.currency) { value in
                TenantAccount.shared.currency = value
            })
        case .help:
            push(TenantTextPageVC(titleText: "Help & Support", body: TenantLegalContent.help))
        case .terms:
            push(TenantTextPageVC(titleText: "Terms & Conditions", body: TenantLegalContent.terms))
        case .privacy:
            push(TenantTextPageVC(titleText: "Privacy Policy", body: TenantLegalContent.privacy))
        case .logout:
            logout()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 54 }
}

final class ProfileMenuCell: UITableViewCell {
    static let identifier = "ProfileMenuCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        iconView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = UIColor(white: 0.72, alpha: 1)
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)
        let text = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        text.axis = .vertical
        text.spacing = 2
        text.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [iconView, text, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 16),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { nil }

    func configure(icon: String, title: String, subtitle: String?, isDestructive: Bool) {
        iconView.image = UIImage(systemName: icon)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        chevron.isHidden = isDestructive
        let color: UIColor = isDestructive ? .darkThemeColor : UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        titleLabel.textColor = color
        iconView.tintColor = isDestructive ? .darkThemeColor : .darkThemeColor
    }
}
