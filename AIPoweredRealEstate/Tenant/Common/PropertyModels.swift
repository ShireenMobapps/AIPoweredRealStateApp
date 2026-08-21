//
//  PropertyModels.swift
//  AIPoweredRealEstate
//

import UIKit

enum PropertySort: String, CaseIterable {
    case recommended = "Recommended"
    case priceLowToHigh = "Price Low → High"
    case priceHighToLow = "Price High → Low"
    case newest = "Newest"
}

struct PropertySearchCriteria {
    var keyword: String = ""
    var listingType: String?
    var location: String?
    var propertyType: String?
    var minPrice: Int?
    var maxPrice: Int?
    var minBedrooms: Int?
    var minBathrooms: Int?
    var minArea: Int?
    var maxArea: Int?
    var furnished: Bool?
    var amenities: Set<String> = []
    var source: String?
    var sort: PropertySort = .recommended

    var activeFilterCount: Int {
        var count = 0
        if location != nil { count += 1 }
        if propertyType != nil { count += 1 }
        if source != nil { count += 1 }
        if minPrice != nil || maxPrice != nil { count += 1 }
        if minBedrooms != nil { count += 1 }
        if minBathrooms != nil { count += 1 }
        if minArea != nil || maxArea != nil { count += 1 }
        if furnished != nil { count += 1 }
        if !amenities.isEmpty { count += 1 }
        return count
    }

    mutating func resetFilters() {
        location = nil
        propertyType = nil
        minPrice = nil
        maxPrice = nil
        minBedrooms = nil
        minBathrooms = nil
        minArea = nil
        maxArea = nil
        furnished = nil
        amenities = []
        source = nil
    }
}

final class TenantAccount {
    static let shared = TenantAccount()

    private let defaults = UserDefaults.standard

    var name: String { didSet { defaults.set(name, forKey: "tenantName") } }
    var email: String { didSet { defaults.set(email, forKey: "tenantEmail") } }
    var phone: String { didSet { defaults.set(phone, forKey: "tenantPhone") } }
    var address: String { didSet { defaults.set(address, forKey: "tenantAddress") } }
    var language: String { didSet { defaults.set(language, forKey: "tenantLanguage") } }
    var currency: String { didSet { defaults.set(currency, forKey: "tenantCurrency") } }
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
            .appendingPathComponent("tenantProfile.jpg")
    }

    var notifyMatching: Bool { didSet { defaults.set(notifyMatching, forKey: "notifyMatching") } }
    var notifySavedUpdates: Bool { didSet { defaults.set(notifySavedUpdates, forKey: "notifySavedUpdates") } }
    var notifySearchAlerts: Bool { didSet { defaults.set(notifySearchAlerts, forKey: "notifySearchAlerts") } }
    var notifyEnquiries: Bool { didSet { defaults.set(notifyEnquiries, forKey: "notifyEnquiries") } }

    var preferredTypes: Set<String> {
        didSet { defaults.set(Array(preferredTypes), forKey: "prefTypes") }
    }
    var preferredLocations: Set<String> {
        didSet { defaults.set(Array(preferredLocations), forKey: "prefLocations") }
    }
    var budgetMax: Int? {
        didSet { defaults.set(budgetMax, forKey: "prefBudget") }
    }
    var minBedrooms: Int? {
        didSet { defaults.set(minBedrooms, forKey: "prefBeds") }
    }
    var preferredAmenities: Set<String> {
        didSet { defaults.set(Array(preferredAmenities), forKey: "prefAmenities") }
    }

    static let languages = ["English", "Español"]
    static let currencies = ["USD", "DOP", "EUR"]

    private init() {
        name = defaults.string(forKey: "tenantName") ?? "Alex Rivera"
        email = defaults.string(forKey: "tenantEmail") ?? "alex.rivera@email.com"
        phone = defaults.string(forKey: "tenantPhone") ?? "+1 809 555 0142"
        address = defaults.string(forKey: "tenantAddress") ?? "Punta Cana, Dominican Republic"
        language = defaults.string(forKey: "tenantLanguage") ?? "English"
        currency = defaults.string(forKey: "tenantCurrency") ?? "USD"
        notifyMatching = defaults.object(forKey: "notifyMatching") as? Bool ?? true
        notifySavedUpdates = defaults.object(forKey: "notifySavedUpdates") as? Bool ?? true
        notifySearchAlerts = defaults.object(forKey: "notifySearchAlerts") as? Bool ?? true
        notifyEnquiries = defaults.object(forKey: "notifyEnquiries") as? Bool ?? true
        preferredTypes = Set(defaults.stringArray(forKey: "prefTypes") ?? ["Villa"])
        preferredLocations = Set(defaults.stringArray(forKey: "prefLocations") ?? ["Punta Cana"])
        let storedBudget = defaults.object(forKey: "prefBudget") as? Int
        budgetMax = storedBudget == 0 ? nil : (storedBudget ?? 500_000)
        let storedBeds = defaults.object(forKey: "prefBeds") as? Int
        minBedrooms = storedBeds == 0 ? nil : (storedBeds ?? 3)
        preferredAmenities = Set(defaults.stringArray(forKey: "prefAmenities") ?? ["Pool"])
    }
}

