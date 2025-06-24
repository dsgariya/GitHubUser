import XCTest
import Combine
@testable import GitHubUser

final class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var mockApiClient: MockGitHubAPIClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        mockApiClient = MockGitHubAPIClient()
        viewModel = UserListViewModel(apiClient: mockApiClient)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockApiClient = nil
    }

    func testFetchInitialUsersSuccess() async {
        // Arrange
        mockApiClient.usersResponse = [[
            GitHubUser(login: "user1", id: 1, avatar_url: "url1"),
            GitHubUser(login: "user2", id: 2, avatar_url: "url2")
        ]]

        let usersExpectation = expectation(description: "users updated")
        let loadingEndExpectation = expectation(description: "loading ended")

        viewModel.$users
            .dropFirst()
            .sink { users in
                if users.count == 2 {
                    usersExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .removeDuplicates()
            .dropFirst()
            .sink { isLoading in
                if !isLoading {
                    loadingEndExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        await viewModel.fetchInitialUsers()

        // Assert
        await fulfillment(of: [usersExpectation, loadingEndExpectation], timeout: 2)
        XCTAssertNil(viewModel.error)
    }

    func testFetchInitialUsersFailure() async {
        // Arrange
        mockApiClient.shouldThrow = true

        let errorExpectation = expectation(description: "error published")

        viewModel.$error
            .compactMap { $0 }
            .sink { error in
                XCTAssertEqual(error, "Failed to fetch users")
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        await viewModel.fetchInitialUsers()

        // Assert
        await fulfillment(of: [errorExpectation], timeout: 2)
        XCTAssertTrue(viewModel.users.isEmpty)
    }

    func testPaginationSuccess() async {
        // Arrange
        mockApiClient.usersResponse = [
            [GitHubUser(login: "user1", id: 1, avatar_url: "url1")],
            [GitHubUser(login: "user2", id: 2, avatar_url: "url2")]
        ]

        let usersExpectation = expectation(description: "users paginated")

        viewModel.$users
            .dropFirst(2) // wait until after second update
            .sink { users in
                if users.count == 2 {
                    XCTAssertEqual(users[1].login, "user2")
                    usersExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        await viewModel.fetchInitialUsers()
        await viewModel.fetchMoreUsers()

        // Assert
        await fulfillment(of: [usersExpectation], timeout: 2)
        XCTAssertNil(viewModel.error)
    }

    func testPaginationStopsWhenAllUsersFetched() async {
        // Arrange
        mockApiClient.usersResponse = [[
            GitHubUser(login: "user1", id: 1, avatar_url: "url1")
        ], []] // second call returns empty

        await viewModel.fetchInitialUsers()
        await viewModel.fetchMoreUsers() // This one returns empty

        let callCountBefore = mockApiClient.callCount

        // Act — Try paginating again, should not trigger API
        await viewModel.fetchMoreUsers()

        // Assert
        XCTAssertEqual(mockApiClient.callCount, callCountBefore, "Should not fetch more if all users are fetched")
    }

}
