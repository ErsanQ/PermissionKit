import Foundation

/// The types of system permissions supported by `PermissionKit`.
public enum PermissionType: String, CaseIterable, Sendable {
    /// Access to the device's camera for photo or video capture.
    case camera
    /// Access to the user's photo library (Read/Write).
    case photoLibrary
    /// The ability to send local or remote notifications.
    case notifications
    /// Access to the App Tracking Transparency identifier.
    case tracking
    /// Access to the device's microphone for audio recording.
    case microphone
}

/// The current state of a requested permission.
public enum PermissionStatus: String, Sendable {
    /// The user has explicitly granted access.
    case authorized
    /// The user has explicitly denied access.
    case denied
    /// The user has not yet been prompted for this permission.
    case notDetermined
    /// Access is restricted (e.g., due to parental controls).
    case restricted
    /// Access is limited (specific to the Photo Library in iOS 14+).
    case limited
}
