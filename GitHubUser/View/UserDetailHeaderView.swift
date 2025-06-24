import UIKit

class UserDetailHeaderView: UIView {
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let followerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true

        nameLabel.font = .boldSystemFont(ofSize: 18)
        usernameLabel.font = .systemFont(ofSize: 16)
        followerLabel.font = .systemFont(ofSize: 14)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        followerLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(followerLabel)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            followerLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            followerLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            followerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    func configure(with detail: GitHubUserDetail) {
        nameLabel.text = detail.name ?? ""
        usernameLabel.text = detail.login
        followerLabel.text = "Followers: \(detail.followers)  Following: \(detail.following)"
        avatarImageView.image = UIImage(systemName: "person.crop.circle") // placeholder
        ImageLoader.shared.loadImage(from: detail.avatar_url) { [weak self] image in
            self?.avatarImageView.image = image
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 120)
    }
}
