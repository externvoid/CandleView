//
//  ChartPlotApp.swift
//  ChartPlot
//
//  Created by Tanaka Hiroshi on 2024/01/13.
//

import SwiftUI

@main
struct ChartPlotApp: App {
  @StateObject var appState = AppState()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(appState)
    }
  }
}
