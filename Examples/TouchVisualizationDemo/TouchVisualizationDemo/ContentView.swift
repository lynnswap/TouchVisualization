// Copyright (c) 2026 Kazuki Nakashima
// SPDX-License-Identifier: MIT

import SwiftUI
import TouchVisualization

struct ContentView: View {
    @Binding var showsTouches: Bool
    @State private var tapCount = 0
    @State private var progress = 0.5
    @State private var message = ""
    @State private var presentsSheet = false
    @State private var configuration = TouchVisualizer.shared.configuration

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Show touches", isOn: $showsTouches)
                        .accessibilityIdentifier("showsTouches")
                        .onChange(of: showsTouches) {
                            TouchVisualizer.shared.isEnabled = showsTouches
                        }
                } footer: {
                    Text("Applies to the entire app. Your choice is saved between launches.")
                }

                Section("Appearance") {
                    ColorPicker(
                        "Color",
                        selection: Binding(
                            get: { Color(uiColor: configuration.color) },
                            set: { configuration.color = UIColor($0) }
                        )
                    )
                    Stepper(
                        "Diameter: \(Int(configuration.diameter)) pt",
                        value: $configuration.diameter,
                        in: 16...96,
                        step: 4
                    )
                    .accessibilityIdentifier("diameter")
                    Stepper(
                        "Outline width: \(Int(configuration.strokeWidth)) pt",
                        value: $configuration.strokeWidth,
                        in: 0...8
                    )
                    .accessibilityIdentifier("strokeWidth")
                    Button("Reset appearance") {
                        configuration = .init()
                    }
                }
                .onChange(of: configuration) {
                    TouchVisualizer.shared.configuration = configuration
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
    ContentView(showsTouches: .constant(false))
}
