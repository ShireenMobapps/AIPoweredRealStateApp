//
//  CommonMethods.swift
//  AIPoweredRealEstate
//
//  Created by Shireen on 18/08/26.
//

import Foundation
import UIKit

extension UIColor {

    static var darkThemeColor: UIColor {
        UIColor(red: 141/255, green: 25/255, blue: 25/255, alpha: 1)
    }

    static var mediumThemeColor: UIColor {
        UIColor(red: 213/255, green: 67/255, blue: 66/255, alpha: 1)
    }

    static var lightThemeColor: UIColor {
        UIColor(red: 236/255, green: 92/255, blue: 91/255, alpha: 1)
    }

    static var screenBackgroundColor: UIColor {
        UIColor(red: 252/255, green: 248/255, blue: 247/255, alpha: 1)
    }

    static var cardBorderColor: UIColor {
        UIColor(red: 236/255, green: 228/255, blue: 227/255, alpha: 1)
    }
}

final class CommonMethods {

    private static let themeGradientLayerName = "themeGradient"

    class func gradientOverView(view: UIView) {
        view.layer.sublayers?
            .filter { $0.name == themeGradientLayerName }
            .forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = themeGradientLayerName
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.darkThemeColor.cgColor,
            UIColor.mediumThemeColor.cgColor,
            UIColor.lightThemeColor.cgColor
        ]
        gradientLayer.locations = [0.0, 0.55, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.05, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    class func applyHeaderGradient(on view: UIView, cornerRadius: CGFloat = 32) {
        gradientOverView(view: view)
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
    }

    class func applyButtonGradient(on button: UIButton, cornerRadius: CGFloat = 14) {
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = cornerRadius
        gradientOverView(view: button)
        updateGradientFrame(for: button)
        if let titleLabel = button.titleLabel {
            button.bringSubviewToFront(titleLabel)
        }
        if let imageView = button.imageView {
            button.bringSubviewToFront(imageView)
        }
    }

    class func updateGradientFrame(for view: UIView) {
        guard let gradientLayer = view.layer.sublayers?
            .first(where: { $0.name == themeGradientLayerName }) as? CAGradientLayer else {
            return
        }
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = view.layer.cornerRadius
        gradientLayer.maskedCorners = view.layer.maskedCorners
    }

    class func styleLogoContainer(_ view: UIView) {
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    class func styleFormCard(_ view: UIView) {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.darkThemeColor.cgColor
        view.layer.shadowOpacity = 0.10
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
    }

    class func styleTextField(_ field: CustomTextField) {
        field.backgroundColor = .screenBackgroundColor
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.cardBorderColor.cgColor
        field.font = .systemFont(ofSize: 16, weight: .regular)
    }

    class func stylePrimaryButton(_ button: UIButton) {
        CommonMethods.applyButtonGradient(on: button, cornerRadius: 14)
    }

    class func styleFilterChip(_ button: UIButton, title: String? = nil, selected: Bool, compact: Bool = false) {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        let inset: CGFloat = compact ? 6 : 14
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: inset, bottom: 8, trailing: inset)
        config.title = title ?? button.configuration?.title ?? button.title(for: .normal)
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: compact ? 12 : 13, weight: .semibold)
            return outgoing
        }
        if selected {
            config.baseBackgroundColor = .darkThemeColor
            config.baseForegroundColor = .white
            config.background.strokeWidth = 0
        } else {
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .darkThemeColor
            config.background.strokeColor = UIColor.darkThemeColor.withAlphaComponent(0.25)
            config.background.strokeWidth = 1
        }
        button.configuration = config
    }

    class func makeFilterChip(title: String, selected: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        styleFilterChip(button, title: title, selected: selected)
        return button
    }

    class func setRootViewController(_ viewController: UIViewController) {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .first

        guard let window else { return }
        UIView.transition(with: window, duration: 0.28, options: .transitionCrossDissolve) {
            window.rootViewController = viewController
        }
    }
}


