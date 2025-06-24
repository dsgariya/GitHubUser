import Foundation
import Combine
class UserDetailViewModel {
    private let apiClient: GitHubAPIClientProtocol

    @Published private(set) var detail: GitHubUserDetail?
    @Published private(set) var repos: [GitHubRepository] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    init(apiClient: GitHubAPIClientProtocol = GitHubAPIClient.shared) {
        self.apiClient = apiClient
    }

    func fetchUserDetail(username: String) async {
        isLoading = true
        error = nil
        do {
            async let detailFetch = apiClient.fetchUserDetail(username: username)
            async let reposFetch = apiClient.fetchRepositories(username: username)
            let (detail, repos) = try await (detailFetch, reposFetch)
            self.detail = detail
            self.repos = repos
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
