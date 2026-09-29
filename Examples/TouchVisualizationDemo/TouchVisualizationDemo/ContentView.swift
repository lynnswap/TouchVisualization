// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import SwiftUI
import TouchVisualization

struct ContentView: View {
    @Bindable var visualizer: TouchVisualizer
    @State private var tapCount = 0
    @State private var progress = 0.5
    @State private var message = ""
    @State private var presentsSheet = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Show touches", isOn: $visualizer.isEnabled)
                        .accessibilityIdentifier("showsTouches")
                } footer: {
                    Text("Applies to the entire app. Your choice is saved between launches.")
                }

                Section("Appearance") {
                    ColorPicker(
                        "Color",
                        selection: Binding(
                            get: { Color(uiColor: visualizer.configuration.strokeColor) },
                            set: { color in
                                var configuration = visualizer.configuration
                                configuration.strokeColor = UIColor(color)
                                configuration.fillColor = UIColor(color.opacity(0.5))
                                visualizer.configuration = configuration
                            }
                        )
                    )
                    Stepper(
                        "Diameter: \(Int(visualizer.configuration.diameter)) pt",
                        value: $visualizer.configuration.diameter,
                        in: 16...96,
                        step: 4
                    )
                    .accessibilityIdentifier("diameter")
                    Stepper(
                        "Outline width: \(Int(visualizer.configuration.strokeWidth)) pt",
                        value: $visualizer.configuration.strokeWidth,
                        in: 0...8
                    )
                    .accessibilityIdentifier("strokeWidth")
                    Button("Reset appearance") {
                        visualizer.configuration = .init()
                    }
                }

                Section("Try the controls") {
                    Button {
                        tapCount += 1
                    } label: {
                        LabeledContent("Tap me", value: "\(tapCount)")
                    }
                    .accessibilityIdentifier("tapCounter")

                    Slider(value: $progress) {
                        Text("Slide")
                    }
                    .accessibilityIdentifier("slider")

                    TextField("Type something", text: $message)
                        .accessibilityIdentifier("textInput")

                    NavigationLink("Open another screen") {
                        ScrollView {
                            VStack(spacing: 24) {
                                Image(systemName: "hand.draw")
                                    .font(.system(size: 72))
                                    .foregroundStyle(.blue)
                                Text("Touches remain visible as you navigate.")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .navigationTitle("Another screen")
                    }

                    Button("Present a sheet") {
                        presentsSheet = true
                    }
                }

                Section("Try scrolling") {
                    ForEach(1...25, id: \.self) { row in
                        Text("Row \(row)")
                    }
                }
            }
            .navigationTitle("TouchVisualization")
            .sheet(isPresented: $presentsSheet) {
                NavigationStack {
                    Form {
                        Text("Touch visualization also works in presented screens.")
                        Button {
                            tapCount += 1
                        } label: {
                            LabeledContent("Tap me", value: "\(tapCount)")
                        }
                    }
                    .navigationTitle("Sheet")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { presentsSheet = false }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(visualizer: .shared)
}
