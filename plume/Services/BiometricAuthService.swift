import SwiftUI
import LocalAuthentication
import Combine

class BiometricAuthService: ObservableObject {
    @Published var isUnlocked = false
    @Published var isEnabled = false
    
    private let context = LAContext()
    
    init() {
        // Check if biometrics are available
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Biometrics available
        }
        
        // Load saved preference
        isEnabled = UserDefaults.standard.bool(forKey: "appLockEnabled")
    }
    
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback to passcode
            return await authenticateWithPasscode()
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock Plume to access your journal"
            )
            
            await MainActor.run {
                isUnlocked = success
            }
            
            return success
        } catch {
            print("Authentication failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func authenticateWithPasscode() async -> Bool {
        let context = LAContext()
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock Plume to access your journal"
            )
            
            await MainActor.run {
                isUnlocked = success
            }
            
            return success
        } catch {
            print("Passcode authentication failed: \(error.localizedDescription)")
            return false
        }
    }
    
    func enableAppLock() {
        isEnabled = true
        UserDefaults.standard.set(true, forKey: "appLockEnabled")
    }
    
    func disableAppLock() {
        isEnabled = false
        isUnlocked = true
        UserDefaults.standard.set(false, forKey: "appLockEnabled")
    }
    
    func lock() {
        isUnlocked = false
    }
    
    var biometricType: String {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Passcode"
        }
        
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return "Biometric"
        }
    }
}
