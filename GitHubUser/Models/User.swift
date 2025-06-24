import Foundation

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let avatar_url: String
}

struct GitHubUserDetail: Codable {
    let login: String
    let avatar_url: String
    let name: String?
    let followers: Int
    let following: Int
}
