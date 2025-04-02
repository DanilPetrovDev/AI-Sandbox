import SwiftUI

struct NewConfigButton: View {
    
    let label: String
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingNewConfigSheet = false
    
    var body: some View {
        Button(action: {
            showingNewConfigSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text(label)
            }
            .bold()
        }
        .sheet(isPresented: $showingNewConfigSheet) {
            NewConfigSheetView()
        }
    }
}

struct DefaultConfigFormState: Equatable {
    var name: String = ""
    var temperature: Double = 1.3
    var maxTokens: Double = 512
    var presencePenalty: Double = 0.0
    var frequencyPenalty: Double = 0.0
    var topProbabilityMass: Double = 0.8
}

struct NewConfigSheetView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var showingDiscardChangesActionSheet: Bool = false
    
    @State private var currentState: DefaultConfigFormState = DefaultConfigFormState()
    private var initialState: DefaultConfigFormState = DefaultConfigFormState()
    
    var hasChanges: Bool {
        currentState != initialState
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Config Name", text: $currentState.name)
                }
                SliderSetting(name: "Temperature", explanation: "Creativity of the AI", range: 0...2, step: 0.1, value: $currentState.temperature)
                SliderSetting(name: "Max Tokens", explanation: "How many tokens (≈words) are allowed in the response", range: 100...2000, step: 10, value: $currentState.maxTokens)
                SliderSetting(name: "Presence Penalty", explanation: "How likely the AI is to use words that have not yet been included in the generated text", range: -2...2, step: 0.1, value: $currentState.presencePenalty)
                SliderSetting(name: "Frequency Penalty", explanation: "How often the AI repeats the same words or phrases within the generated text", range: -2...2, step: 0.1, value: $currentState.frequencyPenalty)
                SliderSetting(name: "Top Probability Mass", explanation: "-", range: 0...1, step: 0.1, value: $currentState.topProbabilityMass)
            }
            .navigationTitle("New Config")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasChanges {
                            showingDiscardChangesActionSheet = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        addConfig(viewContext: viewContext,
                                  name: currentState.name,
                                  temperature: currentState.temperature,
                                  maxTokens: Int16(currentState.maxTokens),
                                  presencePenalty: currentState.presencePenalty,
                                  frequencyPenalty: currentState.frequencyPenalty,
                                  topProbabilityMass: currentState.topProbabilityMass)
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    .disabled(currentState.name.isEmpty)
                }
            }
            .interactiveDismissDisabled(hasChanges)
            .confirmationDialog("", isPresented: $showingDiscardChangesActionSheet) {
                Button("Discard Changes", role: .destructive) { dismiss() }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}


//struct PlusLabelButton_Previews: PreviewProvider {
//    static var previews: some View {
//        PlusLabelButton()
//    }
//}
