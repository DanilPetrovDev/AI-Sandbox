import SwiftUI

struct ConfigEditView: View {
    
    @ObservedObject var config: Config
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var showingDeleteWarning = false
    @State private var configToDelete: Config? = nil
    @State private var showingDiscardChangesActionSheet: Bool = false
    
    @State private var currentState: ConfigSettingsForm
    private let initialState: ConfigSettingsForm
    
    var hasChanges: Bool {
        currentState != initialState
    }

    init(config: Config) {
        self.config = config
        _currentState = State(initialValue: ConfigSettingsForm(config: config))
        initialState = ConfigSettingsForm(config: config)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chat Name")) {
                    TextField("Chat Name", text: $currentState.name)
                }
                .disabled(config.isFeatured)
                .foregroundColor(config.isFeatured ? .secondary : .primary)
                Section {
                    NavigationLink {
                        Form {
                            SliderSetting(name: "Temperature", explanation: "Creativity of the AI", range: 0...2, step: 0.1, value: $currentState.temperature)
                                .disabled(config.isFeatured)
                            SliderSetting(name: "Max Tokens", explanation: "How many tokens (≈words) are allowed in the response", range: 100...2000, step: 10, value: $currentState.maxTokens)
                            SliderSetting(name: "Presence Penalty", explanation: "How likely the AI is to use words that have not yet been included in the generated text", range: -2...2, step: 0.1, value: $currentState.presencePenalty)
                                .disabled(config.isFeatured)
                            SliderSetting(name: "Frequency Penalty", explanation: "How often the AI repeats the same words or phrases within the generated text", range: -2...2, step: 0.1, value: $currentState.frequencyPenalty)
                                .disabled(config.isFeatured)
                            SliderSetting(name: "Top Probability Mass", explanation: "-", range: 0...1, step: 0.1, value: $currentState.topProbabilityMass)
                                .disabled(config.isFeatured)
                            
                            Button {
                                currentState.temperature = DefaultConfigValues.temperature
                                currentState.topProbabilityMass = DefaultConfigValues.topProbabilityMass
                                currentState.maxTokens = Double(DefaultConfigValues.maxTokens)
                                currentState.presencePenalty = DefaultConfigValues.presencePenalty
                                currentState.frequencyPenalty = DefaultConfigValues.frequencyPenalty
                            } label: {
                                Text("Set to Defaults")
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button {
                                    saveConfig()
                                    dismiss()
                                } label: {
                                    Text("Save")
                                }
                                .disabled(!hasChanges)
                            }
                        }
                    } label: {
                        Text("AI settings")
                    }
                }
                
                // TODO: Add delete all chats button and delete config button
//                Button(role: .destructive) {
//                    if let chatCount = config.chats?.count, chatCount > 6 {
//                        configToDelete = config
//                        showingDeleteWarning = true
//                    } else {
//                        viewContext.delete(config)
//                        do {
//                            try viewContext.save()
//                        } catch {
//                            let nsError = error as NSError
//                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                        }
//                    }
//                } label: {
//                    Text("Delete Config")
//                }
            }
            .navigationTitle("\(config.name ?? "Config") Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if hasChanges {
                            showingDiscardChangesActionSheet = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveConfig()
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(!hasChanges)
                }
            }
            .interactiveDismissDisabled(hasChanges)
            .confirmationDialog("", isPresented: $showingDiscardChangesActionSheet) {
                Button("Discard Changes", role: .destructive) { dismiss() }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func saveConfig() {
        config.name = currentState.name
        config.temperature = currentState.temperature
        config.topProbabilityMass = currentState.topProbabilityMass
        config.maxTokens = Int16(currentState.maxTokens)
        config.presencePenalty = currentState.presencePenalty
        config.frequencyPenalty = currentState.frequencyPenalty
        
        saveContext(viewContext)
    }
}

struct ConfigSettingsForm: Equatable {
    
    var config: Config
    var name: String
    var temperature: Double
    var maxTokens: Double
    var presencePenalty: Double
    var frequencyPenalty: Double
    var topProbabilityMass: Double
    
    init(config: Config) {
        self.config = config
        name = config.name ?? ""
        temperature = config.temperature
        maxTokens = Double(config.maxTokens)
        presencePenalty = config.presencePenalty
        frequencyPenalty = config.frequencyPenalty
        topProbabilityMass = config.topProbabilityMass
    }
}

struct SliderSetting: View {
    var name: String
    var explanation: String
    var range: ClosedRange<Double>
    var step: Double
    @Binding var value: Double
    @State var originalValue: Double
    
    init(name: String, explanation: String, range: ClosedRange<Double>, step: Double, value: Binding<Double>) {
        self.name = name
        self.explanation = explanation
        self.range = range
        self.step = step
        self._value = value
        self._originalValue = State(initialValue: value.wrappedValue)
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack (alignment: .center) {
                    Spacer()
                    Text(String(format: "%.1f", originalValue))
                    if (originalValue != value) {
                        Image(systemName: "arrow.right")
                            .bold()
                        Text(String(format: "%.1f", value))
                            .bold()
                    }
                    Spacer()
                }
                HStack {
                    Button(action: {
                        if value > range.lowerBound {
                            value -= step
                        }
                    }) {
                        Image(systemName: "minus")
                            .grayscale(1.0)
                    }
                    Slider(value: $value, in: range, step: step)
                    Button(action: {
                        if value < range.upperBound {
                            value += step
                        }
                    }) {
                        Image(systemName: "plus")
                            .grayscale(1.0)
                    }
                }
                .padding(0)
            }
            .padding(5)
            .onAppear {
                originalValue = value
            }
        } header: {
            Text(name)
        } footer: {
            Text(explanation)
        }
    }
}
