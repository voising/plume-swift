import SwiftUI

struct ZenModeView: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    
    @State private var fontSize: Double = 18
    @State private var showControls = false
    
    var body: some View {
        ZStack {
            AppColors.Background.mainLight // Should adapt to theme
                .ignoresSafeArea()
            
            VStack {
                // Top Bar (Hidden by default)
                if showControls {
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Font controls
                        HStack {
                            Text("A").font(.caption)
                            Slider(value: $fontSize, in: 12...32)
                                .frame(width: 100)
                            Text("A").font(.title3)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                
                Spacer()
                
                TextEditor(text: $text)
                    .font(.system(size: fontSize, design: .serif))
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: 700)
                    .padding()
                
                Spacer()
                
                // Bottom Bar (Hidden by default)
                if showControls {
                    HStack {
                        Text("\(text.split { $0.isWhitespace }.count) words")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onHover { hovering in
            withAnimation {
                showControls = hovering
            }
        }
        #if os(iOS)
        .onTapGesture {
            withAnimation {
                showControls.toggle()
            }
        }
        .statusBar(hidden: !showControls)
        #endif
    }
}

#Preview {
    ZenModeView(text: .constant("This is a sample text for Zen Mode."), isPresented: .constant(true))
}
