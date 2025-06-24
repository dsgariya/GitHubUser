
import XCTest
import Combine
@testable import GitHubUser

final class UserDetailViewModelTests: XCTestCase {
    var viewModel: UserDetailViewModel!
    var mockApiClient: MockGitHubAPIClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockApiClient = MockGitHubAPIClient()
        viewModel = UserDetailViewModel(apiClient: mockApiClient)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockApiClient = nil
        super.tearDown()
    }

    func testFetchUserDetailSuccess() async {
        // Arrange
        mockApiClient.shouldThrow = false
        mockApiClient.detailToReturn = GitHubUserDetail(
            login: "testuser",
            avatar_url: "https://avatar.testuser",
            name: "Test User",
            followers: 42,
            following: 7
        )
        mockApiClient.reposToReturn = [
            GitHubRepository(
                id: 1,
                name: "Repo1",
                language: "Swift",
                stargazers_count: 10,
                description: "Repo 1 description",
                html_url: "https://github.com/user/repo1",
                fork: false
            ),
            GitHubRepository(
                id: 2,
                name: "Repo2",
                language: "Objective-C",
                stargazers_count: 5,
                description: "Repo 2 description",
                html_url: "https://github.com/user/repo2",
                fork: false
            )
        ]

        let detailExpectation = expectation(description: "detail updated")
        let reposExpectation = expectation(description: "repos updated")
        let loadingStartExpectation = expectation(description: "loading starts")
        let loadingEndExpectation = expectation(description: "loading ends")

        var didStartLoading = false
        var didEndLoading = false

        viewModel.$isLoading
            .removeDuplicates()
            .sink { isLoading in
                if isLoading && !didStartLoading {
                    didStartLoading = true
                    loadingStartExpectation.fulfill()
                } else if !isLoading && !didEndLoading {
                    didEndLoading = true
                    loadingEndExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$detail
            .dropFirst()
            .sink { detail in
                if let detail = detail {
                    XCTAssertEqual(detail.login, "testuser")
                    XCTAssertEqual(detail.followers, 42)
                    XCTAssertEqual(detail.following, 7)
                    detailExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$repos
            .dropFirst()
            .sink { repos in
                if repos.count == 2 {
                    XCTAssertEqual(repos[0].name, "Repo1")
                    XCTAssertEqual(repos[0].stargazers_count, 10)
                    reposExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        await viewModel.fetchUserDetail(username: "testuser")

        // Assert
        await fulfillment(of: [
            detailExpectation,
            reposExpectation,
            loadingStartExpectation,
            loadingEndExpectation
        ], timeout: 5)

        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testFetchUserDetailFailure() async {
        // Arrange
        mockApiClient.shouldThrow = true

        let errorExpectation = expectation(description: "error published")
        var receivedError: String?

        viewModel.$error
            .compactMap { $0 }
            .sink { error in
                receivedError = error
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        await viewModel.fetchUserDetail(username: "testuser")

        // Assert
        await fulfillment(of: [errorExpectation], timeout: 2)

        XCTAssertNotNil(receivedError)
        XCTAssertNil(viewModel.detail)
        XCTAssertTrue(viewModel.repos.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
}
