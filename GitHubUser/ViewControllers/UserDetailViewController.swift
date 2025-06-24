import Foundation
import UIKit
import Combine
import WebKit

class UserDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel = UserDetailViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let username: String
    private let tableView = UITableView()
    private let headerView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let followerLabel = UILabel()

    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = username
        setupTableView()
        bindViewModel()
        Task { await viewModel.fetchUserDetail(username: username) }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RepoCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bindViewModel() {
        viewModel.$detail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self = self, let detail = detail else { return }
                let headerView = UserDetailHeaderView()
                headerView.configure(with: detail)

                // Important: force layout and set correct height
                let targetSize = CGSize(width: self.tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
                let height = headerView.systemLayoutSizeFitting(targetSize).height
                headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: height)
                self.tableView.tableHeaderView = headerView

                self.tableView.reloadData()
            }.store(in: &cancellables)

        viewModel.$repos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        let repo = viewModel.repos[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(repo.name)\n\(repo.language ?? "Unknown") | ⭐️ \(repo.stargazers_count)\n\(repo.description ?? "")"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = viewModel.repos[indexPath.row]
        if let url = URL(string: repo.html_url) {
            let webVC = WebViewController(url: url)
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
}
