import SwiftUI

struct ConfigRow: View {
    
    @ObservedObject var config: Config
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var configManager: ConfigManager

    var name: String { config.name ?? "Untitled" }
    var dateUpdated: String { formatDate(config.dateUpdated ?? Date()) }
    
    @State private var isEditingConfig = false
    
    var body: some View {
        HStack(alignment: .center) {
            VStack (alignment: .leading, spacing: 4){
                Text(name)
                    .bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(config.isFeatured ? "Default Config" : dateUpdated)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            
            Spacer()
            
            Text("\(config.chats?.count ?? 0)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $isEditingConfig) {
            ConfigEditView(config: config)
        }
        .alert(isPresented: $configManager.showingDeleteWarning) {
            configManager.deleteConfigAlert(viewContext: viewContext, configToDelete: configManager.configToDelete)
        }
        .contextMenu(ContextMenu(menuItems: {
            Button {
                addConfig(viewContext: viewContext, name: "\(config.name ?? "Config") Copy",
                                       temperature: config.temperature,
                                       maxTokens: config.maxTokens,
                                       presencePenalty: config.presencePenalty,
                                       frequencyPenalty: config.frequencyPenalty,
                                       topProbabilityMass: config.topProbabilityMass)
            } label: {
                Text("Duplicate")
                Image(systemName: "doc.on.doc")
            }
            
            Button {
                isEditingConfig = true
            } label: {
                Text("Show Config Info")
                Image(systemName: "info.circle")
            }
            
            if !config.isFeatured {
                Button(role: .destructive) {
                    configManager.requestDelete(config: config)
                } label: {
                    Text("Delete Config")
                    Image(systemName: "trash")
                }
            }
        }))
    }
}

//struct ConfigRow_Previews: PreviewProvider {
//    static var previews: some View {
//        let preview1 = PersistenceController.preview1
//
//        // Create new Chat object for preview1
//        let newConfig1 = Chat(context: preview1.container.viewContext)
//        newConfig1.name = "Untitled"
//        newConfig1.dateCreated = Date()
//        newConfig1.dateUpdated = Date()
//
//        // Create new Chat object for preview2
//        let newConfig2 = Chat(context: preview1.container.viewContext)
//        newConfig2.name = "School Exploration"
//        newConfig2.dateCreated = Date().addingTimeInterval(-3600)
//        newConfig2.dateUpdated = Date().addingTimeInterval(-3600)
//
//
//        return Group {
//            NavigationStack {
//                List {
//                    NavigationLink {
//                        ChatView(chat: newChat1)
//                    } label: {
//                        ConfigRow(chat: newChat1)
//                    }
//                    NavigationLink {
//                        ChatView(chat: newChat2)
//                    } label: {
//                        ConfigRow(chat: newChat2)
//                    }
//                }
//            }
//        }
//    }
//}
