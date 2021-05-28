import UIKit

public protocol ImageStorage {
    func cachedImage(for model: AsyncImageModel, completion: @escaping (UIImage?) -> Void)
    func store(_ data: Data, for model: AsyncImageModel, completion: @escaping Action)
    func erase(_ block: @escaping Action)
    func downloadImage(with url: URL, completion: @escaping (UIImage?, Data?, Error?, Bool) -> Void)
}
