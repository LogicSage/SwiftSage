//
//  main.swift
//  Swifty-GPT
//
//  Created by Chris Dillard on 4/8/23.
//

import Foundation

// Note you must have xcodegen brew and gem xcodeproj installed.

// Replace this with your OpenAI API key
let OPEN_AI_KEY = "sk-OPEN_AI_KEY"
let PIXABAY_KEY = "PIXABAY_KEY"

// TODO: Fix hardcoded paths.
let xcodegenPath = "/opt/homebrew/bin/xcodegen"
let infoPlistPath = "/Users/sprinchar/Documents/GPT/Swifty-GPT/Swifty-GPT/Info.plist"
let rubyScriptPath = "/Users/sprinchar/Documents/GPT/Swifty-GPT/Swifty-GPT/add_file_to_project.rb"
let apiEndpoint = "https://api.openai.com/v1/chat/completions"
let swiftyGPTWorkspaceName = "SwiftyGPTWorkspace"

// Configurable settings for AI.
let retryLimit = 10

struct GPTAction: Codable {
    let command: String
    let name: String?
    //let fileContents: String?
}

var projectName = ""

// Main function to run the middleware
func main() {
    // Parse command-line arguments
    let arguments = CommandLine.arguments
    let appName = arguments.contains("--name") ? arguments[arguments.firstIndex(of: "--name")! + 1] : "MyApp"
    let appType = arguments.contains("--type") ? arguments[arguments.firstIndex(of: "--type")! + 1] : "iOS"
    let language = arguments.contains("--language") ? arguments[arguments.firstIndex(of: "--language")! + 1] : "Swift"

    // TODO: Check workspace and delete or backup if req
    // backup workspace to file folder with suffix
    backupAndDeleteWorkspace()
    
    // Other optional command-line arguments, like frameworks or additional features, can be added here

//    let appDesc = "a game that uses simple shapes and colors. Develop a 2D grid-based color matching puzzle where players swap shapes to create matches, clear grid cells, and score points. Use distinct colors and geometric shapes (circles, squares, triangles) for game pieces. Utilize animations for shape swapping and cascading. Develop using Apple's built in frameworks."

//    let appDesc = "that displays a matching game to the user. There should be a 2d grid of cards with concealed emojis on them, tapping a card should show the concealed emoji. If the user selects two cards with the same concealsed emoji, they get a point and those two cards are removed from the grid."

//    let appDesc = "that displays a text label that says 'Hello World! with text color that randomly changes to a random color every random number of seconds between 1-3."
//    let appDesc = "that displays the following text using a typewriter animation: You are feeling very sleepy..."
    // Working PROMPTS that generate somewhat working code.
//    let appDesc = "that displays a label that says I love you so much! with heart emojis all around the screen in random places."
//     let appDesc = "containing a label that says 'Hello World!"
//     let appDesc = "containing a color picker and a label that says `Hi bud` which changes color based on the picker."
//     let appDesc = "that displays a scrollable grid with many random emojis and the emoji name in each square."
    //let appDesc = "containing a circle that can be moved by tapping and dragging."
//     let appDesc = "containing a circle that can be moved by tapping and dragging and stays where you move it."
//    let appDesc = "containing a list of hilarious jokes."
//    let appDesc = "that displays a beautiful gradient between green and light green across the entire screen. Show a system symbol in multicolor of the palette in the center of the screen."
//      let appDesc = "that displays a 3d scene using SceneKit. Show a beach ball in the SceneKit 3d view."
//    let appDesc = "that displays the following text using a typewriter animation: You are feeling very sleepy..."

    // PARTIALLY WORKS. EXCITED TO see gpt-4
//    let appDesc = "that displays the classic Hangman game. A random word should be chosen and the user should be able to guess by entering into the text field."
   // let appDesc = "that implments the classic game battleships. The user should be able to play against the computer opponent."
    let appDesc = "that displays a spiraling swirling line across the entire screen. It should use many different colors."

    // Should use import Accelerate ????
//      let appDesc = "that displays a mandelbrot set fractal."

//     let appDesc = "Generate Swift code for an iOS app that displays an interactive Mandelbrot set fractal. The app should allow users to zoom in and out, and pan the fractal using touch gestures. The fractal should be rendered in real-time, with adjustable color schemes. Include code for basic touch gesture handling and the fractal generation algorithm."

    //let appDesc = "that shows an wave using sin function. Animate the wave by changing the value passed to sin over time. "
    // let appDesc = "that displays an animation of  many layers sliding to open the screen."
    // let appDesc = "that displays all the emoji related to plants and green across the screen in random locations."

    // borky
//    let appDesc = "that displays an american flag. The american flag should be drawn using the built in shape drawing in SwiftUI."
//     let appDesc = "that displays a list of saved notes. The app should allow the user to create a new note."
//    let appDesc = "that implements the classic dots and boxes game."

    // Example GPT prompt with command-line arguments included
    let prompt = """
You are working on a \(appType) app in the \(language) programming language named \(appName).

As an AI language model, please generate \(language) code for a SwiftUI app \(appDesc). Your response should include the necessary \(language) code files. Please ensure that the generated code is valid and properly formatted. The files should be returned as a JSON array with the following structure:

It is essential you return your response as a JSON array matching the structure:. [{"command": "Create file","name": "Filename.swift","fileContents": "SWIFT_FILE_CONTENTS"}]

Example SWIFT_FILE_CONTENTS = "import SwiftUI\nstruct ContentView: View {\n    var body: some View {\n        Spinner()\n    }\n}\nstruct Spinner: View {\n    @State private var spin = 0.0\n    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()\n    var body: some View {\n }"

Available commmands are: "Close project name" , "Create project name", "Open project name", Create file name fileContents

Please keep in mind the following constraints when generating the response:
1. It is essential you return your response as a JSON array.
2. It is essential you include a Swift `App` file.
3. Focus on generating valid, properly formatted, and properly escaped Swift code.
4. Complete tasks in this order: Create project. Create Swift files including App file. Open project. Close project.
"""

    //It is essential that "SWIFT_FILE_CONTENTS" be a string that can be parsed by JSONDecoder.

    /*
     3. Run project
     4. Build project
     5. Test project
     6. Commit changes
     7. Push changes
     8. Send Slack message
     */

    var promptingRetryNumber = 0

    let sema = DispatchSemaphore(value: 0)

    func doPrompting() {
        generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit) { response in
            if response != nil, let response {
                parseAndExecuteGPTOutput(response) { success in
                    if success {
                        print("Parsed and executred code successfully.")
                        print("Opening project....")

                        executeAppleScriptCommand(.openProject(name: projectName))

                        sema.signal()
                    }
                    else {
                        print("Failed @ parsing / executing code successfully.")
                        if promptingRetryNumber >= retryLimit {
                            print("OVERALL prompting limit reached, stopping the process. Try a diff prompt you doof.")
                            //completion(nil)
                            sema.signal()
                            return
                        }

                        promptingRetryNumber += 1

                        doPrompting()
                    }
                }
            } else {
                print("Failed to generate compilable code within the retry limit.")
            }
        }
    }

    doPrompting()

    sema.wait()
}

