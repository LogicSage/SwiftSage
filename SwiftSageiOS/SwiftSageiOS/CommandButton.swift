//
//  CommandButton.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

struct CommandButtonView: View {
    @State private var isInputViewShown = false
    @State private var multiLineText = ""
    @ObservedObject var settingsViewModel: SettingsViewModel
    @FocusState private var isTextFieldFocused: Bool

    func doExec() {
        self.isInputViewShown.toggle()
        consoleManager.isVisible = !isInputViewShown
        consoleManager.fontSize = settingsViewModel.textSize
    }

    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                Spacer()

                HStack {
                    Spacer()
                    if !isInputViewShown {
                        // PLugItIn BUTTON
                        Button("🔌") {
                            print("🔌 Force reconnecting websocket...")
                            consoleManager.print("🔌 Force reconnect...")
                            consoleManager.print("You can always force quit / restart you know...")

                            //screamer.connect()
                        }
                        .font(.body)
//                        .foregroundColor(Color.white)
//                        .padding(.bottom)
                        .background(settingsViewModel.buttonColor)
//                        .cornerRadius(10)
                    }

                    if multiLineText.isEmpty && isInputViewShown {
                        // debate BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            multiLineText += "debate "
                        }) {
                            Text( "debate")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
//                        // st BUTTON
//                        Button(action: {
//                            isTextFieldFocused = true
//                            multiLineText += "st"
//                        }) {
//                            Text( "st")
//                                .font(.subheadline)
//                                .foregroundColor(Color.white)
//                                .padding()
//                                .background(settingsViewModel.buttonColor)
//                                .cornerRadius(10)
//                        }
//                        .padding(.bottom)
                        // i BUTTON
                        Button(action: {
                            isTextFieldFocused = true
                            multiLineText += "i "
                        }) {
                            Text( "i")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)
                        // g BUTTON

                        Button(action: {
                            isTextFieldFocused = true
                            multiLineText += "g "
                        }) {
                            Text( "g")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)

                        }
                        .padding(.bottom)

                    }

                    if !multiLineText.isEmpty && isInputViewShown {
                        // X BUTTON
                        Button(action: {
                            multiLineText = ""
                        }) {
                            Text( "X")
                                .font(.subheadline)
                                .foregroundColor(Color.white)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .cornerRadius(10)
                        }
                        .padding(.bottom)

                    }
                    // STOP BUTTON
                    Button(action: {

                        // cmd send st
                        multiLineText = "st"
                        DispatchQueue.main.async {

                            // Execute your action here
                            screamer.sendCommand(command: multiLineText)

                            self.isInputViewShown = false
                            consoleManager.isVisible = true

                        }

                    }) {
                        Text("🛑")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)


                    Button(action: {
                        // Execute your action here
                        screamer.sendCommand(command: multiLineText)

                        self.isInputViewShown = false
                        consoleManager.isVisible = true

                    }) {
                        Text("EXEC")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                    Button(action: {
                        if isInputViewShown {
                            // Execute your action here
                            screamer.sendCommand(command: multiLineText)

                            self.isInputViewShown = false
                            consoleManager.isVisible = true
                        }
                        else {
                            doExec()
                        }
                    }) {
                        Text(self.isInputViewShown ? "TERM" : "COMMAND")
                            .font(.headline)
                            .foregroundColor(Color.white)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .cornerRadius(10)
                    }
                    .padding(.bottom)

                }
                .padding(.bottom)


                if isInputViewShown {
                    TextEditor(text: $multiLineText)
                        .frame(height: 200)
                        .border(settingsViewModel.buttonColor, width: 2)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .focused($isTextFieldFocused)
                        .scrollDismissesKeyboard(.interactively)
                }
            }
        }
    }
}