struct EnquiryItem {
    let id: String
    let propertyId: String
    let propertyTitle: String
    let agentName: String
    let message: String
    let contactName: String
    let email: String
    let phone: String
    let date: Date
}

struct PropertyItem {
    let id: String
    let title: String
    let location: String
    let priceText: String
    let priceValue: Int
    let listingType: String
    let propertyType: String
    let bedrooms: Int
    let bathrooms: Int
    let area: String
    let areaValue: Int
    let summary: String
    let amenities: [String]
    let isFurnished: Bool
    let source: String
    let listedDate: Date
    let galleryIcons: [String]
    let agentName: String
    let agentAgency: String
    let iconName: String
    let imageName: String

    var specsText: String {
        "\(bedrooms) bd  ·  \(bathrooms) ba  ·  \(area)"
    }

    var detailSpecsText: String {
        "\(propertyType)  ·  \(bedrooms) Bedrooms  ·  \(bathrooms) Bathrooms  ·  \(area)"
    }

    var costPerSquareMeter: Int {
        areaValue > 0 ? priceValue / areaValue : 0
    }

    var costPerSquareMeterText: String {
        "$\(costPerSquareMeter)/m²"
    }

    func hasAmenity(_ name: String) -> Bool {
        amenities.contains { $0.caseInsensitiveCompare(name) == .orderedSame }
    }

    func matches(filter: String) -> Bool {
        switch filter.lowercased() {
        case "buy", "rent":
            return listingType.lowercased() == filter.lowercased()
        default:
            return propertyType.lowercased() == filter.lowercased()
        }
    }

    func matches(_ criteria: PropertySearchCriteria) -> Bool {
        if let listingType = criteria.listingType, listingType.lowercased() != self.listingType.lowercased() {
            return false
        }
        if let location = criteria.location, location.lowercased() != self.location.lowercased() {
            return false
        }
        if let propertyType = criteria.propertyType, propertyType.lowercased() != self.propertyType.lowercased() {
            return false
        }
        if let source = criteria.source, source.lowercased() != self.source.lowercased() {
            return false
        }
        if let minPrice = criteria.minPrice, priceValue < minPrice {
            return false
        }
        if let maxPrice = criteria.maxPrice, priceValue > maxPrice {
            return false
        }
        if let minBedrooms = criteria.minBedrooms, bedrooms < minBedrooms {
            return false
        }
        if let minBathrooms = criteria.minBathrooms, bathrooms < minBathrooms {
            return false
        }
        if let minArea = criteria.minArea, areaValue < minArea {
            return false
        }
        if let maxArea = criteria.maxArea, areaValue > maxArea {
            return false
        }
        if let furnished = criteria.furnished, isFurnished != furnished {
            return false
        }
        if !criteria.amenities.isEmpty {
            let available = Set(amenities.map { $0.lowercased() })
            for amenity in criteria.amenities where !available.contains(amenity.lowercased()) {
                return false
            }
        }

        let keyword = criteria.keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !keyword.isEmpty else { return true }
        return title.lowercased().contains(keyword)
            || location.lowercased().contains(keyword)
            || propertyType.lowercased().contains(keyword)
            || listingType.lowercased().contains(keyword)
            || summary.lowercased().contains(keyword)
            || amenities.joined(separator: " ").lowercased().contains(keyword)
            || source.lowercased().contains(keyword)
    }

