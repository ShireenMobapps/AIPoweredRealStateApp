//
//  AIChatCell.swift
//  AIPoweredRealEstate
//

import UIKit

enum AIChatSender {
    case user
    case assistant
}

struct AIChatMessage {
    let sender: AIChatSender
    let text: String
    let isParameters: Bool
}

final class AIChatCell: UITableViewCell {

    static let identifier = "AIChatCell"

    private let bubbleLabel = UILabel()
    private let bubbleView = UIView()
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(_ message: AIChatMessage) {
        bubbleLabel.text = message.text
        let isUser = message.sender == .user
        bubbleView.backgroundColor = isUser ? .darkThemeColor : .white
        bubbleLabel.textColor = isUser ? .white : UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        bubbleView.layer.borderWidth = isUser ? 0 : 1
        bubbleView.layer.borderColor = UIColor.cardBorderColor.cgColor
        leadingConstraint?.constant = isUser ? 72 : 16
        trailingConstraint?.constant = isUser ? -16 : -72
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16

        bubbleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bubbleLabel.numberOfLines = 0

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(bubbleLabel)

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            leadingConstraint!,
            trailingConstraint!,

            bubbleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            bubbleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            bubbleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            bubbleLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
    }
}
