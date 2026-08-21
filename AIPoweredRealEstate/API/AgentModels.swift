//
//  AgentModels.swift
//  AIPoweredRealEstate
//

import UIKit

enum AgentLeadStatus: String, CaseIterable {
    case new = "New"
    case contacted = "Contacted"
    case viewing = "Viewing"
    case closed = "Closed"
}

enum AgentMarketingChannel: String, CaseIterable {
    case listing = "Listing"
    case instagram = "Instagram"
    case whatsapp = "WhatsApp"
    case email = "Email"
}

struct AgentClientSearch {
    let id: String
    var client: String
    var query: String
    let date: Date
}

struct AgentLead {
    let id: String
    let propertyId: String
    let propertyTitle: String
    let clientName: String
    let email: String
    let phone: String
    let message: String
    let date: Date
    var status: AgentLeadStatus
}

struct AgentNotificationItem {
    let id: String
    let title: String
    let body: String
    let icon: String
    let date: Date
    var isRead: Bool
}

enum AgentMarketingCopy {
    static func text(for property: PropertyItem, channel: AgentMarketingChannel) -> String {
        let amenities = property.amenities.prefix(4).joined(separator: ", ")
        let furnished = property.isFurnished ? "Furnished" : "Unfurnished"
        let cityTag = property.location.replacingOccurrences(of: " ", with: "")
        switch channel {
        case .listing:
            return """
            MARKETING DESCRIPTION
            \(property.title) | \(property.location) | \(property.source)

            Price: \(property.priceText)  ·  \(property.listingType)
            \(property.detailSpecsText)
            \(furnished)  ·  \(amenities)
            \(property.costPerSquareMeterText)

            \(property.summary)

            Ideal for clients looking for a \(property.propertyType.lowercased()) in \(property.location). Ready for portal upload (SuperCasas, Corotos, Encuentra24).

            Listed by \(AgentAccount.shared.name), \(AgentAccount.shared.agency)
            \(AgentAccount.shared.phone)
            """
        case .instagram:
            return """
            ✨ Just listed in \(property.location)

            \(property.title)
            \(property.priceText)
            \(property.bedrooms) BR · \(property.bathrooms) BA · \(property.area)
            \(furnished) · \(amenities)

            \(property.summary)

            Private tours this week — DM to book.
            —
            \(AgentAccount.shared.name) | \(AgentAccount.shared.agency)

            #\(cityTag) #DominicanRepublic #RealEstate #\(property.propertyType) #JustListed #CaribbeanHomes
            """
        case .whatsapp:
            return """
            Hi, I found a listing that may match what you asked for:

            *\(property.title)*
            \(property.location)
            \(property.priceText) · \(property.listingType)
            \(property.bedrooms) beds · \(property.bathrooms) baths · \(property.area)
            \(furnished)
            Source: \(property.source)

            \(property.summary)

            I can arrange a viewing this week. Shall I send a short client report as well?

            \(AgentAccount.shared.name)
            \(AgentAccount.shared.agency)
            \(AgentAccount.shared.phone)
            """
        case .email:
            return """
            Hello,

            Sharing a listing from our cross-inventory search that may fit your brief.

            Property: \(property.title)
            Location: \(property.location)
            Price: \(property.priceText) (\(property.listingType))
            Details: \(property.detailSpecsText)
            Condition: \(furnished)
            Amenities: \(property.amenities.joined(separator: ", "))
            Portal: \(property.source)

            \(property.summary)

            I can follow up with a client-facing comparison report or schedule a showing at your convenience.

            Kind regards,
            \(AgentAccount.shared.name)
            \(AgentAccount.shared.agency)
            \(AgentAccount.shared.email)
            \(AgentAccount.shared.phone)
            """
        }
    }

