import SwiftUI

struct EditStringSection: View {
    
    var sectionName: String
    @Binding var string: String
    
    var body: some View {
        Section {
            NavigationLink(destination: EditStringSectionView( sectionName: sectionName, string: $string)) {
                HStack(alignment: .center) {
                    Text("Name")
                    
                    Spacer()
                    
                    Text("\(string)")
                        .foregroundColor(.secondary)
                }
                }
        }
    }
}

struct EditStringSectionView: View {
    
    var sectionName: String
    @Binding var string: String
    
    var body: some View {
        Form {
            Section {
                TextField(sectionName, text: $string)
            }
        }
        .navigationTitle(sectionName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
