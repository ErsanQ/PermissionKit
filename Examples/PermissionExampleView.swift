import SwiftUI
import PermissionKit

struct PermissionExampleView: View {
    @State private var showCameraPermission = false
    @State private var showPhotoPermission = false
    @State private var showNotificationPermission = false
    @State private var showMicrophonePermission = false
    @State private var showTrackingPermission = false
    
    @State private var cameraStatus: PermissionStatus = .notDetermined
    @State private var photoStatus: PermissionStatus = .notDetermined
    @State private var notificationStatus: PermissionStatus = .notDetermined
    @State private var microphoneStatus: PermissionStatus = .notDetermined
    @State private var trackingStatus: PermissionStatus = .notDetermined

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Device Handlers")) {
                    PermissionRow(title: "Camera", status: $cameraStatus, action: { showCameraPermission = true })
                    PermissionRow(title: "Microphone", status: $microphoneStatus, action: { showMicrophonePermission = true })
                    PermissionRow(title: "Photo Library", status: $photoStatus, action: { showPhotoPermission = true })
                }
                
                Section(header: Text("Privacy & System")) {
                    PermissionRow(title: "Notifications", status: $notificationStatus, action: { showNotificationPermission = true })
                    PermissionRow(title: "Tracking", status: $trackingStatus, action: { showTrackingPermission = true })
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("PermissionKit")
            .onAppear {
                refreshStatuses()
            }
            // Using the SwiftUI extension from PermissionKit
            .requestPermission(for: .camera, isPresented: $showCameraPermission) { status in
                cameraStatus = status
            }
            .requestPermission(for: .microphone, isPresented: $showMicrophonePermission) { status in
                microphoneStatus = status
            }
            .requestPermission(for: .photoLibrary, isPresented: $showPhotoPermission) { status in
                photoStatus = status
            }
            .requestPermission(for: .notifications, isPresented: $showNotificationPermission) { status in
                notificationStatus = status
            }
            .requestPermission(for: .tracking, isPresented: $showTrackingPermission) { status in
                trackingStatus = status
            }
        }
    }
    
    private func refreshStatuses() {
        Task {
            cameraStatus = await PermissionManager.shared.status(for: .camera)
            microphoneStatus = await PermissionManager.shared.status(for: .microphone)
            photoStatus = await PermissionManager.shared.status(for: .photoLibrary)
            notificationStatus = await PermissionManager.shared.status(for: .notifications)
            trackingStatus = await PermissionManager.shared.status(for: .tracking)
        }
    }
}

struct PermissionRow: View {
    let title: String
    @Binding var status: PermissionStatus
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
            Spacer()
            Button(action: action) {
                Text("Request")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .disabled(status == .authorized)
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch status {
        case .authorized: return .green
        case .denied, .restricted: return .red
        case .limited: return .orange
        case .notDetermined: return .secondary
        }
    }
}

#Preview {
    PermissionExampleView()
}
