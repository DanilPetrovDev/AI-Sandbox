import SwiftUI

struct ConfigList: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var configManager = ConfigManager()
    
    @FetchRequest(entity: Config.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Config.isFeatured, ascending: false), NSSortDescriptor(keyPath: \Config.dateUpdated, ascending: false)])
    private var configs: FetchedResults<Config>
    
    @State private var path = NavigationPath()
    var gridItems: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(configs) { config in
                    NavigationLink(value: config) {
                        ConfigRow(config: config)
                    }
                }
                .onDelete(perform: deleteSwipedConfig)
            }
            .navigationTitle("AI Configurations")
            .navigationDestination(for: Config.self) { config in
                ChatList(config: config)
            }
            .alert(isPresented: $configManager.showingDeleteWarning) {
                configManager.deleteConfigAlert(viewContext: viewContext, configToDelete: configManager.configToDelete)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        NewConfigButton(label: "New Config")
                        Spacer()
                    }
                }
            }
            .environmentObject(configManager)
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
    
    func deleteSwipedConfig(offsets: IndexSet) {
        for index in offsets {
            let config = configs[index]
            configManager.requestDelete(config: config)
        }
    }
}
