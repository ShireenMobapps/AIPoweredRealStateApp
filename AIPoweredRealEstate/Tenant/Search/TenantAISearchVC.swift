//
//  TenantAISearchVC.swift
//  AIPoweredRealEstate
//

import UIKit

class TenantAISearchVC: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputCardView: CustomView!
    @IBOutlet weak var messageTextField: CustomTextField!
    @IBOutlet weak var sendButton: CustomButton!
    @IBOutlet weak var recommendationsCollection: UICollectionView!
    @IBOutlet weak var recommendationsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var recommendationsTitleLabel: UILabel!

    var initialQuery: String?

    private var messages: [AIChatMessage] = [
        AIChatMessage(
            sender: .assistant,
            text: "Tell me what you're looking for... a villa near the beach, a 2-bed apartment in Santo Domingo, or anything in between.",
            isParameters: false
        )
    ]
    private var matches: [PropertyItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        setupChat()
        setupRecommendations()
        sendInitialQueryIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        recommendationsCollection.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CommonMethods.updateGradientFrame(for: sendButton)
        recommendationsCollection.collectionViewLayout.invalidateLayout()
    }

    private func applyStyle() {
        view.backgroundColor = .screenBackgroundColor
        CommonMethods.styleFormCard(inputCardView)
        CommonMethods.styleTextField(messageTextField)
        CommonMethods.stylePrimaryButton(sendButton)
        recommendationsHeightConstraint.constant = 0
        recommendationsCollection.isHidden = true
    }

    private func setupChat() {
        tableView.register(AIChatCell.self, forCellReuseIdentifier: AIChatCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        messageTextField.delegate = self
        messageTextField.returnKeyType = .send
    }

    private func setupRecommendations() {
        recommendationsCollection.register(PropertyCardCell.nib, forCellWithReuseIdentifier: PropertyCardCell.identifier)
        recommendationsCollection.dataSource = self
        recommendationsCollection.delegate = self
        recommendationsCollection.showsHorizontalScrollIndicator = false
        recommendationsCollection.backgroundColor = .clear
        recommendationsCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if let layout = recommendationsCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func sendTapped(_ sender: UIButton) {
        let query = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else { return }
        messageTextField.text = nil
        append(AIChatMessage(sender: .user, text: query, isParameters: false))
        runAIFlow(for: query)
    }

    private func sendInitialQueryIfNeeded() {
        let query = initialQuery?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else { return }
        initialQuery = nil
        append(AIChatMessage(sender: .user, text: query, isParameters: false))
        runAIFlow(for: query)
    }

    private func runAIFlow(for query: String) {
        if isAgentFlow {
            AgentStore.shared.rememberSearch(query)
        }
        sendButton.isEnabled = false
        append(AIChatMessage(sender: .assistant, text: "Understanding your requirements...", isParameters: false))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            let parameters = self.parameters(from: query)
            self.append(AIChatMessage(sender: .assistant, text: "Search Parameters\n\(parameters)", isParameters: true))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
            guard let self else { return }
            self.matches = PropertyStore.shared.topMatches(for: query)
            self.append(AIChatMessage(
                sender: .assistant,
                text: "Here are the top 3 recommendations based on what you described.",
                isParameters: false
            ))
            self.recommendationsCollection.isHidden = false
            self.recommendationsHeightConstraint.constant = 268
            self.recommendationsCollection.reloadData()
            self.sendButton.isEnabled = true
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func parameters(from query: String) -> String {
        let text = query.lowercased()
        var parts: [String] = []
        if text.contains("rent") { parts.append("Rent") }
        if text.contains("buy") || text.contains("purchase") { parts.append("Buy") }
        if text.contains("villa") { parts.append("Villa") }
        if text.contains("apartment") || text.contains("condo") { parts.append("Apartment") }
        if text.contains("house") { parts.append("House") }
        if text.contains("beach") { parts.append("Near Beach") }
        if let beds = [1, 2, 3, 4, 5].first(where: { text.contains("\($0)") }) {
            parts.append("\(beds) Bedrooms")
        }
        ["punta cana", "santo domingo", "santiago", "puerto plata", "cap cana"].forEach { city in
            if text.contains(city) {
                parts.append(city.capitalized)
            }
        }
        if parts.isEmpty {
            parts = ["Any listing type", "Any property type", "Dominican Republic"]
        }
        return parts.map { "• \($0)" }.joined(separator: "\n")
    }

    private func append(_ message: AIChatMessage) {
        messages.append(message)
        tableView.reloadData()
        let last = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: last, at: .bottom, animated: true)
    }
}

extension TenantAISearchVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AIChatCell.identifier, for: indexPath) as? AIChatCell else {
            return UITableViewCell()
        }
        cell.configure(messages[indexPath.row])
        return cell
    }
}

extension TenantAISearchVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        matches.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PropertyCardCell.identifier,
            for: indexPath
        ) as? PropertyCardCell else {
            return UICollectionViewCell()
        }
        let property = matches[indexPath.item]
        let saved = isAgentFlow ? AgentStore.shared.isFavorite(property.id) : PropertyStore.shared.isFavorite(property.id)
        cell.configure(with: property, isFavorite: saved, showsSource: isAgentFlow)
        cell.onFavorite = { [weak self] in
            guard let self else { return }
            if self.isAgentFlow {
                AgentStore.shared.toggleFavorite(property.id)
            } else {
                PropertyStore.shared.toggleFavorite(property.id)
            }
            self.recommendationsCollection.reloadData()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openPropertyDetails(matches[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 236, height: collectionView.bounds.height)
    }
}

extension TenantAISearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}
