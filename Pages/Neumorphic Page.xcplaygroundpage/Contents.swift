//: [Previous](@previous)
// https://sarunw.com/posts/swiftui-buttonstyle/

//: [Next](@next)

import SwiftUI
import PlaygroundSupport

struct ContentView: View {
  @State private var isPressed: Bool = false
  
  var body: some View {
    VStack {
      Button(action: {
        self.isPressed.toggle()
      }, label: {
        VStack {
          Text("Hello")
        }.neumorphic(isPressed: $isPressed, bgColor: .gray)
        //            }.neumorphic(isPressed: $isPressed, bgColor: .neuBackground)
      }).frame(maxWidth: .infinity,
               maxHeight: .infinity)
      .background(Color.gray)
      //            .background(Color.neuBackground)
      .edgesIgnoringSafeArea(.all)
      
    }.frame(width: 200, height: 200)
  }
}

struct Neumorphic: ViewModifier {
  var bgColor: Color
  @Binding var isPressed: Bool
  
  func body(content: Content) -> some View {
    content
      .padding(20)
      .background(
        ZStack {
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .shadow(color: .white, radius: self.isPressed ? 7: 10, x: self.isPressed ? -5: -15, y: self.isPressed ? -5: -15)
            .shadow(color: .black, radius: self.isPressed ? 7: 10, x: self.isPressed ? 5: 15, y: self.isPressed ? 5: 15)
            .blendMode(.overlay)
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(bgColor)
        }
      )
      .scaleEffect(self.isPressed ? 0.95: 1)
      .foregroundColor(.primary)
      .animation(.spring(), value: 1.0)
      //.animation(.spring())
  }
}

extension View {
  func neumorphic(isPressed: Binding<Bool>, bgColor: Color) -> some View {
    self.modifier(Neumorphic(bgColor: bgColor, isPressed: isPressed))
  }
}


PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView())
