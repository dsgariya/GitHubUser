# 📱 GitHubUsers

A Swift-based iOS app that lists GitHub users and their repositories, built with MVVM architecture, pagination, image caching, and unit tests — designed for team scalability and smooth UX.

---

## 📋 Assignment Requirements Covered

| Feature | Status |
|--------|--------|
| Fetch GitHub users via API | ✅ |
| Display avatar & username in list | ✅ |
| Navigate to repository screen | ✅ |
| Show user detail (avatar, name, followers, following) | ✅ |
| List of user's repositories (excluding forks) | ✅ |
| Repository info: name, language, stars, description | ✅ |
| Open repository in WebView | ✅ |
| Use of GitHub Personal Access Token | ✅ |
| MVVM Architecture | ✅ |
| Image caching (custom) | ✅ |
| Pagination in user list | ✅ |
| Unit Tests for ViewModels | ✅ |

---

## 🧱 Architecture

The project is built using **MVVM (Model-View-ViewModel)** to ensure separation of concerns, testability, and scalability.

### Folder Structure

```
GitHubUser/
├── Models/                // User, Repository
├── Network/               // GitHubAPIClient
├── Utility/               // ImageLoader (with caching)
├── View/                  // Views
├── ViewControllers/       // UIKit ViewControllers
├── ViewModels/            // Business logic, state binding
├── GitHubUserTests/       // Unit Tests + Mocks
├── GitHubUserUITests/     // UI Tests (optional)
```

---

## 🚀 Features

### 🧑‍💻 User List Screen

- Displays GitHub users with avatar and username.
- Infinite scrolling with pagination.
- Avatar images are cached using a custom `ImageLoader`.

### 📄 User Detail Screen

- Displays detailed info (avatar, name, followers, following).
- Lists repositories (excluding forks).
- Repositories show:
  - Name
  - Language (with color dot)
  - Star count
  - Description
- Tapping a repository opens it in an embedded `WebView`.

### ✅ Unit Testing

- ViewModels are unit tested with `MockGitHubAPIClient`.
- ViewModels are injected with protocol (`GitHubAPIClientProtocol`) for flexibility.
- Example tests:
  - Initial fetch
  - Pagination
  - Error handling
---

## 🔐 Authentication

- Uses a [GitHub Personal Access Token](https://developer.github.com/v3/#authentication) via `Authorization` header.
- Avoids hitting unauthenticated 60-req/hour limit.
---

## 🧪 Technologies Used

- `Swift` + `UIKit`
- `Combine` for binding
- `URLSession` for networking
- `MVVM` architecture
- `XCTest` for Unit Testing

---

## 🧼 Future Improvements

- Pull to refresh
- Search users
- CoreData caching
- UI test coverage
- Skeleton loaders while loading
- Swift Concurrency retry logic with exponential backoff

---

## 👨‍💻 Author

DEV SINGH
