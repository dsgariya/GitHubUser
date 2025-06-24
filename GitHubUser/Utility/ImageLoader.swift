import UIKit
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

final class ImageLoader {
    static let shared = ImageLoader()

    private let imageQueue = DispatchQueue(label: "com.myApp.imageLoader", qos: .userInitiated)

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            completion(cachedImage)
            return
        }

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        imageQueue.async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                ImageCache.shared.setImage(image, forKey: urlString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}


