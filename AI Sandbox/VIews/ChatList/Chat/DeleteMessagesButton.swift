import SwiftUI
import CoreData

struct DeleteMessagesButton: View {
    @ObservedObject var chat: Chat

    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var openAIModel: OpenAIModel
    @State private var showingAlert = false

    var body: some View {
        Button(action: {
            if let messageCount = chat.messages?.count, messageCount > 6 {
                showingAlert = true
            } else {
                _deleteMessages()
            }
        }) {
            Image(systemName: "trash")
                .foregroundColor(!openAIModel.isWaitingForResponse ? .red : .gray)
                .animation(.easeInOut, value: openAIModel.isWaitingForResponse)
        }
        .disabled(openAIModel.isWaitingForResponse)
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