    static let samples: [PropertyItem] = [
        PropertyItem(
            id: "p1",
            title: "Oceanview Villa",
            location: "Punta Cana",
            priceText: "$485,000",
            priceValue: 485_000,
            listingType: "Buy",
            propertyType: "Villa",
            bedrooms: 4,
            bathrooms: 3,
            area: "320 m²",
            areaValue: 320,
            summary: "A bright beachside villa with an open living area, private pool, and walking distance to the sand.",
            amenities: ["Pool", "Parking", "Furnished", "Garden", "A/C"],
            isFurnished: true,
            source: "Encuentra24",
            listedDate: Date().addingTimeInterval(-3 * 86_400),
            galleryIcons: ["house.lodge.fill", "water.waves", "sun.max.fill"],
            agentName: "Maria Santos",
            agentAgency: "Caribbean Homes",
            iconName: "house.lodge.fill",
            imageName: "propertyOceanVilla"
        ),
        PropertyItem(
            id: "p2",
            title: "Modern City Apartment",
            location: "Santo Domingo",
            priceText: "$1,200/mo",
            priceValue: 1_200,
            listingType: "Rent",
            propertyType: "Apartment",
            bedrooms: 2,
            bathrooms: 2,
            area: "95 m²",
            areaValue: 95,
            summary: "A contemporary apartment in the city center, close to cafes, coworking, and public transport.",
            amenities: ["Elevator", "Security", "Furnished", "A/C"],
            isFurnished: true,
            source: "SuperCasas",
            listedDate: Date().addingTimeInterval(-8 * 86_400),
            galleryIcons: ["building.2.fill", "sofa.fill", "building.columns.fill"],
            agentName: "Luis Perez",
            agentAgency: "Capital Realty",
            iconName: "building.2.fill",
            imageName: "propertyCityApartment"
        ),
        PropertyItem(
            id: "p3",
            title: "Family House with Garden",
            location: "Santiago",
            priceText: "$265,000",
            priceValue: 265_000,
            listingType: "Buy",
            propertyType: "House",
            bedrooms: 3,
            bathrooms: 2,
            area: "180 m²",
            areaValue: 180,
            summary: "A quiet family home with a backyard, covered parking, and easy access to schools and shops.",
            amenities: ["Garden", "Parking", "Power Backup"],
            isFurnished: false,
            source: "SuperCasas",
            listedDate: Date().addingTimeInterval(-18 * 86_400),
            galleryIcons: ["house.fill", "leaf.fill", "car.fill"],
            agentName: "Ana Rodriguez",
            agentAgency: "Northern Estates",
            iconName: "house.fill",
            imageName: "propertyFamilyHouse"
        ),
        PropertyItem(
            id: "p4",
            title: "Beachfront Condo",
            location: "Puerto Plata",
            priceText: "$2,100/mo",
            priceValue: 2_100,
            listingType: "Rent",
            propertyType: "Apartment",
            bedrooms: 3,
            bathrooms: 2,
            area: "140 m²",
            areaValue: 140,
            summary: "Wake up to ocean views in this furnished condo with balcony, gym access, and 24/7 security.",
            amenities: ["Ocean View", "Gym", "Security", "Furnished"],
            isFurnished: true,
            source: "Encuentra24",
            listedDate: Date().addingTimeInterval(-1 * 86_400),
            galleryIcons: ["water.waves", "building.2.fill", "figure.run"],
            agentName: "Diego Alvarez",
            agentAgency: "Coastline Living",
            iconName: "water.waves",
            imageName: "propertyBeachCondo"
        ),
        PropertyItem(
            id: "p5",
            title: "Luxury Cap Cana Villa",
            location: "Cap Cana",
            priceText: "$890,000",
            priceValue: 890_000,
            listingType: "Buy",
            propertyType: "Villa",
            bedrooms: 5,
            bathrooms: 4,
            area: "410 m²",
            areaValue: 410,
            summary: "A premium villa with resort access, smart home features, and a resort-style outdoor living space.",
            amenities: ["Pool", "Smart Home", "Golf Access", "Maid Room"],
            isFurnished: false,
            source: "Cap Cana Listings",
            listedDate: Date().addingTimeInterval(-12 * 86_400),
            galleryIcons: ["sparkles", "flag.fill", "drop.fill"],
            agentName: "Camila Reyes",
            agentAgency: "Cap Cana Residences",
            iconName: "sparkles",
            imageName: "propertyLuxuryVilla"
        ),
        PropertyItem(
            id: "p6",
            title: "Downtown Studio",
            location: "Santo Domingo",
            priceText: "$750/mo",
            priceValue: 750,
            listingType: "Rent",
            propertyType: "Apartment",
            bedrooms: 1,
            bathrooms: 1,
            area: "42 m²",
            areaValue: 42,
            summary: "A compact unfurnished studio near Parque Independencia, ideal for a first apartment in the city.",
            amenities: ["Elevator", "Security", "A/C"],
            isFurnished: false,
            source: "Corotos",
            listedDate: Date().addingTimeInterval(-5 * 86_400),
            galleryIcons: ["building.fill", "lamp.desk.fill", "window.casement"],
            agentName: "Luis Perez",
            agentAgency: "Capital Realty",
            iconName: "building.fill",
            imageName: "propertyDowntownStudio"
        ),
        PropertyItem(
            id: "p7",
            title: "Garden Townhouse",
            location: "Punta Cana",
            priceText: "$1,800/mo",
            priceValue: 1_800,
            listingType: "Rent",
            propertyType: "House",
            bedrooms: 3,
            bathrooms: 2,
            area: "160 m²",
            areaValue: 160,
            summary: "A furnished townhouse with a private garden, two parking spaces, and a short drive to the beach.",
            amenities: ["Garden", "Parking", "Furnished", "A/C", "Pool"],
            isFurnished: true,
            source: "Encuentra24",
            listedDate: Date().addingTimeInterval(-6 * 86_400),
            galleryIcons: ["house.fill", "tree.fill", "car.fill"],
            agentName: "Maria Santos",
            agentAgency: "Caribbean Homes",
            iconName: "house.fill",
            imageName: "propertyGardenTownhouse"
        ),
        PropertyItem(
            id: "p8",
            title: "Golf View Apartment",
            location: "Cap Cana",
            priceText: "$310,000",
            priceValue: 310_000,
            listingType: "Buy",
            propertyType: "Apartment",
            bedrooms: 2,
            bathrooms: 2,
            area: "118 m²",
            areaValue: 118,
            summary: "A bright apartment overlooking the golf course with resort amenities and a furnished living area.",
            amenities: ["Golf Access", "Pool", "Furnished", "Gym", "Security"],
            isFurnished: true,
            source: "Realtor DR",
            listedDate: Date().addingTimeInterval(-2 * 86_400),
            galleryIcons: ["building.2.fill", "flag.fill", "sportscourt.fill"],
            agentName: "Camila Reyes",
            agentAgency: "Cap Cana Residences",
            iconName: "building.2.fill",
            imageName: "propertyGolfApartment"
        )
    ]
}

