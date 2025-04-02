import SwiftUI
import CoreData

struct ChatView: View {
    @ObservedObject var chat: Chat
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var openAIModel: OpenAIModel
    
    @State private var isEditingChat = false
    @State private var isEditingConfig = false

    
    init(chat: Chat) {
        self.chat = chat
        _openAIModel = StateObject(wrappedValue: OpenAIModel(chat: chat))
    }
    
    var body: some View {
        VStack {
            MessageList(chat: chat)
            MessageField(chat: chat)
        }
        .environmentObject(openAIModel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: { isEditingChat = true} ) {
                    HStack(alignment: .center){
                        Text(chat.name ?? "Error")
                            .font(.headline)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(-2)
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 8, weight: .semibold, design: .default))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .padding(-2)
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditingConfig = true }) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $isEditingChat) {
            ChatEditView(chat: chat, isWaitingForResponse: $openAIModel.isWaitingForResponse)
        }
        .sheet(isPresented: $isEditingConfig) {
            ConfigEditView(config: chat.config!)
        }
    }
}



//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
