//
//  AgentMarketingVC.swift
//  AIPoweredRealEstate
//

import UIKit

final class AgentMarketingVC: UIViewController {

    var property: PropertyItem?

    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var channelControl: UISegmentedControl!
    @IBOutlet weak var generateButton: CustomButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultCardView: CustomView!

    private var selectedChannel: AgentMarketingChannel = .listing
    private var actionButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Generate content"
        view.backgroundColor = .screenBackgroundColor
        navigationController?.navigationBar.tintColor = .darkThemeColor
        CommonMethods.stylePrimaryButton(generateButton)
        CommonMethods.styleFormCard(resultCardView)
        resultLabel.numberOfLines = 0
        resultLabel.lineBreakMode = .byWordWrapping
        copyButton.layer.cornerRadius = 12
        copyButton.layer.borderWidth = 1
        copyButton.layer.borderColor = UIColor.darkThemeColor.cgColor
        shareButton.layer.cornerRadius = 12
        shareButton.layer.borderWidth = 1
        shareButton.layer.borderColor = UIColor.darkThemeColor.cgColor
        makeContentScrollable()
        installContentActions()
        refreshPickerTitle()
        if property != nil { generate() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: generateButton)
    }

    private func makeContentScrollable() {
        guard let stack = pickerButton.superview, stack.superview === view else { return }
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)
        stack.removeFromSuperview()
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    private func installContentActions() {
        guard let stack = channelControl.superview as? UIStackView else { return }
        channelControl.isHidden = true
        generateButton.setTitle("Regenerate", for: .normal)

        let actions = UIStackView()
        actions.axis = .vertical
        actions.spacing = 8

        let rows: [(String, Int)] = [
            ("Generate marketing description", 0),
            ("Generate Instagram content", 1),
            ("Generate WhatsApp message", 2),
            ("Generate email content", 3),
            ("Create client-facing report", 4)
        ]
        rows.forEach { title, tag in
            let button = UIButton(type: .system)
            button.tag = tag
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            button.setTitle(title, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(contentActionTapped(_:)), for: .touchUpInside)
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
            actions.addArrangedSubview(button)
            actionButtons.append(button)
        }

        if let index = stack.arrangedSubviews.firstIndex(of: channelControl) {
            stack.insertArrangedSubview(actions, at: index)
        }
        refreshActionStyles()
    }

    private func refreshActionStyles() {
        actionButtons.forEach { button in
            let on = button.tag < 4 && button.tag == selectedChannel.index
            button.backgroundColor = on ? UIColor.darkThemeColor.withAlphaComponent(0.12) : .white
            button.layer.borderColor = (on ? UIColor.darkThemeColor : UIColor.cardBorderColor).cgColor
            button.setTitleColor(on ? .darkThemeColor : UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1), for: .normal)
        }
    }

    private func refreshPickerTitle() {
        if let property {
            pickerButton.setTitle("\(property.title) · \(property.source)", for: .normal)
        } else {
            pickerButton.setTitle("Select a property", for: .normal)
        }
    }

    @objc private func contentActionTapped(_ sender: UIButton) {
        if sender.tag == 4 {
            openClientReport()
            return
        }
        selectedChannel = AgentMarketingChannel.allCases[sender.tag]
        channelControl.selectedSegmentIndex = sender.tag
        refreshActionStyles()
        generate()
    }

    private func openClientReport() {
        let listings: [PropertyItem]
        if let property {
            listings = [property]
        } else {
            let compared = AgentStore.shared.comparedProperties()
            listings = compared.isEmpty ? Array(PropertyStore.shared.all.prefix(3)) : compared
        }
        let vc: AgentReportVC = AgentStoryboard.load("AgentReportVC")
        vc.properties = listings
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func pickProperty(_ sender: Any) {
        let sheet = UIAlertController(title: "Property", message: "Choose from inventory", preferredStyle: .actionSheet)
        PropertyStore.shared.all.forEach { item in
            sheet.addAction(UIAlertAction(title: "\(item.title) · \(item.source)", style: .default) { [weak self] _ in
                self?.property = item
                self?.refreshPickerTitle()
                self?.generate()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = pickerButton
            popover.sourceRect = pickerButton.bounds
        }
        present(sheet, animated: true)
    }

    @IBAction func generate() {
        guard let property else {
            resultLabel.text = "Select a property, then generate a listing description, Instagram caption, WhatsApp message, or email."
            return
        }
        selectedChannel = AgentMarketingChannel.allCases[min(channelControl.selectedSegmentIndex, AgentMarketingChannel.allCases.count - 1)]
        refreshActionStyles()
        resultLabel.text = AgentMarketingCopy.text(for: property, channel: selectedChannel)
    }

    @IBAction func copyTapped(_ sender: Any) {
        UIPasteboard.general.string = resultLabel.text
        let alert = UIAlertController(title: "Copied", message: "Paste into Instagram, WhatsApp, email, or a listing portal.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func shareTapped(_ sender: Any) {
        guard let text = resultLabel.text, property != nil else { return }
        switch selectedChannel {
        case .whatsapp:
            let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "whatsapp://send?text=\(encoded)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        case .email:
            let subject = "\(property?.title ?? "Property") in \(property?.location ?? "")"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let body = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string: "mailto:?subject=\(subject)&body=\(body)") {
                UIApplication.shared.open(url)
                return
            }
        default:
            break
        }
        present(UIActivityViewController(activityItems: [text], applicationActivities: nil), animated: true)
    }
}

private extension AgentMarketingChannel {
    var index: Int { AgentMarketingChannel.allCases.firstIndex(of: self) ?? 0 }
}
