import Foundation
import SwiftUI

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(Photos)
import Photos
#endif

#if canImport(UserNotifications)
import UserNotifications
#endif

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// A central manager responsible for handling permission requests and status checks across the ErsanQ ecosystem.
///
/// `PermissionManager` provides a modern, `async/await` based API that wraps Apple's various permission
/// frameworks (AVFoundation, PHPhotoLibrary, etc.) into a unified interface.
///
/// ## Usage
/// ```swift
/// let status = await PermissionManager.shared.request(for: .camera)
/// if status == .authorized {
///     startCamera()
/// }
/// ```
@MainActor
public final class PermissionManager: ObservableObject {
    
    /// The shared singleton instance of `PermissionManager`.
    public static let shared = PermissionManager()
    
    private init() {}
    
    /// Requests the specified permission from the system.
    ///
    /// If the permission has already been determined (Authorized or Denied), this method
    /// returns the current status immediately without prompting the user.
    ///
    /// - Parameter type: The type of permission to request (e.g., `.camera`).
    /// - Returns: The resulting `PermissionStatus` after the request completes.
    public func request(for type: PermissionType) async -> PermissionStatus {
        switch type {
        case .camera:
            return await requestCamera()
        case .photoLibrary:
            return await requestPhotoLibrary()
        case .notifications:
            return await requestNotifications()
        case .tracking:
            return await requestTracking()
        case .microphone:
            return await requestMicrophone()
        }
    }
    
    /// Checks the current status of the specified permission without prompting the user.
    ///
    /// - Parameter type: The type of permission to check.
    /// - Returns: The current `PermissionStatus`.
    public func status(for type: PermissionType) async -> PermissionStatus {
        switch type {
        case .camera:
            return checkCameraStatus()
        case .photoLibrary:
            return checkPhotoLibraryStatus()
        case .notifications:
            return await checkNotificationsStatus()
        case .tracking:
            return checkTrackingStatus()
        case .microphone:
            return checkMicrophoneStatus()
        }
    }
    
    // MARK: - Camera
    
    private func requestCamera() async -> PermissionStatus {
        #if canImport(AVFoundation)
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        guard status == .notDetermined else {
            return mapAVStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ? .authorized : .denied)
            }
        }
        #else
        return .denied
        #endif
    }
    
    private func checkCameraStatus() -> PermissionStatus {
        #if canImport(AVFoundation)
        return mapAVStatus(AVCaptureDevice.authorizationStatus(for: .video))
        #else
        return .denied
        #endif
    }
    
    // MARK: - Microphone
    
    private func requestMicrophone() async -> PermissionStatus {
        #if canImport(AVFoundation)
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        guard status == .notDetermined else {
            return mapAVStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted ? .authorized : .denied)
            }
        }
        #else
        return .denied
        #endif
    }
    
    private func checkMicrophoneStatus() -> PermissionStatus {
        #if canImport(AVFoundation)
        return mapAVStatus(AVCaptureDevice.authorizationStatus(for: .audio))
        #else
        return .denied
        #endif
    }
    
    // MARK: - Photo Library
    
    private func requestPhotoLibrary() async -> PermissionStatus {
        #if canImport(Photos)
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .notDetermined else {
            return mapPHStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                continuation.resume(returning: self.mapPHStatus(newStatus))
            }
        }
        #else
        return .denied
        #endif
    }
    
    private func checkPhotoLibraryStatus() -> PermissionStatus {
        #if canImport(Photos)
        return mapPHStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
        #else
        return .denied
        #endif
    }
    
    // MARK: - Notifications
    
    private func requestNotifications() async -> PermissionStatus {
        #if canImport(UserNotifications)
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
        #else
        return .denied
        #endif
    }
    
    private func checkNotificationsStatus() async -> PermissionStatus {
        #if canImport(UserNotifications)
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let status: PermissionStatus
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral: status = .authorized
                case .denied: status = .denied
                case .notDetermined: status = .notDetermined
                @unknown default: status = .denied
                }
                continuation.resume(returning: status)
            }
        }
        #else
        return .denied
        #endif
    }
    
    // MARK: - Tracking
    
    private func requestTracking() async -> PermissionStatus {
        #if canImport(AppTrackingTransparency)
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else {
            return mapTrackingStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            ATTrackingManager.requestTrackingAuthorization { newStatus in
                continuation.resume(returning: self.mapTrackingStatus(newStatus))
            }
        }
        #else
        return .authorized
        #endif
    }
    
    private func checkTrackingStatus() -> PermissionStatus {
        #if canImport(AppTrackingTransparency)
        return mapTrackingStatus(ATTrackingManager.trackingAuthorizationStatus)
        #else
        return .authorized
        #endif
    }
    
    // MARK: - Mapping Helpers
    
    #if canImport(AVFoundation)
    private func mapAVStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
    #endif
    
    #if canImport(Photos)
    private func mapPHStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .limited: return .limited
        @unknown default: return .denied
        }
    }
    #endif
    
    #if canImport(AppTrackingTransparency)
    private func mapTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
    #endif
}
