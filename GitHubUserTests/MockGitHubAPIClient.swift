
import XCTest
import Combine
@testable import GitHubUser

class MockGitHubAPIClient: GitHubAPIClientProtocol {
    var shouldThrow = false
    var callCount = 0
    var usersResponse: [[GitHubUser]] = []
    var detailToReturn: GitHubUserDetail?
    var reposToReturn: [GitHubRepository] = []

    func fetchUsers(since: Int) async throws -> [GitHubUser] {
        if shouldThrow {
            throw NSError(domain: "TestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch users"])
        }
        let response = callCount < usersResponse.count ? usersResponse[callCount] : []
        callCount += 1
        return response
    }

    func fetchUserDetail(username: String) async throws -> GitHubUserDetail {
        if shouldThrow {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user detail"])
        }
        return detailToReturn ?? GitHubUserDetail(login: "mockUser", avatar_url: "https://avatar.url", name: "Mock User", followers: 100, following: 10)
    }

    func fetchRepositories(username: String) async throws -> [GitHubRepository] {
        if shouldThrow {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch repos"])
        }
        return reposToReturn
    }
}
