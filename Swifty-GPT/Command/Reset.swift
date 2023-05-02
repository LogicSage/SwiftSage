//
//  Reset.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 5/1/23.
//

import Foundation

var config = Config(
    projectName: "MyApp",
    globalErrors: [String](),
    manualPromptString: "",
    blockingInput: false,
    promptingRetryNumber: 0,
    lastFileContents: [String](),
    lastNameContents: [String](),
    searchResultHeadingGlobal: nil,
    appName: "MyApp",
    appType: "iOS",
    appDesc: builtInAppDesc,
    language: "Swift",
    conversational: false,
    streak: 0,
    chosenTQ: nil,
    promptMode: .normal,
    // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
    enableGoogle: false,
    enableLink: false,
    loadMode: LoadMode.dots
)


struct Config {
    var projectName: String
    var globalErrors: [String]
    var manualPromptString: String
    var blockingInput: Bool
    var promptingRetryNumber: Int

    var lastFileContents: [String]
    var lastNameContents: [String]
    var searchResultHeadingGlobal: String?
    var linkResultGlobal: String?

    var appName: String
    var appType: String

    var appDesc: String
    var language: String

    var conversational: Bool
    var streak: Int
    var chosenTQ: TriviaQuestion?
    var promptMode: InputMode

    // EXPERIMENTAL: YE BEEN WARNED!!!!!!!!!!!!
    var enableGoogle: Bool
    var enableLink: Bool

    var loadMode: LoadMode

}
func resetCommand(input: String) {

    // TODO: Reset for the right user.
    resetCommandWithConfig(config: &config)
}

func resetCommandWithConfig(config: inout Config) {
    config.projectName = "MyApp"
    config.globalErrors = [String]()
    config.manualPromptString = ""
    config.blockingInput = false
    config.promptingRetryNumber = 0

    config.lastFileContents = [String]()
    config.lastNameContents = [String]()
    config.searchResultHeadingGlobal = nil

    config.appName = "MyApp"
    config.appType = "iOS"

    config.appDesc = builtInAppDesc
    config.language = "Swift"

    config.conversational = false
    config.manualPromptString = ""

    config.streak = 0
    config.chosenTQ = nil
    config.promptMode = .normal

    config.loadMode = LoadMode.dots
    multiPrinter("🔁🔄♻️ Reset.")
}