func generateCodeUntilSuccessfulCompilation(prompt: String, retryLimit: Int, currentRetry: Int = 0, completion: @escaping (String?) -> Void) {
    if currentRetry >= retryLimit {
        print("Retry limit reached, stopping the process.")
        completion(nil)
        return
    }
    backupAndDeleteWorkspace()
    projectName = ""

    sendPromptToGPT(prompt: prompt) { response, success in
        if success {
            completion(response)
        } else {
            backupAndDeleteWorkspace()
            projectName = ""

            print("Code did not compile successfully, trying again... (attempt \(currentRetry + 1)/\(retryLimit))")
            generateCodeUntilSuccessfulCompilation(prompt: prompt, retryLimit: retryLimit, currentRetry: currentRetry + 1, completion: completion)
        }
    }
}

// Function to send a prompt to GPT via the OpenAI API
func sendPromptToGPT(prompt: String, completion: @escaping (String, Bool) -> Void) {

    let url = URL(string: apiEndpoint)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Set the required headers
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(OPEN_AI_KEY)", forHTTPHeaderField: "Authorization")

    // Prepare the request payload
    let requestBody: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": [
            [
                "role": "user",
                "content": prompt,
            ]
        ]
    ]
    do {
        // Convert the payload to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion("Failed networking w/ error = \(error)", false)
                return
            }

            guard let data  else {
                completion("Failed networking w/ error = \(error)", false)
                return print("failed to laod data")
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content, true)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion("Failed parsing JSON w/ error = \(error)",false)
            }
        }
        print("🐑🧠🧠🧠 THINKING... 🧠🧠🧠🐑")
        task.resume()
    }
    catch {
        return completion("Failed parsing w/ error = \(error)", false)
    }
}

