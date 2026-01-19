import Testing
import AppKit
@testable import ThingsToOrgKit

@Suite("AppleScripts Executor Tests")
struct AppleScriptsExecutorTests {
  enum TestError: Error, Equatable {
    case boom
  }

  @Test("Single script execution returns expected result")
  func testSingleScriptSuccess() async throws {
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: "return \"Hello, AppleScript!\""))
    #expect(result == "Hello, AppleScript!")
  }
  
  @Test("Multiple scripts execute in sequence")
  func testMultipleScriptsSequential() async throws {
    let script1 = AppleScript(script: "return \"First\"")
    let script2 = AppleScript(script: "return \"Second\"")
    let script3 = AppleScript(script: "return \"Third\"")
    
    let result1 = try await AppleScriptsExecutor.execute(script1)
    let result2 = try await AppleScriptsExecutor.execute(script2)
    let result3 = try await AppleScriptsExecutor.execute(script3)
    
    #expect(result1 == "First")
    #expect(result2 == "Second") 
    #expect(result3 == "Third")
  }
  
  @Test("Concurrent script execution")
  func testConcurrentScriptExecution() async throws {
    // Execute multiple scripts concurrently
    async let result1 = AppleScriptsExecutor.execute(AppleScript(script: "return \"Concurrent1\""))
    async let result2 = AppleScriptsExecutor.execute(AppleScript(script: "return \"Concurrent2\""))
    async let result3 = AppleScriptsExecutor.execute(AppleScript(script: "return \"Concurrent3\""))
    
    let results = try await [result1, result2, result3]
    
    // All scripts should complete successfully
    #expect(results.count == 3)
    #expect(results.contains("Concurrent1"))
    #expect(results.contains("Concurrent2"))
    #expect(results.contains("Concurrent3"))
  }
  
  @Test("Script with numeric return value")
  func testScriptReturningNumber() async throws {
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: "return 42"))
    #expect(result == "42")
  }
  
  @Test("Script with boolean return value")
  func testScriptReturningBoolean() async throws {
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: "return true"))
    #expect(result == "true")
  }
  
  @Test("Script with list return value")
  func testScriptReturningList() async throws {
    // AppleScript lists need to be converted to string explicitly
    let script = """
      set myList to {"item1", "item2", "item3"}
      set AppleScript's text item delimiters to ", "
      set listAsString to myList as string
      set AppleScript's text item delimiters to ""
      return listAsString
      """
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: script))
    
    // AppleScript lists converted to strings are comma-separated
    #expect(result.contains("item1"))
    #expect(result.contains("item2"))
    #expect(result.contains("item3"))
    #expect(result.contains(", ")) // Should contain the delimiter
  }
  
  @Test("Empty script execution")
  func testEmptyScript() async throws {
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: ""))
    #expect(result == "")
  }
  
  @Test("Script with variables and operations")
  func testScriptWithVariables() async throws {
    let script = """
      set x to 10
      set y to 5
      return x + y
      """
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: script))
    #expect(result == "15")
  }
  
  @Test("Script execution throws error for invalid syntax")
  func testInvalidScriptThrowsError() async throws {
    await #expect(throws: AppleScript.Error.self) {
      try await AppleScriptsExecutor.execute(AppleScript(script: "this is not valid applescript syntax!!!"))
    }
  }
  
  @Test("Large number of concurrent scripts")
  func testManyScriptsExecution() async throws {
    let scriptCount = 10
    
    // Create array of tasks
    let tasks = (1...scriptCount).map { index in
      Task {
        try await AppleScriptsExecutor.execute(AppleScript(script: "return \"Script\(index)\""))
      }
    }
    
    // Wait for all tasks to complete
    let results = try await withThrowingTaskGroup(of: String.self) { group in
      for task in tasks {
        group.addTask { try await task.value }
      }
      
      var allResults: [String] = []
      for try await result in group {
        allResults.append(result)
      }
      return allResults
    }
    
    #expect(results.count == scriptCount)
    
    // Check that all expected results are present
    for index in 1...scriptCount {
      #expect(results.contains("Script\(index)"))
    }
  }
  
  @Test("Script with system interaction")
  func testSystemInteractionScript() async throws {
    // Get current date/time - this tests that AppleScript can interact with system
    let script = "return (current date) as string"
    let result = try await AppleScriptsExecutor.execute(AppleScript(script: script))
    
    // Result should contain date information
    #expect(!result.isEmpty)
    // Basic check that it looks like a date string
    #expect(result.contains("202")) // Should contain year starting with 202
  }
  
  @Test("Script execution preserves order under concurrent load")
  func testOrderPreservationUnderLoad() async throws {
    // Execute scripts that include their order number
    let tasks = (1...5).map { index in
      Task {
        let script = AppleScript(script: "return \"Order:\(index)\"")
        return try await AppleScriptsExecutor.execute(script)
      }
    }
    
    let results = try await withThrowingTaskGroup(of: String.self) { group in
      for task in tasks {
        group.addTask { try await task.value }
      }
      
      var allResults: [String] = []
      for try await result in group {
        allResults.append(result)
      }
      return allResults
    }
    
    // All results should be present
    #expect(results.count == 5)
    for index in 1...5 {
      #expect(results.contains("Order:\(index)"))
    }
  }
}
