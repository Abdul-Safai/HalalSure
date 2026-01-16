import Foundation

// MARK: - Proxy response shape from your PHP
struct ProxyResponse: Decodable {
    let status: Int
    let url: String
    let html: String
}

// MARK: - Simple product/category structs (expand later)
struct WebCategory: Identifiable {
    let id = UUID()
    let title: String
}

enum ProxyClientError: Error {
    case badURL
    case badStatus(Int)
    case emptyHTML
}

enum HMAWebService {
    /// Base points at your local proxy (Simulator: localhost)
    static var proxyBase = URL(string: "http://localhost/halalsure-api/proxy.php")!

    /// Fetch raw HTML of the HMA page via your proxy (JSON with `html` field)
    static func fetchHalalCheckHTML() async throws -> String {
        var comps = URLComponents(url: proxyBase, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "url", value: "https://hmacanada.org/halal-check/")
        ]
        guard let url = comps.url else { throw ProxyClientError.badURL }

        let (data, resp) = try await URLSession.shared.data(from: url)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard code == 200 else { throw ProxyClientError.badStatus(code) }

        let decoded = try JSONDecoder().decode(ProxyResponse.self, from: data)
        guard !decoded.html.isEmpty else { throw ProxyClientError.emptyHTML }
        return decoded.html
    }

    /// Very lightweight “demo” parse to extract the line of Popular Categories from the HTML.
    /// For production, switch to SwiftSoup (SPM) and select the exact elements.
    static func parsePopularCategories(from html: String) -> [WebCategory] {
        // 1) Try to isolate the "Popular Categories ... Categories" block
        // This is a heuristic based on current site text.
        let lower = html.lowercased()
        guard let startRange = lower.range(of: "popular categories"),
              let endRange = lower.range(of: "categories", range: startRange.upperBound..<lower.endIndex) else {
            return []
        }
        let snippet = lower[startRange.upperBound..<endRange.lowerBound]

        // 2) Known tokens we expect to see (adjust as the site changes)
        let known: [String] = [
            "cheese", "pizza", "croissant", "yogurt",
            "chocolate", "beans", "lentis", "juice",
            "spice", "soft drinks"
        ]

        // 3) Pull those keywords if they appear in the snippet
        var found: [String] = []
        for k in known {
            if snippet.contains(k) { found.append(k) }
        }

        // 4) Normalize titles (capitalization)
        let titled = found.map { word -> String in
            return word.split(separator: " ").map { $0.capitalized }.joined(separator: " ")
        }

        // 5) Wrap into WebCategory
        return Array(NSOrderedSet(array: titled)).compactMap { any in
            (any as? String).map { WebCategory(title: $0) }
        }
    }

    /// Map parsed names to your asset keys used by the ticker (adjust as needed).
    static func mapToTickerItems(_ cats: [WebCategory]) -> [PopularItem] {
        // Your asset names: drink, juice, pizza, crosissant, chips, cheese, cookies
        // Build a simple map from title -> asset key
        let map: [String: String] = [
            "Soft Drinks": "drink",
            "Juice": "juice",
            "Pizza": "pizza",
            "Croissant": "crosissant",
            "Chips": "chips",
            "Cheese": "cheese",
            "Cookies": "cookies"
        ]
        return cats.map { c in
            let key = map[c.title] ?? "drink" // fallback
            return PopularItem(title: c.title, imageName: key)
        }
    }
}
