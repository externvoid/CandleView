//: [Previous](@previous)
// https://sarunw.com/posts/swiftui-buttonstyle/
// このコードはPlaygroundでは動かない。残念。

//: [Next](@next)

import SwiftUI
import UIKit
import PlaygroundSupport

let a = UIImage(named: "flower1.jpg")!

struct ContentView: View {
  @State private var isPressed: Bool = false
  
  var body: some View {
      Image(uiImage: a) // なぜか、失敗。
//    VStack {
//      Image("flower1.jpg")
//      Text("OK")
//    }
  }
}
PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView())
