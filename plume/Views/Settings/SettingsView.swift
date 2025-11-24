import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var authService: BiometricAuthService
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Dark Mode", isOn: $isDarkMode)
            }
            
            Section("Security") {
                Toggle("App Lock", isOn: Binding(
                    get: { authService.isEnabled },
                    set: { enabled in
                        if enabled {
                            authService.enableAppLock()
                        } else {
                            authService.disableAppLock()
                        }
                    }
                ))
                
                if authService.isEnabled {
                    HStack {
                        Image(systemName: authService.biometricType == "Face ID" ? "faceid" : "touchid")
                        Text("Unlock with \(authService.biometricType)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Text("Protect your journal with \(authService.biometricType) or passcode.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("AI Assistance") {
                Picker("Provider", selection: $aiService.currentProvider) {
                    ForEach(AIProviderType.allCases) { provider in
                        Text(provider.rawValue.capitalized).tag(provider)
                    }
                }
                
                SecureField("API Key", text: $aiService.apiKey)
                
                Text("Your API key is stored locally and never sent to our servers.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("Data") {
                Button("Export Data (JSON)") {
                    // Placeholder for export
                }
                
                Button("Delete All Data", role: .destructive) {
                    // Placeholder for delete
                }
            }
            
            Section("About") {
                Text("Plume v1.0.0")
                Text("The calmest way to capture every day.")
                    .font(.caption)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AIService())
}
