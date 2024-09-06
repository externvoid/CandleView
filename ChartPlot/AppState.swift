//  Created by Tanaka Hiroshi on 2024/08/23.
import Foundation
import NWer

@MainActor
class AppState: ObservableObject {
  @Published var codeTbl: [[String]] = []

  /// Properties used for detecting loading states
  @Published var loadingError = false
  @Published var isLoading = false
  @Published var isShown = false

  /// On `init` start downloading the data for the current day.
  init() {
    Task {
      codeTbl = try! await Networker.queryCodeTbl()
    }
  }
}
