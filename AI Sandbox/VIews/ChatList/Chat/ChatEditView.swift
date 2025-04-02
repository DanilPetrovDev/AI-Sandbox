import SwiftUI

struct ChatEditView: View {
    
    @ObservedObject var chat: Chat
    @Binding var isWaitingForResponse: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var tempName: String = ""
    @State private var showingAlert = false
// TODO: Check if there are changes and only allow saving when there are. Check Apple's tutorials for how to make a good edit sheet
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chat Name")) {
                    TextField("Chat name", text: $tempName)
                }
                
                Button(role: .destructive) {
                    if let messageCount = chat.messages?.count, messageCount > 6 {
                        showingAlert = true
                    } else {
                        _deleteMessages()
                    }
                } label: {
                    Text("Delete All Messages")
                }
                .disabled(isWaitingForResponse)
                
            }
            .navigationTitle("Edit Chat")
            
            
            
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        chat.name = tempName
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        dismiss()
                    }
                }
            }
        }
        
        
        .onAppear {
            tempName = chat.name ?? ""
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Delete all messages?"),
                message: Text("This chat has multiple messages. Are you sure you want to delete them all permanently?"),
                primaryButton: .destructive(Text("Delete")) {
                    _deleteMessages()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func _deleteMessages() {
        withAnimation {
            deleteMessages(viewContext: viewContext, chat: chat)
        }
    }
}

