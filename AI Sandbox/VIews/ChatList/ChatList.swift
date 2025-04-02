import SwiftUI

struct ChatList: View {
    @ObservedObject var config: Config
    @FetchRequest private var chats: FetchedResults<Chat>
    
    @Environment(\.managedObjectContext) private var viewContext

    init(config: Config) {
        self.config = config
        self._chats = FetchRequest(
            entity: Chat.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Chat.dateUpdated, ascending: false)],
            predicate: NSPredicate(format: "config == %@", config)
        )
    }
    
    @State private var showingDeleteWarning = false
    @State private var chatToDelete: Chat? = nil
    @State private var isEditingConfig = false
    
    var body: some View {
        List {
            ForEach(chats) { chat in
                NavigationLink(value: chat) {
                    ChatRow(chat: chat)
                }
            }
            .onDelete(perform: deleteChat)
        }
        .navigationTitle(config.name ?? "Error: config name")
        .navigationDestination(for: Chat.self) { chat in
            ChatView(chat: chat)
        }
        .alert(isPresented: $showingDeleteWarning) {
            Alert(title: Text("Warning"), message: Text("This chat contains multiple messages. Are you sure you want to delete it permanently?"), primaryButton: .destructive(Text("Delete")) {
                if let chatToDelete = self.chatToDelete {
                    viewContext.delete(chatToDelete)
                    saveContext()
                }
            }, secondaryButton: .cancel())
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditingConfig = true }) {
                    Image(systemName: "gearshape")
                }
            }
            
            NewChatButton(label: "New Chat", action: { addChat(viewContext: viewContext, config: config) })
        }
        .sheet(isPresented: $isEditingConfig) {
            ConfigEditView(config: config)
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteChat(offsets: IndexSet) {
        for index in offsets {
            let chat = chats[index]
            if let messageCount = chat.messages?.count, messageCount > 6 {
                chatToDelete = chat
                showingDeleteWarning = true
            } else {
                viewContext.delete(chat)
                saveContext()
            }
        }
    }
}