    static func clientReport(for properties: [PropertyItem], client: String) -> String {
        let agent = AgentAccount.shared
        let rows = properties.enumerated().map { index, property in
            """
            \(index + 1). \(property.title)
               \(property.location) · \(property.source)
               \(property.priceText) · \(property.costPerSquareMeterText)
               \(property.detailSpecsText)
               \(property.summary)
            """
        }.joined(separator: "\n\n")
        let summary = PropertyStore.shared.comparisonSummary(for: properties)
        return """
        Client property report
        Prepared for: \(client)
        By: \(agent.name), \(agent.agency)

        \(rows)

        Recommendation
        \(summary)

        Contact: \(agent.email) · \(agent.phone)
        """
    }
}

final class AgentAccount {
    static let shared = AgentAccount()

    private let defaults = UserDefaults.standard

    var name: String { didSet { defaults.set(name, forKey: "agentName") } }
    var agency: String { didSet { defaults.set(agency, forKey: "agentAgency") } }
    var email: String { didSet { defaults.set(email, forKey: "agentEmail") } }
    var phone: String { didSet { defaults.set(phone, forKey: "agentPhone") } }
    var imageName: String { "tenantProfile" }

    var profileImage: UIImage {
        if let data = try? Data(contentsOf: Self.profileImageURL), let image = UIImage(data: data) {
            return image
        }
        return UIImage(named: imageName) ?? UIImage()
    }

    func saveProfileImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: Self.profileImageURL, options: .atomic)
    }

    private static var profileImageURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("agentProfile.jpg")
    }

    private init() {
        name = defaults.string(forKey: "agentName") ?? "Maria Santos"
        agency = defaults.string(forKey: "agentAgency") ?? "Caribbean Homes"
        email = defaults.string(forKey: "agentEmail") ?? "maria.santos@caribbeanhomes.com"
        phone = defaults.string(forKey: "agentPhone") ?? "+1 809 555 0188"
    }
    
}

final class AgentStore {
    
    static let shared = AgentStore()
   
    static var pendingSavedSection: Int?

    private let defaults = UserDefaults.standard

    private(set) var favoriteIDs: Set<String>
    private(set) var compareIDs: [String]
    private(set) var recentSearches: [String]
    private(set) var clientSearches: [AgentClientSearch]
    private(set) var leads: [AgentLead]
    private(set) var notifications: [AgentNotificationItem]

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    
    var openLeadCount: Int { leads.filter { $0.status != .closed }.count }

    private init() {
        
        favoriteIDs = Set(defaults.stringArray(forKey: "agentFavoriteIDs") ?? [])
       
        compareIDs = defaults.stringArray(forKey: "agentCompareIDs") ?? []
        
        recentSearches = defaults.stringArray(forKey: "agentRecentSearches") ?? [
            "Beach villa in Punta Cana",
            "2-bed apartment Santo Domingo under $1,500",
            "Furnished condo Puerto Plata"
        ]
        
        clientSearches = [
            
            AgentClientSearch(id: "c1", client: "Luis Perez", query: "2-bed apartment in Santo Domingo", date: Date().addingTimeInterval(-86_400)),
            
            AgentClientSearch(id: "c2", client: "Ana Rodriguez", query: "Family house with garden in Santiago", date: Date().addingTimeInterval(-172_800)),
            
            AgentClientSearch(id: "c3", client: "Diego Alvarez", query: "Beachfront condo for rent", date: Date().addingTimeInterval(-259_200))
        ]
        
        leads = PropertyStore.shared.enquiries.map { enquiry in
            AgentLead(
                id: enquiry.id,
                propertyId: enquiry.propertyId,
                propertyTitle: enquiry.propertyTitle,
                clientName: enquiry.contactName,
                email: enquiry.email,
                phone: enquiry.phone,
                message: enquiry.message,
                date: enquiry.date,
                status: .new
            )
        }
        
        notifications = [
            
            AgentNotificationItem(id: "n1", title: "New matching property", body: "A new villa in Cap Cana matches a saved client search.", icon: "house.fill", date: Date().addingTimeInterval(-2_000), isRead: false),
           
            AgentNotificationItem(id: "n2", title: "Saved property update", body: "Oceanview Villa price was updated to $485,000.", icon: "heart.fill", date: Date().addingTimeInterval(-8_000), isRead: false),
            
            AgentNotificationItem(id: "n3", title: "New lead", body: "Alex Rivera requested a viewing for Oceanview Villa.", icon: "person.badge.plus", date: Date().addingTimeInterval(-20_000), isRead: false),
            
            AgentNotificationItem(id: "n4", title: "Client enquiry", body: "Luis Perez asked about Modern City Apartment.", icon: "envelope.fill", date: Date().addingTimeInterval(-50_000), isRead: true),
            
            AgentNotificationItem(id: "n5", title: "System notification", body: "Inventory sync from SuperCasas and Corotos completed.", icon: "gearshape.fill", date: Date().addingTimeInterval(-90_000), isRead: true)
        ]
    }