struct SavedSearch {
    var id: String
    var location: String?
    var listingType: String?
    var minPrice: Int?
    var maxPrice: Int?
    var minBedrooms: Int?
    var amenities: Set<String>
    var alertOn: Bool

    var title: String {
        var parts: [String] = []
        if let listingType { parts.append(listingType) }
        if let location { parts.append(location) }
        return parts.isEmpty ? "Saved Search" : parts.joined(separator: " · ")
    }

    var subtitle: String {
        var parts: [String] = []
        if let maxPrice {
            parts.append(maxPrice >= 1_000 ? "Up to $\(maxPrice / 1_000)k" : "Up to $\(maxPrice)")
        } else if let minPrice {
            parts.append("$\(minPrice / 1_000)k+")
        }
        if let minBedrooms { parts.append("\(minBedrooms)+ beds") }
        if !amenities.isEmpty { parts.append(amenities.sorted().joined(separator: ", ")) }
        return parts.isEmpty ? "Any price · Any bedrooms" : parts.joined(separator: "  ·  ")
    }

    func asCriteria() -> PropertySearchCriteria {
        var criteria = PropertySearchCriteria()
        criteria.location = location
        criteria.listingType = listingType
        criteria.minPrice = minPrice
        criteria.maxPrice = maxPrice
        criteria.minBedrooms = minBedrooms
        criteria.amenities = amenities
        return criteria
    }