func executeXcodeCommand(_ command: XcodeCommand, completion: @escaping (Bool) -> Void) {
    switch command {
    case let .openProject(name):
        print("SKIPPING GPT-Opening project with name (we auto open project after gpt commands now): \(name)")
        //        executeAppleScriptCommand(.openProject(name: projectName))
        //        completion(true)
    case let .createProject(name):
        print("Creating project with name: \(name)")
        projectName = name
        print("set current name")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/"

        // Call the createNewWorkspace function directly
        createNewProject(projectName: name, projectDirectory: projectPath)
        completion(true)

    case .closeProject(name: let name):
        print("SKIPPING GPT-Closing project with name: \(name)")
        //        executeAppleScriptCommand(.closeProject(name: name))
        //        completion(true)

    case .createFile(fileName: let fileName, fileContents: let fileContents):
        if projectName.isEmpty {
            print("missing proj, creating one")

            // MIssing projecr gen// create a proj
            executeXcodeCommand(.createProject(name: projectName)) { success in }
        }
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(projectName)"
        let filePath = "\(projectPath)/Sources/\(fileName)"
        print("Adding file w/ path: \(filePath) w/ contents w length = \(fileContents.count) to p=\(projectPath)")
        createFile(projectPath: "\(projectPath).xcodeproj", projectName: projectName, targetName: projectName, filePath: filePath, fileContent: fileContents)
        completion(true)

    case .buildProject(name: let name):
        print("buildProject project with name: \(name)")
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\(projectName).xcodeproj"

        buildProject(projectPath: projectPath, scheme: projectName) { success in

            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

// Function to execute an high level Xcode Shell/ Ruby / AppleScript command
func executeAppleScriptCommand(_ command: XcodeCommand) {
    if !command.appleScript.isEmpty {
        
        let appleScriptCommand = command.appleScript
        let script = NSAppleScript(source: appleScriptCommand)
        var errorDict: NSDictionary? = nil
        print("Executing AppleScript: \(command)")

        script?.executeAndReturnError(&errorDict)
        if let error = errorDict {
            print("AppleScript Error: \(error)")
        }
    } else {
        print("Unsupported command")
    }
}

// Returns success / failure for some ops.
func parseAndExecuteGPTOutput(_ output: String, completion: @escaping (Bool) -> Void) {

    print("orignal GPT output = \(output)")

    let (updatedString, fileContents) = extractFileContents(output)
    print("extracted files from response = \(fileContents.count)")
    for (index, file) in fileContents.enumerated() {
        let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\("x_xTempProjNamex_x")"
        let filePath = "\(projectPath)/Sources/\(index).swift"

        do
        {
            try FileManager.default.createDirectory(atPath: "\(projectPath)/Sources/", withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
        }

//        if FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil) {
            writeFile(fileContent: file, filePath: filePath)
            print("EARLY Added file: \(filePath) w/ contents w length = \(fileContents.count) to Sources...")
//        }
//        else {
//            print("Unable to create early file.. failed to create file")
//
//        }


    }
    print("Tried to extract files from respone and write out in sequential Swift files 0.Swift , 1.Swift, 2.Swift , etc..")
    let sanitizedOutput =   removeInvalidEscapeSequences(in: updatedString)

    let doubleSanitizedOuput =  removeControlCharacters(from: sanitizedOutput)

    let manualRemoval = replaceFileContents(doubleSanitizedOuput)

    // let removedAfterBracketText =  removeTextAfterLastClosingBracket(input: manualRemoval)

    print("Attempt to parseAndExecute output = \(manualRemoval)")

    guard let data = manualRemoval.data(using: .utf8) else {
        print("Invalid GPT output")
        return completion(false)
    }

    var fileIndex = 0

    do {
        let gptCommands = try JSONDecoder().decode([GPTAction].self, from: data)
        for (index, gptAction) in gptCommands.enumerated() {
            let fullCommand = gptAction.command

            switch fullCommand {
            case "Create project":
                guard let name = gptAction.name else { return completion(false) }

                executeXcodeCommand(.createProject(name: name)) { success in }
            case "Open project":
                guard let name = gptAction.name else { return completion(false) }

                executeXcodeCommand(.openProject(name: name)) { success in }

            case "Close project":
                guard let name = gptAction.name else { return completion(false) }
                // todo: check success here
                executeXcodeCommand(.createProject(name: name)) { _ in  }
            case "Create file":
                guard let fileName = gptAction.name  else {
                    return
                    //completion(false)
                }

                var fileContents = Array(fileContents)

                let foundFileContents: String
                if fileContents.count > fileIndex {
                    foundFileContents = fileContents[index - 1]
                }
                else {
                    // check the other place
                    let projectPath = "\(getWorkspaceFolder())\(swiftyGPTWorkspaceName)/\("x_xTempProjNamex_x")"
                    let filePath = "\(projectPath)/Sources/\(fileIndex).swift"

                    if let data = FileManager.default.contents(atPath: filePath) {
                        foundFileContents = String(decoding: data, as: UTF8.self)
                    }
                    else {
                        foundFileContents = ""
                    }
                }

                fileIndex += 1

                if foundFileContents.isEmpty {
                    return completion(false)
                }

                executeXcodeCommand(.createFile(fileName: fileName, fileContents:foundFileContents)) { success in  }

            default:
                print("Unknown command \(fullCommand)")
                //return completion(false)
            }
        }

        print("Building project...")
        executeXcodeCommand(.buildProject(name: projectName)) { success in
            if success {
                completion(true)
            }
            else {
                completion(false)
            }
        }

    } catch {
        print("Error decoding JSON: \(error)")
        return completion(false)
    }
}

func writeFile(fileContent: String, filePath: String) {
    print("createFile w/ contents = \(fileContent)")

    let modifiedFileContent = fileContent.replacingOccurrences(of: "\\n", with: "\n")
    // Create a new Swift file
    if let data = modifiedFileContent.data(using: .utf8) {
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
        }
        catch {
            print("Error writing file: \(error) @ p = \(filePath)")
        }
    }
}

func createFile(projectPath: String, projectName: String, targetName: String, filePath: String, fileContent: String) {

    writeFile(fileContent: fileContent, filePath: filePath)

    // Add the file to the project using xcodeproj gem
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = [
        "ruby",
        // TODO: Fix hardcoded path.
        rubyScriptPath,
        projectPath,
        filePath,
        targetName
    ]

    do {
        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            print("Error: Failed to add file to the project.")
        } else {
            print("File successfully added to the project.")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

main()