    func isFavorite(_ id: String) -> Bool { favoriteIDs.contains(id) }

    func toggleFavorite(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        defaults.set(Array(favoriteIDs), forKey: "agentFavoriteIDs")
    }

    func favoriteProperties() -> [PropertyItem] {
        PropertyStore.shared.all.filter { favoriteIDs.contains($0.id) }
    }

    func isCompared(_ id: String) -> Bool { compareIDs.contains(id) }

    @discardableResult
    func toggleCompare(_ id: String) -> String {
        if let index = compareIDs.firstIndex(of: id) {
            compareIDs.remove(at: index)
            persistCompare()
            return "Removed from compare."
        }
        guard compareIDs.count < 3 else {
            return "You can compare up to 3 properties."
        }
        compareIDs.append(id)
        persistCompare()
        return "Added to compare (\(compareIDs.count)/3)."
    }

    func comparedProperties() -> [PropertyItem] {
        compareIDs.compactMap { id in PropertyStore.shared.all.first { $0.id == id } }
    }

    func compareCandidates() -> [PropertyItem] {
        let compared = comparedProperties()
        let remaining = PropertyStore.shared.all.filter { !compareIDs.contains($0.id) }
        let favorites = remaining.filter { favoriteIDs.contains($0.id) }
        let others = remaining.filter { !favoriteIDs.contains($0.id) }
        return compared + favorites + others
    }

    func rememberSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        if recentSearches.count > 8 { recentSearches = Array(recentSearches.prefix(8)) }
        defaults.set(recentSearches, forKey: "agentRecentSearches")
    }

    func addClientSearch(client: String, query: String) {
        clientSearches.insert(
            AgentClientSearch(id: UUID().uuidString, client: client, query: query, date: Date()),
            at: 0
        )
        rememberSearch(query)
    }

    func deleteClientSearch(id: String) {
        clientSearches.removeAll { $0.id == id }
    }

    func recordLead(from enquiry: EnquiryItem) {
        if leads.contains(where: { $0.id == enquiry.id }) { return }
        let lead = AgentLead(
            id: enquiry.id,
            propertyId: enquiry.propertyId,
            propertyTitle: enquiry.propertyTitle,
            clientName: enquiry.contactName,
            email: enquiry.email,
            phone: enquiry.phone,
            message: enquiry.message,
            date: enquiry.date,
            status: .new
        )
        leads.insert(lead, at: 0)
        notifications.insert(
            AgentNotificationItem(
                id: UUID().uuidString,
                title: "New lead",
                body: "\(enquiry.contactName) enquired about \(enquiry.propertyTitle).",
                icon: "person.badge.plus",
                date: Date(),
                isRead: false
            ),
            at: 0
        )
    }

    func setLeadStatus(id: String, status: AgentLeadStatus) {
        guard let index = leads.firstIndex(where: { $0.id == id }) else { return }
        leads[index].status = status
    }

    func markAllRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    private func persistCompare() {
        defaults.set(compareIDs, forKey: "agentCompareIDs")
    }
}
