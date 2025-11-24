import SwiftUI

struct BiometricLockScreen: View {
    @EnvironmentObject var authService: BiometricAuthService
    @State private var isAuthenticating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon/Logo
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(AppColors.primary)
                
                VStack(spacing: 12) {
                    Text("Plume")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Your journal is locked")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Unlock Button
                Button(action: authenticate) {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: authService.biometricType == "Face ID" ? "faceid" : "touchid")
                            Text("Unlock with \(authService.biometricType)")
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(isAuthenticating)
                
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Auto-trigger authentication on appear
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                await authenticate()
            }
        }
    }
    
    private func authenticate() {
        Task {
            isAuthenticating = true
            showError = false
            
            let success = await authService.authenticate()
            
            await MainActor.run {
                isAuthenticating = false
                
                if !success {
                    showError = true
                    errorMessage = "Authentication failed. Please try again."
                }
            }
        }
    }
}

#Preview {
    BiometricLockScreen()
        .environmentObject(BiometricAuthService())
}