    static func from(_ criteria: PropertySearchCriteria, alertOn: Bool = true) -> SavedSearch {
        SavedSearch(
            id: UUID().uuidString,
            location: criteria.location,
            listingType: criteria.listingType,
            minPrice: criteria.minPrice,
            maxPrice: criteria.maxPrice,
            minBedrooms: criteria.minBedrooms,
            amenities: criteria.amenities,
            alertOn: alertOn
        )
    }
}

final class PropertyStore {
    static let shared = PropertyStore()

    private(set) var all: [PropertyItem] = PropertyItem.samples
    private(set) var favoriteIDs: Set<String> = []
    private(set) var compareIDs: [String] = []
    private(set) var recentlyViewed: [PropertyItem] = Array(PropertyItem.samples.prefix(2))
    private(set) var savedSearches: [SavedSearch] = [
        SavedSearch(
            id: "s1",
            location: "Punta Cana",
            listingType: "Buy",
            minPrice: nil,
            maxPrice: 500_000,
            minBedrooms: 3,
            amenities: ["Pool"],
            alertOn: true
        ),
        SavedSearch(
            id: "s2",
            location: "Santo Domingo",
            listingType: "Rent",
            minPrice: nil,
            maxPrice: 1_500,
            minBedrooms: 2,
            amenities: ["A/C", "Security"],
            alertOn: false
        )
    ]
    private(set) var pendingCriteria: PropertySearchCriteria?
    private(set) var enquiries: [EnquiryItem] = [
        EnquiryItem(
            id: "e1",
            propertyId: "p1",
            propertyTitle: "Oceanview Villa",
            agentName: "Maria Santos",
            message: "I'm interested in Oceanview Villa in Punta Cana.",
            contactName: "Alex Rivera",
            email: "alex.rivera@email.com",
            phone: "+1 809 555 0142",
            date: Date().addingTimeInterval(-2 * 86_400)
        )
    ]

    static let locations = ["Punta Cana", "Santo Domingo", "Santiago", "Puerto Plata", "Cap Cana"]
    static let propertyTypes = ["Apartment", "House", "Villa"]
    static var sources: [String] {
        Array(Set(PropertyItem.samples.map(\.source))).sorted()
    }
    static let amenityOptions = ["Pool", "Parking", "Furnished", "Garden", "A/C", "Elevator", "Security", "Ocean View", "Gym", "Smart Home", "Golf Access", "Power Backup"]

