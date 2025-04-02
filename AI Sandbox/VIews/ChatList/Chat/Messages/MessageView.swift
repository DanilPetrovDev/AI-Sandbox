import SwiftUI
import CoreData

struct MessageView: View {
    
    var message: Message

    var isUser: Bool { message.role == "user" }
    var content: String { message.content ?? "Unwrap error" }
    @State private var loadState = false
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 30) }
            
            if !(content.isEmpty) {
                Text(content)
                    .foregroundColor(isUser ? .white : .primary)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(isUser ? .blue : Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .background(alignment: isUser ? .bottomTrailing : .bottomLeading) {
                        Image(isUser ? "outgoingTail" : "incomingTail")
                            .renderingMode(.template)
                            .foregroundStyle(isUser ? .blue : Color(uiColor: .secondarySystemBackground))
                    }
                    .offset(x: isUser ? loadState ? 0 : 130 : loadState ? 0 : -130)
                    .scaleEffect(loadState ? 1 : 0.1)
                    .animation(.spring(), value: loadState)
                    .onAppear {
                        loadState = true
                    }
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20))
                    .contextMenu(ContextMenu(menuItems: {
                        Button(action: {
                            UIPasteboard.general.string = content
                        }) {
                            Text("Copy")
                            Image(systemName: "doc.on.doc")
                        }
                    }))
            }
            
            if !isUser { Spacer(minLength: 30) }
        }
        .padding(.horizontal)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview1

        let newMessage1 = Message(context: persistenceController.container.viewContext)
        newMessage1.id = UUID()
        newMessage1.dateCreated = Date()
        newMessage1.role = "user"
        newMessage1.content = "Message 1"

        let newMessage2 = Message(context: persistenceController.container.viewContext)
        newMessage2.id = UUID()
        newMessage2.dateCreated = Date()
        newMessage2.role = "assistant"
        newMessage2.content = "Message 2"

        return Group {
            MessageView(message: newMessage1)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .previewDisplayName("User Message")

            MessageView(message: newMessage2)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .previewDisplayName("Assistant Message")
        }
    }
}

