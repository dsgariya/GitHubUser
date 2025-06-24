import Foundation
import UIKit
import Combine

class UserListViewController: UITableViewController {
    private let viewModel = UserListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let spinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GitHub Users"
        tableView.register(UserListCell.self, forCellReuseIdentifier: UserListCell.reuseIdentifier)
        
        bindViewModel()
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
        tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.rowHeight = 70

        Task {
            await viewModel.fetchInitialUsers()
        }
    }

    private func bindViewModel() {
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)

        viewModel.$isPaginating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPaginating in
                if isPaginating {
                    self?.spinner.startAnimating()
                } else {
                    self?.spinner.stopAnimating()
                }
            }
            .store(in: &cancellables)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserListCell.reuseIdentifier, for: indexPath) as? UserListCell else {
            return UITableViewCell()
        }
        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        let detailVC = UserDetailViewController(username: user.login)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight * 1.5 {
            Task {
                await viewModel.fetchMoreUsers()
            }
        }
    }
}

