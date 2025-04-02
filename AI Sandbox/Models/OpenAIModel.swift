import Foundation
import OpenAISwift
import CoreData
import Combine
import GPTEncoder
import SwiftUI

@MainActor
class OpenAIModel: ObservableObject {
    
    @ObservedObject var chat: Chat

    private let api = OpenAISwift(authToken: "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")
    let encoder = GPTEncoder()
    @Published var chatMessages = [ChatMessage]()
    @Published var isWaitingForResponse = false
    @Published var messageSentFlag = CurrentValueSubject<Bool, Never>(false)
    var maxTokens = 3100
    
    init(chat: Chat) {
        self.chat = chat
    }
   
    func populateMessages(viewContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chat == %@", chat)

        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Message.dateCreated, ascending: false)]
        var totalTokens = 0

        do {
            let fetchedMessages = try viewContext.fetch(fetchRequest)
            
            self.chatMessages.removeAll()
            
            for message in fetchedMessages {
                guard let role = ChatRole(rawValue: message.role ?? ""), let content = message.content else {
                    continue
                }
                let tokens = encoder.encode(text: content).count
                
                if totalTokens + tokens > maxTokens {
                    print("Rejected a message with \(tokens) tokens. Breaking")
                    break
                }
                totalTokens += tokens
                
                let chatMessage = ChatMessage(role: role, content: content)
                self.chatMessages.append(chatMessage)
            }
            self.chatMessages.reverse()
        } catch {
            print("Failed to fetch messages: \(error)")
        }
        

        print(" - Retrieved", self.chatMessages.count, "messages: \(totalTokens) tokens - ")

         for (index, chatMessage) in self.chatMessages.enumerated() {
             print("Message #\(index + 1):\nRole: \(chatMessage.role.rawValue)\nContent: \(chatMessage.content)\n---")
         }
    }

    
    func messageSent() {
        messageSentFlag.send(true)
    }

    func sendMessage(viewContext: NSManagedObjectContext, config: Config, message: String) async throws -> String {
        populateMessages(viewContext: viewContext)
        isWaitingForResponse = true
        
        do {
            print(chatMessages)
            print(config.temperature)
            print(config.topProbabilityMass)
            print(config.maxTokens)
            print(config.presencePenalty)
            print(config.frequencyPenalty)
            let result = try await api.sendChat(with: chatMessages,
                                                model: .chat(.chatgpt),
                                                temperature: config.temperature,
                                                topProbabilityMass: config.topProbabilityMass,
                                                maxTokens: Int(config.maxTokens),
                                                presencePenalty: config.presencePenalty,
                                                frequencyPenalty: config.frequencyPenalty
            )
            let assistantMessageContent = result.choices?.first?.message.content ?? "Error unwrapping the output"
            
            isWaitingForResponse = false
            return assistantMessageContent
        } catch {
            isWaitingForResponse = false
            return error.localizedDescription
        }
    }

    func clearMessages() {
        chatMessages = [ChatMessage]()
    }
}