    private init() {}

    func isFavorite(_ id: String) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(_ id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }

    @discardableResult
    func addToCompare(_ id: String) -> String {
        if compareIDs.contains(id) {
            return "Already added to compare."
        }
        guard compareIDs.count < 3 else {
            return "You can compare up to 3 properties."
        }
        compareIDs.append(id)
        return "Added to compare (\(compareIDs.count)/3)."
    }

    func favoriteProperties() -> [PropertyItem] {
        all.filter { favoriteIDs.contains($0.id) }
    }

    func isCompared(_ id: String) -> Bool {
        compareIDs.contains(id)
    }

    @discardableResult
    func toggleCompare(_ id: String) -> String {
        if let index = compareIDs.firstIndex(of: id) {
            compareIDs.remove(at: index)
            return "Removed from compare."
        }
        guard compareIDs.count < 3 else {
            return "You can compare up to 3 properties."
        }
        compareIDs.append(id)
        return "Added to compare (\(compareIDs.count)/3)."
    }

    func comparedProperties() -> [PropertyItem] {
        compareIDs.compactMap { id in all.first { $0.id == id } }
    }

    func compareCandidates() -> [PropertyItem] {
        let compared = comparedProperties()
        let remaining = all.filter { !compareIDs.contains($0.id) }
        let favorites = remaining.filter { favoriteIDs.contains($0.id) }
        let others = remaining.filter { !favoriteIDs.contains($0.id) }
        return compared + favorites + others
    }

    func saveSearch(from criteria: PropertySearchCriteria, alertOn: Bool = true) {
        savedSearches.insert(SavedSearch.from(criteria, alertOn: alertOn), at: 0)
    }

    func upsertSearch(_ search: SavedSearch) {
        if let index = savedSearches.firstIndex(where: { $0.id == search.id }) {
            savedSearches[index] = search
        } else {
            savedSearches.insert(search, at: 0)
        }
    }

    func deleteSearch(id: String) {
        savedSearches.removeAll { $0.id == id }
    }

    func setAlert(id: String, isOn: Bool) {
        guard let index = savedSearches.firstIndex(where: { $0.id == id }) else { return }
        savedSearches[index].alertOn = isOn
    }

    func applySavedSearch(_ search: SavedSearch) {
        pendingCriteria = search.asCriteria()
    }

    func consumePendingCriteria() -> PropertySearchCriteria? {
        let value = pendingCriteria
        pendingCriteria = nil
        return value
    }

    func addEnquiry(property: PropertyItem, name: String, email: String, phone: String, message: String) {
        let item = EnquiryItem(
            id: UUID().uuidString,
            propertyId: property.id,
            propertyTitle: property.title,
            agentName: property.agentName,
            message: message,
            contactName: name,
            email: email,
            phone: phone,
            date: Date()
        )
        enquiries.insert(item, at: 0)
        AgentStore.shared.recordLead(from: item)
    }

    func comparisonSummary(for properties: [PropertyItem]) -> String {
        guard let best = properties.max(by: { comparisonScore($0) < comparisonScore($1) }) else {
            return "Select properties to see an AI summary."
        }
        return "\(best.title) is the best match for your budget and requirements."
    }

    private func comparisonScore(_ property: PropertyItem) -> Int {
        let cost = property.costPerSquareMeter
        return property.amenities.count * 8
            + property.bedrooms * 4
            + (property.isFurnished ? 6 : 0)
            - cost / 40
    }

    func markViewed(_ property: PropertyItem) {
        recentlyViewed.removeAll { $0.id == property.id }
        recentlyViewed.insert(property, at: 0)
        if recentlyViewed.count > 8 {
            recentlyViewed = Array(recentlyViewed.prefix(8))
        }
    }

