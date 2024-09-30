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
      let dbBase = "/Volumes/twsmb/newya/asset/"
      //        let dbBase = "/Volumes/homes/super/NASData/StockDB/"
      let dbPath1 = dbBase + "yatoday.db"
      let dbPath2 = dbBase + "n225Hist.db"
      codeTbl = try! await Networker.queryCodeTbl(dbPath1, dbPath2)
    }
  }
}
