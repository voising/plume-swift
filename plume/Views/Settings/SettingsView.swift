import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var aiService: AIService
    @EnvironmentObject private var authService: BiometricAuthService
    @EnvironmentObject private var dataService: DataService
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    @State private var showDeleteConfirmation = false
    
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
                    if let url = dataService.exportData() {
                        exportURL = url
                        showShareSheet = true
                    }
                }
                
                Button("Delete All Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Delete All Data?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataService.deleteAllData()
                }
            } message: {
                Text("This action cannot be undone. All your entries and todos will be permanently deleted.")
            }
            
            Section("About") {
                Text("Plume v1.0.0")
                Text("The calmest way to capture every day.")
                    .font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.Background.mainLight)
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AIService())
        .environmentObject(BiometricAuthService())
        // Mock DataService for preview if needed, or just rely on environment injection in app
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
