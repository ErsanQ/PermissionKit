import Foundation
import AVFoundation
import Photos
import UserNotifications
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
import SwiftUI

/// A manager responsible for handling permission requests and checking status.
@MainActor
public final class PermissionManager: ObservableObject {
    
    /// The shared singleton instance of `PermissionManager`.
    public static let shared = PermissionManager()
    
    private init() {}
    
    /// Requests the specified permission and returns the resulting status.
    /// - Parameter type: The type of permission to request.
    /// - Returns: The updated `PermissionStatus`.
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
    
    /// Checks the current status of the specified permission asynchronously.
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
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        guard status == .notDetermined else {
            return mapAVStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ? .authorized : .denied)
            }
        }
    }
    
    private func checkCameraStatus() -> PermissionStatus {
        return mapAVStatus(AVCaptureDevice.authorizationStatus(for: .video))
    }
    
    // MARK: - Microphone
    
    private func requestMicrophone() async -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        guard status == .notDetermined else {
            return mapAVStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted ? .authorized : .denied)
            }
        }
    }
    
    private func checkMicrophoneStatus() -> PermissionStatus {
        return mapAVStatus(AVCaptureDevice.authorizationStatus(for: .audio))
    }
    
    // MARK: - Photo Library
    
    private func requestPhotoLibrary() async -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .notDetermined else {
            return mapPHStatus(status)
        }
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                continuation.resume(returning: self.mapPHStatus(newStatus))
            }
        }
    }
    
    private func checkPhotoLibraryStatus() -> PermissionStatus {
        return mapPHStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }
    
    // MARK: - Notifications
    
    private func requestNotifications() async -> PermissionStatus {
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
    }
    
    private func checkNotificationsStatus() async -> PermissionStatus {
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
    }
    
    // MARK: - Tracking
    
    private func requestTracking() async -> PermissionStatus {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, macOS 11, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            guard status == .notDetermined else {
                return mapTrackingStatus(status)
            }
            
            return await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { newStatus in
                    continuation.resume(returning: self.mapTrackingStatus(newStatus))
                }
            }
        } else {
            return .authorized
        }
        #else
        return .authorized
        #endif
    }
    
    private func checkTrackingStatus() -> PermissionStatus {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, macOS 11, *) {
            return mapTrackingStatus(ATTrackingManager.trackingAuthorizationStatus)
        }
        #endif
        return .authorized
    }
    
    // MARK: - Mapping Helpers
    
    private func mapAVStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
    
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
