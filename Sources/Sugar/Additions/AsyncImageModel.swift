import Foundation
import UIKit

public struct AsyncImageModel: Equatable, Hashable, Identifiable {

    public let id: String
    public var identityId: String

    public init(id: String = UUID().uuidString,
                identityId: String) {
        self.id = id
        self.identityId = identityId
    }
}

public typealias DownloadProgress = (Progress) -> Void
public typealias DownloadCompletion = (Result<UIImage, Error>) -> Void
public protocol ImageDownloading {
    func download(model: AsyncImageModel, progress: DownloadProgress?, completion: @escaping DownloadCompletion)
    func url(model: AsyncImageModel, completion: @escaping (Result<URL, Error>) -> Void)
    func store(data: Data, model: AsyncImageModel)
    func fetchLocal(model: AsyncImageModel, completion: @escaping DownloadCompletion)
}
