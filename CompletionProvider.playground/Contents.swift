// Autocompletion tests

import Cocoa
import PlaygroundSupport

// Enum for the completion type
enum CompletionType : Int {
    case function = 0
    case constant = 1
}

// Our completion entry data type
struct CompletionEntry {
    var completionType: CompletionType
    
    // Public, non-nullable properties
    var title: String
    var description: String
    
    // Nullable property
    var arguments: String!
    
    private var _hasArguments: Bool = false
    
    // Initialization method, the underscore means there's no need to name the params
    init(_ completionType: CompletionType, _ title: String, _ description: String, _ arguments: String!) {
        self.completionType = completionType;
        self.title = title
        self.description = description
        self.arguments = arguments
        
        self._hasArguments = isFunction()
    }
    
    // Check is it's a function
    func isFunction() -> Bool {
        return completionType == .function
    }
    
    // Return the text for the input field
    func textEntry() -> String {
        if (_hasArguments) {
            return title + "(argument: " + arguments! + ")"
        } else {
            return title
        }
    }
}

// Method to parse the JSON completions file
// AnyObject represents any object of class-type, kind of 'id' in Obj-C
func readCompletionsJSON(_ object: [String: AnyObject]) -> [CompletionEntry]! {
    // Check if entries are there with Swift's 'guard' statement
    guard let entries = object["CompletionEntries"] as? [[String: AnyObject]] else {
        return nil
    }
    
    // Initialize the completions array
    var completionEntries: [CompletionEntry] = []
    
    // Fill the array
    for entry in entries {
        // Check for the fields
        guard let type = entry["completionType"] as? Int,
        let title = entry["title"] as? String,
        let description = entry["description"] as? String else {
            break
        }
        
        let completionType = CompletionType(rawValue: type)!
        
        let arguments = entry["arguments"] as! String!
        
        // Append to the array
        completionEntries.append(CompletionEntry(
            completionType,
            title,
            description,
            arguments
        ));
    }
    
    return completionEntries
}

// Catch our completions file
let url = Bundle.main.url(forResource: "completions", withExtension: "json")
let data = try Data(contentsOf: url!)

// Read it
do {
    let object = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
    
    if let dictionary = object as? [String: AnyObject] {
        readCompletionsJSON(dictionary)
    }
} catch {
    // Exceptions
    print(error)
}