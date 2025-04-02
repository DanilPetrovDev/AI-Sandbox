import SwiftUI


struct MessageField: View {
    
    @ObservedObject var chat: Chat

    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var openAIModel: OpenAIModel
    @State private var input = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            TextField("Message", text: $input, axis: .vertical)
                .padding(.leading, 10)
                .padding(.vertical, 4)
            
            if !openAIModel.isWaitingForResponse {
                SendButton(input: $input, action: sendButtonAction)
            } else {
                ProgressView()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
        .padding(3)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(.tertiary, lineWidth: 1)
            .opacity(0.7)
        )
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
    
    func sendButtonAction() {
        if !input.isEmpty {
            Task {
                do {
                    saveUserMessage(viewContext: viewContext, chat: chat, content: input)
                    let messageCopy = input
                    input = ""
                    openAIModel.messageSent()
                    
                    let assistantMessage = try await openAIModel.sendMessage(viewContext: viewContext, config: chat.config!, message: messageCopy)
                    saveAssistantMessage(viewContext: viewContext, chat: chat, content: assistantMessage)
                    
                    chat.dateUpdated = Date()
                    chat.config?.dateUpdated = Date()
                    openAIModel.messageSent()
                } catch {
                    print("sendButton Error:", error.localizedDescription)
                }
            }
        }
    }
}


//struct MessageField_Previews: PreviewProvider {
//    static var previews: some View {
//        @StateObject var openAIModel = OpenAIModel()
//
//        VStack {
//            Color.gray
//            MessageField()
//                .environment(\.managedObjectContext, PersistenceController.preview1.container.viewContext)
//                .environmentObject(openAIModel)
//            Color.gray
//        }
//    }
//}