    func recommended(filter: String?) -> [PropertyItem] {
        guard let filter, !filter.isEmpty else { return all }
        let filtered = all.filter { $0.matches(filter: filter) }
        return filtered.isEmpty ? all : filtered
    }

    func search(_ criteria: PropertySearchCriteria) -> [PropertyItem] {
        var results = all.filter { $0.matches(criteria) }
        switch criteria.sort {
        case .recommended:
            if !criteria.keyword.isEmpty {
                results.sort { relevance($0, keyword: criteria.keyword) > relevance($1, keyword: criteria.keyword) }
            }
        case .priceLowToHigh:
            results.sort { $0.priceValue < $1.priceValue }
        case .priceHighToLow:
            results.sort { $0.priceValue > $1.priceValue }
        case .newest:
            results.sort { $0.listedDate > $1.listedDate }
        }
        return results
    }

    func topMatches(for query: String) -> [PropertyItem] {
        let text = query.lowercased()
        var scored = all.map { property -> (PropertyItem, Int) in
            var score = 0
            if text.contains(property.listingType.lowercased()) { score += 3 }
            if text.contains(property.propertyType.lowercased()) { score += 4 }
            if text.contains(property.location.lowercased()) { score += 4 }
            if text.contains("beach") && (property.location.contains("Punta") || property.location.contains("Puerto") || property.location.contains("Cap")) {
                score += 3
            }
            if text.contains("\(property.bedrooms)") { score += 2 }
            if text.contains("furnished") && property.isFurnished { score += 2 }
            return (property, score)
        }
        scored.sort { $0.1 > $1.1 }
        return Array(scored.prefix(3).map(\.0))
    }

    private func relevance(_ property: PropertyItem, keyword: String) -> Int {
        let text = keyword.lowercased()
        var score = 0
        if property.location.lowercased().contains(text) { score += 5 }
        if property.title.lowercased().contains(text) { score += 4 }
        if property.propertyType.lowercased().contains(text) { score += 3 }
        if property.listingType.lowercased().contains(text) { score += 2 }
        return score
    }
}

extension UIViewController {

    var isAgentFlow: Bool {
        var current: UIViewController? = self
        while let controller = current {
            if controller is AgentTabBarController { return true }
            current = controller.parent ?? controller.presentingViewController
        }
        return tabBarController is AgentTabBarController
    }

    func openPropertyDetails(_ property: PropertyItem) {
        PropertyStore.shared.markViewed(property)
        if isAgentFlow {
            let details: AgentPropertyDetailsVC = AgentStoryboard.load("AgentPropertyDetailsVC")
            details.property = property
            details.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(details, animated: true)
            return
        }
        guard let details = UIStoryboard(name: "TenantSB", bundle: nil)
            .instantiateViewController(withIdentifier: "TenantPropertyDetailsVC") as? TenantPropertyDetailsVC else {
            return
        }
        details.property = property
        details.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(details, animated: true)
    }

    func openAISearch(prefilled query: String? = nil) {
        guard let aiVC = UIStoryboard(name: "TenantSB", bundle: nil)
            .instantiateViewController(withIdentifier: "TenantAISearchVC") as? TenantAISearchVC else {
            return
        }
        aiVC.initialQuery = query
        aiVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(aiVC, animated: true)
    }

    func openCompare(_ properties: [PropertyItem]) {
        let compareVC = TenantCompareVC()
        compareVC.properties = properties
        compareVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(compareVC, animated: true)
    }

    func openSavedSearch(_ search: SavedSearch?) {
        let editor = TenantSavedSearchVC()
        editor.search = search ?? SavedSearch(
            id: UUID().uuidString,
            location: nil,
            listingType: nil,
            minPrice: nil,
            maxPrice: nil,
            minBedrooms: nil,
            amenities: [],
            alertOn: true
        )
        editor.isNew = search == nil
        editor.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editor, animated: true)
    }
}
