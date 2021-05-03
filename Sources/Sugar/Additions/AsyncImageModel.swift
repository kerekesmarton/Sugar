import Foundation
import SwiftUI

public enum MediaError: ServiceError {

    case empty
    case unknown
    case other(ServiceError)

    public var errorDescription: String {
        switch self {
        case .empty:
            return "Media not found"
        case .unknown:
            return "Unknown media error"
        case .other(let error):
            return error.errorDescription
        }
    }

    public var recoverySuggestion: String {
        switch self {
        case .empty, .unknown:
            return ""
        case .other(let error):
            return error.recoverySuggestion
        }
    }

    public var suggestiveImage: Image {
        switch self {
        case .empty, .unknown:
            return Image("")
        case .other(let error):
            return error.suggestiveImage
        }
    }

    public init(from error: Error) {
        switch error {
        case let error as ServiceError:
            self = .other(error)
        default:
            self = MediaError.unknown
        }
    }

    public init?(other: ServiceError?) {
        guard let error = other else { return nil}
        self = .other(error)
    }
}

public struct AsyncImageModel: Equatable, Hashable, Identifiable {

    public let id: String
    public var identityId: String
    public var isVideo: Bool {
        return SupportedVideoSuffix.mathesSuffix(self)
    }

    private enum SupportedVideoSuffix: String, CaseIterable {
        case mp4
        case mov
        case mpg
        case m2ts

        static func mathesSuffix(_ model: AsyncImageModel) -> Bool {
            let components = model.id.split(separator: ".")
            guard components.count == 2 else {
                return false
            }
            guard let suffix = components.last else { return false }
            return SupportedVideoSuffix(rawValue: String(suffix)) != nil
        }
    }

    public enum VideoQuality {
        case list
        case audioOnly
        case small
        case medium
        case large
        case xLarge

        var videoPath: String {
            var fileExtension = "m3u8"
            switch self {
            case .list:
                return ".\(fileExtension)"
            case .audioOnly:
                return ["_audio", fileExtension].joined(separator: ".")
            case .small:
                return ["_325", fileExtension].joined(separator: ".")
            case .medium:
                return ["_750", fileExtension].joined(separator: ".")
            case .large:
                return ["_1500", fileExtension].joined(separator: ".")
            case .xLarge:
                return ["_3000", fileExtension].joined(separator: ".")
            }
        }
    }

    public func videoDirectory(quality: VideoQuality) -> String {
        guard isVideo else {
            return ""
        }

        func videoIdWithoutExtension(_ model: AsyncImageModel) -> String {
            let components = model.id.split(separator: ".")
            guard let id = components.first, components.count == 2 else {
                return ""
            }
            return String(id)
        }

        func makePath(video id: String, quality: VideoQuality) -> String {
            "\(id)/\(id+quality.videoPath)"
        }

        let path = makePath(video: videoIdWithoutExtension(self), quality: quality)
        return path
    }



    public init(id: String = UUID().uuidString,
                identityId: String) {
        self.id = id
        self.identityId = identityId
    }
}

public typealias DownloadProgress = (Progress) -> Void
public typealias DownloadCompletion = (Result<UIImage, MediaError>) -> Void
public protocol ImageDownloading {
    func download(model: AsyncImageModel, progress: DownloadProgress?, completion: @escaping DownloadCompletion)
    func videoUrl(model: AsyncImageModel, quality: AsyncImageModel.VideoQuality, completion: @escaping (Result<URL, MediaError>) -> Void)
    func store(data: Data, model: AsyncImageModel)
    func fetchLocal(model: AsyncImageModel, completion: @escaping DownloadCompletion)
}
