import Combine
import Foundation

class UserListViewModel {
    private let apiClient: GitHubAPIClientProtocol

    @Published private(set) var users: [GitHubUser] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var isPaginating = false

    private var since: Int = 0
    private var allUsersFetched = false

    init(apiClient: GitHubAPIClientProtocol = GitHubAPIClient.shared) {
        self.apiClient = apiClient
    }

    func fetchInitialUsers() async {
        isLoading = true
        error = nil
        since = 0
        allUsersFetched = false

        do {
            let newUsers = try await apiClient.fetchUsers(since: since)
            users = newUsers
            since = newUsers.last?.id ?? 0
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func fetchMoreUsers() async {
        guard !isPaginating && !allUsersFetched else { return }
        isPaginating = true
        error = nil

        do {
            let newUsers = try await apiClient.fetchUsers(since: since)
            if newUsers.isEmpty {
                allUsersFetched = true
            } else {
                users += newUsers
                since = newUsers.last?.id ?? since
            }
        } catch {
            self.error = error.localizedDescription
        }

        isPaginating = false
    }
}
