import XCTest
@testable import PermissionKit

final class PermissionKitTests: XCTestCase {
    
    @MainActor
    func testPermissionManagerInitialization() throws {
        let manager = PermissionManager.shared
        XCTAssertNotNil(manager)
    }
    
    func testPermissionTypeKeys() throws {
        XCTAssertEqual(PermissionType.camera.usageDescriptionKey, "NSCameraUsageDescription")
        XCTAssertEqual(PermissionType.photoLibrary.usageDescriptionKey, "NSPhotoLibraryUsageDescription")
        XCTAssertEqual(PermissionType.microphone.usageDescriptionKey, "NSMicrophoneUsageDescription")
        XCTAssertEqual(PermissionType.tracking.usageDescriptionKey, "NSUserTrackingUsageDescription")
    }
}
