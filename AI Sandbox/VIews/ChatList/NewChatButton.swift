import SwiftUI

struct NewChatButton: ToolbarContent {
    
    let label: String
    let action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button(action: action) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(label)
                }
                .bold()
            }
            Spacer()
        }
    }
}

//struct NewChatButton_Previews: PreviewProvider {
//    static var previews: some View {
//        NewChatButton()
//    }
//}
