import SwiftUI

public extension View {
    
    /// A view modifier that requests a permission when a binding is set to true.
    /// - Parameters:
    ///   - type: The type of permission to request.
    ///   - isPresented: A binding to a Boolean value that determines whether to present the request.
    ///   - onCompletion: An optional closure to execute when the request completes.
    /// - Returns: A view that triggers a permission request.
    func requestPermission(
        for type: PermissionType,
        isPresented: Binding<Bool>,
        onCompletion: ((PermissionStatus) -> Void)? = nil
    ) -> some View {
        self.modifier(PermissionRequestModifier(type: type, isPresented: isPresented, onCompletion: onCompletion))
    }
}

private struct PermissionRequestModifier: ViewModifier {
    let type: PermissionType
    @Binding var isPresented: Bool
    let onCompletion: ((PermissionStatus) -> Void)?
    
    @StateObject private var manager = PermissionManager.shared
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    Task {
                        let status = await manager.request(for: type)
                        isPresented = false
                        onCompletion?(status)
                    }
                }
            }
    }
}
