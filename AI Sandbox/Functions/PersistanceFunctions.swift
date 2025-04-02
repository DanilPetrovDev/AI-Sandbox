import Foundation
import CoreData
import SwiftUI

func saveContext(_ viewContext: NSManagedObjectContext) -> Void {
    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}

func deleteMessages(viewContext: NSManagedObjectContext, chat: Chat) -> Void {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Message.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "chat == %@", chat)

    do {
        if let fetchedMessages = try viewContext.fetch(fetchRequest) as? [Message] {
            for message in fetchedMessages {
                viewContext.delete(message)
            }
            try viewContext.save()
        }
    } catch let error as NSError {
        print("Error deleting messages for chat: \(error), \(error.userInfo)")
    }
}

func saveUserMessage(viewContext: NSManagedObjectContext, chat: Chat, content: String) {
    let message = Message(context: viewContext)
    message.chat = chat
    message.id = UUID()
    message.dateCreated = Date()
    message.role = "user"
    message.content = content

    print("\n User: \(content)")
    saveContext(viewContext)
}

func saveAssistantMessage(viewContext: NSManagedObjectContext, chat: Chat, content: String) {
    let message = Message(context: viewContext)
    message.chat = chat
    message.id = UUID()
    message.dateCreated = Date()
    message.role = "assistant"
    message.content = content

    print("Assistant: \(content)")
    
    saveContext(viewContext)
}

func addChat(viewContext: NSManagedObjectContext, config: Config) -> Chat {
    let newChat = Chat(context: viewContext)
    newChat.id = UUID()
    newChat.dateCreated = Date()
    newChat.dateUpdated = Date()
    newChat.config = config

    let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH %@ AND config == %@", "Chat", config)

    do {
        let untitledChats = try viewContext.fetch(fetchRequest)
        let untitledCount = untitledChats.count
        
        newChat.name = "Chat \(untitledCount + 1)"
    } catch {
        print("Failed to fetch untitled chats: \(error)")
        newChat.name = "Chat"
    }
    
    saveContext(viewContext)
    return newChat
}



func addDefaultConfig(viewContext: NSManagedObjectContext) {
    let newConfig = Config(context: viewContext)
    newConfig.id = UUID()
    newConfig.dateCreated = Date()
    newConfig.dateUpdated = Date()
    
    let fetchRequest: NSFetchRequest<Config> = Config.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH %@", "Config")

    do {
        let untitledConfigs = try viewContext.fetch(fetchRequest)
        let untitledCount = untitledConfigs.count
        
        newConfig.name = "Config \(untitledCount + 1)"
    } catch {
        print("Failed to fetch untitled chats: \(error)")
        newConfig.name = "Config"
    }
    
    saveContext(viewContext)
//    return newConfig
}

func addConfig(viewContext: NSManagedObjectContext, name: String, temperature: Double, maxTokens: Int16, presencePenalty: Double, frequencyPenalty: Double, topProbabilityMass: Double) {
    let newConfig = Config(context: viewContext)
    newConfig.id = UUID()
    newConfig.dateCreated = Date()
    newConfig.dateUpdated = Date()
    newConfig.name = name
    newConfig.temperature = temperature
    newConfig.maxTokens = maxTokens
    newConfig.presencePenalty = presencePenalty
    newConfig.frequencyPenalty = frequencyPenalty
    newConfig.topProbabilityMass = topProbabilityMass
    
    saveContext(viewContext)
}

func deleteConfig(viewContext: NSManagedObjectContext, config: Config) {
    viewContext.delete(config)
    saveContext(viewContext)
}
