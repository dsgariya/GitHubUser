import Foundation

protocol GitHubAPIClientProtocol {
    func fetchUsers(since: Int) async throws -> [GitHubUser]
    func fetchUserDetail(username: String) async throws -> GitHubUserDetail
    func fetchRepositories(username: String) async throws -> [GitHubRepository]
}

extension GitHubAPIClient: GitHubAPIClientProtocol {}

final class GitHubAPIClient {
    static let shared = GitHubAPIClient()
    private let session = URLSession.shared
    private let baseURL = "https://api.github.com"
    private let token = "Bearer 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"

    private init() {}

    func fetchUsers(since: Int = 0) async throws -> [GitHubUser] {
        let url = URL(string: "\(baseURL)/users?since=\(since)")!
        return try await request(url: url)
    }

    func fetchUserDetail(username: String) async throws -> GitHubUserDetail {
        let url = URL(string: "\(baseURL)/users/\(username)")!
        return try await request(url: url)
    }

    func fetchRepositories(username: String) async throws -> [GitHubRepository] {
        let url = URL(string: "\(baseURL)/users/\(username)/repos")!
        let repos: [GitHubRepository] = try await request(url: url)
        return repos.filter { !$0.fork }
    }

    private func request<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
