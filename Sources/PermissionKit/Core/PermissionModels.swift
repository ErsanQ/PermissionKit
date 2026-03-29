import Foundation

/// The current status of a permission request.
public enum PermissionStatus: String, Codable, Sendable {
    /// The user has granted authorization.
    case authorized
    /// The user has explicitly denied authorization.
    case denied
    /// The user has not yet made a choice regarding this application.
    case notDetermined
    /// The application is not authorized to use the service.
    case restricted
    /// The user has granted limited authorization (e.g., photo library access).
    case limited
}

/// The types of permissions supported by `PermissionKit`.
public enum PermissionType: String, CaseIterable, Sendable {
    case camera
    case photoLibrary
    case notifications
    case tracking
    case microphone
    
    /// The Info.plist key required for this permission.
    public var usageDescriptionKey: String {
        switch self {
        case .camera: return "NSCameraUsageDescription"
        case .photoLibrary: return "NSPhotoLibraryUsageDescription"
        case .notifications: return "N/A"
        case .tracking: return "NSUserTrackingUsageDescription"
        case .microphone: return "NSMicrophoneUsageDescription"
        }
    }
}
