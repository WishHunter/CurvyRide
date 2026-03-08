public func bug(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
  print("Bug!: \(message()) \(file)")
  assertionFailure(message(), file: file, line: line)
}
