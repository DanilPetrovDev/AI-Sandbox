import SwiftUI

extension AnyTransition {
    static var slideFromRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale),
            removal: .scale.combined(with: .opacity)
        )
    }
    
    static var slideFromLeft: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity).combined(with: .scale),
            removal: .scale.combined(with: .opacity)
        )
    }
}

struct MessageList: View {
    @ObservedObject var chat: Chat
    @FetchRequest private var messages: FetchedResults<Message>
    
    @EnvironmentObject var openAIModel: OpenAIModel

    init(chat: Chat) {
        self.chat = chat
        self._messages = FetchRequest(
            entity: Message.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Message.dateCreated, ascending: true)],
            predicate: NSPredicate(format: "chat == %@", chat)
        )
    }

    var body: some View {
        ZStack {
            if messages.isEmpty {
                BackgroundLogo()
                    .transition(.opacity)
                    .animation(.easeInOut, value: chat.messages?.count)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        Spacer(minLength: 10)
                        LazyVStack(spacing: 16) {
                            
                            
                            ForEach(messages) { message in
                                MessageView(message: message)
                            }
                            
                            Color.clear.frame(height: 1).id("bottomOfTheChat")
                        }
                        .onReceive(openAIModel.messageSentFlag) { _ in
                            withAnimation {
                                proxy.scrollTo("bottomOfTheChat")
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
    }
}

//struct MessageList_Previews: PreviewProvider {
//    static var previews: some View {
//        @StateObject var openAIModel = OpenAIModel()
//
//        MessageList()
//            .environment(\.managedObjectContext, PersistenceController.preview2.container.viewContext)
//            .environmentObject(openAIModel)
//    }
//}

