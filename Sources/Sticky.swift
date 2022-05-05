import SwiftUI
// [SwiftUIの肝となるGeometryReaderについて理解を深める - Qiita](https://qiita.com/masa7351/items/0567969f93cc88d714ac)
public struct StickyNoteSamplesView: View {
  public init() {}
  public var body: some View {
    Group {
      Text("Hello World!")
        .frame(width: 120, height: 120)
        .background(StickyNoteView())
      
      Spacer().frame(height: 10)
      
      Text("GeometryReaderのお勉強。これをマスターすると実現できることが広がりそう。")
        .frame(width: 200, height: 200)
        .lineLimit(10)
        .fixedSize(horizontal: true, vertical: false)
        .background(StickyNoteView())
    }
  }
}

public struct StickyNoteView: View {
  var color: Color = .green
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Path { path in
          let w = geometry.size.width
          let h = geometry.size.height
          let m = min(w/5, h/5)
          path.move(to: CGPoint(x: 0, y: 0))
          path.addLine(to: CGPoint(x: 0, y: h))
          path.addLine(to: CGPoint(x: w-m, y: h))
          path.addLine(to: CGPoint(x: w, y: h-m))
          path.addLine(to: CGPoint(x: w, y: 0))
          path.addLine(to: CGPoint(x: 0, y: 0))
        }
        .fill(self.color)
        Path { path in
          let w = geometry.size.width
          let h = geometry.size.height
          let m = min(w/5, h/5)
          path.move(to: CGPoint(x: w-m, y: h))
          path.addLine(to: CGPoint(x: w-m, y: h-m))
          path.addLine(to: CGPoint(x: w, y: h-m))
          path.addLine(to: CGPoint(x: w-m, y: h))
        }
        .fill(Color.black).opacity(0.4)
      }
    }
  }
}
