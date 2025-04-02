import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview1: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()
    
    static var preview2: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AI_Sandbox")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        

        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            print("Core Data store URL:", storeDescription.url ?? "No URL")
        })
        
        
        if !hasFeaturedConfig(named: "Assistant", in: context) {
            insertFeaturedConfig(named: "Assistant", settings: ["temperature": 1.0, "maxTokens": 500, "topProbabilityMass": 1.0], into: context)
        }
        
        if !hasFeaturedConfig(named: "Creative", in: context) {
            insertFeaturedConfig(named: "Creative", settings: ["temperature": 1.3, "maxTokens": 800, "topProbabilityMass": 0.8], into: context)
        }
        
//        if !hasFeaturedConfig(named: "Coder", in: context) {
//            insertFeaturedConfig(named: "Coder", settings: ["temperature": 0.0, "maxTokens": 800, "topProbabilityMass": 0.8], into: context)
//        }
    }

    
    func hasFeaturedConfig(named name: String, in context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<Config> = Config.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND isFeatured == TRUE", name)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to fetch Config from CoreData:", error)
            return false
        }
    }

    func insertFeaturedConfig(named name: String, settings: [String: Any], into context: NSManagedObjectContext) {
        let config = Config(context: context)
        config.id = UUID()
        config.name = name
        config.isFeatured = true
        config.dateCreated = Date()
        config.dateUpdated = Date()
        for (key, value) in settings {
            config.setValue(value, forKey: key)
        }
        saveContext()
    }


//    func hasInitialData(in context: NSManagedObjectContext) -> Bool {
//        let fetchRequest: NSFetchRequest<Config> = Config.fetchRequest()
//        let count = try? context.count(for: fetchRequest)
//        return (count ?? 0) > 0
//    }
//
//    func insertInitialData(into context: NSManagedObjectContext) {
//        let assistantConfig = Config(context: context)
//        assistantConfig.id = UUID()
//        assistantConfig.name = "Assistant"
//        assistantConfig.dateCreated = Date()
//        assistantConfig.dateUpdated = Date()
//
//        let firstChat = Chat(context: context)
//        firstChat.id = UUID()
//        firstChat.name = "First Chat"
//        firstChat.dateCreated = Date()
//        firstChat.dateUpdated = Date()
//        firstChat.config = assistantConfig
//
////        let creativeConfig = Config(context: context)
////        creativeConfig.id = UUID()
////        creativeConfig.name = "Creative"
////        creativeConfig.dateCreated = Date()
////        creativeConfig.dateUpdated = Date()
//
//        saveContext()
//    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
