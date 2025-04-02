import SwiftUI
import CoreData

struct PlusButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            Image(systemName: "plus")
        }
    }
}
