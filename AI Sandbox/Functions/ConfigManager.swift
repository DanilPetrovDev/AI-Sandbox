import Foundation
import CoreData
import SwiftUI

class ConfigManager: ObservableObject {
    
    @Published var showingDeleteWarning: Bool = false
    @Published var configToDelete: Config? = nil

    func requestDelete(config: Config) {
        self.configToDelete = config
        self.showingDeleteWarning = true
    }
    
    func deleteConfigAlert(viewContext: NSManagedObjectContext, configToDelete: Config?) -> Alert {
        Alert(
            title: Text("Delete config \"\(configToDelete?.name ?? "")\"?"),
            message: Text("This will delete this config and all chats in it permanently"),
            primaryButton: .destructive(Text("Delete")) {
                if let configToDelete = configToDelete { self.deleteConfig(viewContext: viewContext, config: configToDelete) }},
            secondaryButton: .cancel()
        )
    }

    private func deleteConfig(viewContext: NSManagedObjectContext, config: Config) {
        viewContext.delete(config)
        saveContext(viewContext)
    }
}