/*
 TAB 2 — SEARCH

 Ye agent ke liye sabse important module hai.

 SEARCH
   ↓
 Search Type
   ├── AI Search
   └── Traditional Filters
 AI Search

 Agent normal language me search karega:

 "Find me 2 bedroom furnished apartments in Piantini under $1,500."

 Agent Query
      ↓
 AI understands request
      ↓
 Extract parameters
      ↓
 Location
 Budget
 Bedrooms
 Property Type
 Furnished
 Amenities
      ↓
 Search Properties
      ↓
 Results
 AI Follow-up

 Agar information incomplete hai:

 AI:
 "What is your maximum budget?"


 Agent:
 "$2,000"


 AI:
 "Do you prefer furnished?"


 Agent:
 "Yes"

 Then:

 AI Search
    ↓
 Top 3 Properties

 Each property:

 Property Card
  ├── Image
  ├── Price
  ├── Location
  ├── Bedrooms
  ├── Bathrooms
  ├── Area
  ├── Match %
  ├── Why this property?
  ├── ❤️ Save
  └── Compare
 Traditional Search / Filters

 Agent manually bhi search kar sake:

 Search
  │
  ├── Location
  ├── Buy / Rent
  ├── Property Type
  ├── Price Range
  ├── Bedrooms
  ├── Bathrooms
  ├── Property Size
  ├── Furnished
  ├── Amenities
  └── Apply Filters

 Results:

 Property Listing
       ↓
 Property Details
 PROPERTY DETAILS

 Agent ke liye details screen:

 Property Details
  │
  ├── Image Gallery
  ├── Property Title
  ├── Price
  ├── Location
  ├── Property Type
  ├── Bedrooms
  ├── Bathrooms
  ├── Area
  ├── Amenities
  ├── Description
  ├── Source / Portal
  ├── Agent Information
  │
  ├── ❤️ Save
  ├── Compare
  ├── Contact Agent
  │
  └── AI Tools
        ├── Instagram
        ├── WhatsApp
        ├── Email
        └── Marketing Description
 
 
 
 
 TAB 3 — SAVED

 Agent ke saved properties:

 SAVED
  │
  ├── Saved Properties
  │
  ├── Saved Searches
  │
  └── Client Searches
 Saved Properties
 Property Card
  ├── Image
  ├── Price
  ├── Location
  ├── Details
  ├── Remove
  └── Compare
 Saved Searches

 Agent apni frequently used search save kar sakta hai:

 "2BR Apartments in Piantini"
 "Luxury Villas under $500K"

 Search ko open karke latest properties dekh sakta hai.

 PROPERTY COMPARISON

 Ye Saved ya Search dono se open ho sakta hai.

 Select 2–3 Properties
         ↓
 Compare
         ↓
 ┌─────────────────────────────┐
 │ Property A │ Property B │ C │
 ├─────────────────────────────┤
 │ Price       │ Price      │   │
 │ Location    │ Location   │   │
 │ Bedrooms    │ Bedrooms   │   │
 │ Bathrooms   │ Bathrooms  │   │
 │ Area        │ Area       │   │
 │ $/m²        │ $/m²       │   │
 │ Amenities   │ Amenities  │   │
 │ Social Area │ Social Area│   │
 └─────────────────────────────┘

 Then:

 AI Comparison
       ↓
 "Property A is better for..."
 "Property B is better for..."
 AI MARKETING CONTENT

 Agent kisi property ko select kare:

 Property
    ↓
 Generate Content
    ↓
 Choose Platform
 ┌─────────────────────────┐
 │ Instagram               │
 │ WhatsApp                │
 │ Email                   │
 │ Marketing Description   │
 └─────────────────────────┘

 Example flow:

 Property Details
       ↓
 Generate Instagram Content
       ↓
 AI generates content
       ↓
 Preview
       ↓
 Copy / Share

 Same flow for:

 WhatsApp
 Email
 Property Description
 CLIENT / LEAD FLOW

 Agent ko client enquiries bhi milengi.

 Property
    ↓
 Contact / Enquiry
    ↓
 Lead Created
    ↓
 Agent Notification
    ↓
 Lead Details

 Lead screen:

 Lead Details
  ├── Client Name
  ├── Contact
  ├── Requirement
  ├── Interested Property
  ├── Date
  ├── Status
  │    ├── New
  │    ├── Contacted
  │    ├── Interested
  │    └── Closed
  └── Contact History
 
 TAB 4 — PROFILE
 PROFILE
  │
  ├── Profile Image
  ├── Agent Name
  ├── Email
  ├── Phone
  ├── Agency
  ├── License / Verification
  │
  ├── Edit Profile
  │
  ├── My Leads
  │
  ├── My Searches
  │
  ├── AI Usage
  │
  ├── Notification Settings
  │
  ├── Security
  │
  ├── Change Password
  │
  ├── Terms & Conditions
  │
  ├── Privacy Policy
  │
  └── Logout
 Complete Agent Flow

 Cursor ko dene ke liye overall flow:

                     SPLASH
                        ↓
                  LOGIN / SIGNUP
                        ↓
                 SELECT ROLE
                        ↓
                     AGENT
                        ↓
               ACCOUNT VERIFICATION
                        ↓
                   AGENT HOME
                        ↓
        ┌───────────────┼────────────────┐
        ↓               ↓                ↓
      HOME            SEARCH           SAVED
        │               │                │
        │               ├── AI Search    ├── Properties
        │               │                ├── Searches
        │               ├── Filters      └── Compare
        │               │
        │               └── Results
        │                    ↓
        │              Property Details
        │                    │
        │          ┌─────────┼──────────┐
        │          ↓         ↓          ↓
        │        Save      Compare    AI Content
        │                               │
        │                    ┌──────────┼─────────┐
        │                    ↓          ↓         ↓
        │                Instagram   WhatsApp   Email
        │
        └── Notifications
                │
                ├── New Property
                ├── Lead
                └── Enquiry


                        ↓
                     PROFILE
                        │
               ┌────────┼─────────┐
               ↓        ↓         ↓
            Account   Leads    Settings
 Agent ka core experience

 Home → AI Search → Property Results → Property Details → Save/Compare → Generate Marketing Content → Lead/Client Enquiry

 Ye agent ko document ke according high-speed real estate sales copilot ke role me cover karta hai.
 */
