import SwiftUI
import CoreData

struct ChatRow: View {
    
    @ObservedObject var chat: Chat
    
    var name: String { chat.name ?? "Untitled" }
    var dateUpdated: String { formatDate(chat.dateUpdated ?? Date()) }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 4){
            Text(name)
                .bold()
                .lineLimit(1)
                .truncationMode(.tail)
            Text(dateUpdated)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        let preview1 = PersistenceController.preview1
        
        // Create new Chat object for preview1
        let newChat1 = Chat(context: preview1.container.viewContext)
        newChat1.name = "Untitled"
        newChat1.dateCreated = Date()

        // Create new Chat object for preview2
        let newChat2 = Chat(context: preview1.container.viewContext)
        newChat2.name = "School Exploration"
        newChat2.dateCreated = Date().addingTimeInterval(-3600)

        return Group {
            NavigationStack {
                List {
                    NavigationLink {
                        ChatView(chat: newChat1)
                    } label: {
                        ChatRow(chat: newChat1)
                    }
                    NavigationLink {
                        ChatView(chat: newChat2)
                    } label: {
                        ChatRow(chat: newChat2)
                    }
                }
            }
        }
    }
}

