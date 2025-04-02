import SwiftUI
import CoreData

struct CounterToolbar: ToolbarContent {
    let label: String
    let count: Int
    let onAdd: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            
            Text("\(count) \(label.capitalized)")
                .font(.footnote)
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus")
            }
        }
    }
}

