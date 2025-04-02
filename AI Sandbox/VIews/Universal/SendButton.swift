import SwiftUI

struct SendButton: View {
    
    @Binding var input: String
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(!input.isEmpty ? .blue : .secondary)
                .font(.body.weight(.semibold))
                .animation(.spring(), value: input)
        }
        .disabled(input.isEmpty)
    }
}

//struct SendButton_Previews: PreviewProvider {
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
