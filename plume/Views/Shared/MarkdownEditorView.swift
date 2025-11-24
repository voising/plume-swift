import SwiftUI

struct MarkdownEditorView: View {
    @Binding var text: String
    @State private var isEditing = false
    @State private var showPreview = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Toolbar
            HStack {
                // Markdown buttons
                if isEditing || isFocused {
                    Group {
                        Button(action: { insertMarkdown("**", "**") }) {
                            Image(systemName: "bold")
                        }
                        
                        Button(action: { insertMarkdown("*", "*") }) {
                            Image(systemName: "italic")
                        }
                        
                        Button(action: { insertMarkdown("- ", "") }) {
                            Image(systemName: "list.bullet")
                        }
                        
                        Button(action: { insertMarkdown("# ", "") }) {
                            Image(systemName: "textformat.size")
                        }
                        
                        Button(action: { insertMarkdown("[](", ")") }) {
                            Image(systemName: "link")
                        }
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
                
                Spacer()
                
                // Preview toggle
                Toggle(isOn: $showPreview) {
                    Label("Preview", systemImage: showPreview ? "eye.fill" : "eye")
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .font(.caption)
            }
            
            // Editor or Preview
            if showPreview {
                ScrollView {
                    Text(renderMarkdown(text))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 200)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            } else {
                TextEditor(text: $text)
                    .frame(minHeight: 200)
                    .font(.body)
                    .focused($isFocused)
                    .onChange(of: isFocused) { _, focused in
                        isEditing = focused
                    }
            }
        }
    }
    
    private func insertMarkdown(_ prefix: String, _ suffix: String) {
        text += prefix + suffix
    }
    
    // Simple markdown rendering using AttributedString
    private func renderMarkdown(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown)
        } catch {
            return AttributedString(markdown)
        }
    }
}

#Preview {
    MarkdownEditorView(text: .constant("# Hello\n\nThis is **bold** and *italic* text.\n\n- Item 1\n- Item 2"))
        .padding()
}
