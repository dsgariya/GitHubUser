import Foundation

struct GitHubRepository: Codable {
    let id: Int
    let name: String
    let language: String?
    let stargazers_count: Int
    let description: String?
    let html_url: String
    let fork: Bool
}
