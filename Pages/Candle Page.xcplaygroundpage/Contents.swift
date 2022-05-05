import SwiftUI
import PlaygroundSupport
//import CoreGraphics
let ar = Candle.ar2 // Candle is in Sources
let ticks = Candle.ticks2
struct ContentView: View {
  var body: some View {
    CandleView(ar: ar, ticks: ticks)
  }
}

let d = Date(dateString: "2016/02/28")
struct CandleView: View {
  var ar: [candle]
  var ticks: [gridline]
//  let ar = Candle.ar2 // Candle is in Sources
//  let ticks = Candle.ticks2
  var body: some View {
    VStack {
      Canvas { ctx, size in // size: 描画エリア、ar: 正規化取引値(0 - 1.0)
        candlefoo(ctx, size, ar)
        gridlines(ctx, size, ticks)
      }
      .frame(width: 300, height: 200)
      
      Canvas { ctx, size in // Volume
        volumes(ctx, size, ar)
      }
      .frame(width: 300, height: 50)
      .offset(x: 0, y: -10)
    }.border(Color.yellow, width: 2.0) // VStack
  }
} // 日足、出来高を描画
extension CandleView {
func volumes(_ ctx: GraphicsContext, _ size: CGSize, _ ar: [candle]) -> Void {
  let width = size.width, h = size.height, n = ar.count, w = width / CGFloat(n)
  let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: h)
  
  for (i, e) in ar.enumerated() {
    let point = CGPoint(x: CGFloat(i) * w, y: 0.0)
    let vsize = CGSize(width: w, height: h * e.volume)
    let rect = CGRect(origin: point, size: vsize) // 出来高棒
    ctx.fill(
      Path { p in
        p.addRect(rect) // addLine can't be contained in fill method
      }.applying(mtx), with: .color(.blue)
    )
    ctx.stroke(
      Path { p in
        p.addRect(rect) // addLine can't be contained in fill method
      }.applying(mtx), with: .color(.black)
    )
  }
}

func gridlines(_ ctx: GraphicsContext, _ size: CGSize, _ ticks: [gridline]) ->
  Void {
  let h = size.height
  let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: h)
  let rect = CGRect(origin: .zero, size: size) // 描画エリア
    
  ticks.forEach { e in
    ctx.stroke( //grid line
      Path { p in
        p.move(to: CGPoint(x: rect.minX, y: h * e.1))
        p.addLine(to: CGPoint(x: rect.maxX, y: h * e.1))
//      }, with: .color(.gray)
      }.applying(mtx), with: .color(.gray)
    )
  }
  // Axis Labels▶️ticks2の中身を再考
  var rticks: [Int] = []
  for e in ticks.reversed() { rticks.append(Int(e.quote)) }
  for (i, e) in ticks.enumerated() {
    ctx.draw(Text(String(rticks[i])).font(.system(size: 10.5)),
      at: CGPoint(x: rect.minX, y: h * e.norm), anchor: UnitPoint(x: -0.1, y:  1.0))//.bottomLeading)
  }
//  ctx.draw(Text("OK").font(.system(size: 10.5)),
//           at: CGPoint(x: 0, y: 0), anchor: UnitPoint(x: 0.0, y:  0.0))//.bottomLeading)
}
func candlefoo(_ ctx: GraphicsContext, _ size: CGSize, _ ar: [candle]) -> Void {
  let width = size.width, h = size.height, n = ar.count, w = width / CGFloat(n)
  let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: h)
  
  for (i, e) in ar.enumerated() {
    let point = CGPoint(x: CGFloat(i) * w, y: h * min(e.open, e.close))
    let csize = CGSize(width: w, height: h * abs(e.open - e.close)) //実体縦横
    let rect = CGRect(origin: point, size: csize) // ローソク実体
    if e.open >= e.close { // 終値下落, 陰線
      ctx.fill(
        Path { p in
          p.addRect(rect) // addLine can't be contained in fill method
        }.applying(mtx), with: .color(.blue)
      )
      ctx.stroke( // ひげ
        Path { p in
          p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
          p.addLine(to: CGPoint(x: rect.midX, y: h * e.high) )
          p.move(to: CGPoint(x: rect.midX, y: rect.minY))
          p.addLine(to: CGPoint(x: rect.midX, y: h * e.low) )
        }.applying(mtx), with: .color(.blue)
      )
    } else { // 陽線
      ctx.stroke(
        Path { p in
          let point = CGPoint(x: CGFloat(i) * w, y: h * min(e.open, e.close))
          let csize = CGSize(width: w, height: h * abs(e.open - e.close))
          let rect = CGRect(origin: point, size: csize)
          p.addRect(rect)
          p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
          p.addLine(to: CGPoint(x: rect.midX, y: h * e.high) )
          p.move(to: CGPoint(x: rect.midX, y: rect.minY))
          p.addLine(to: CGPoint(x: rect.midX, y: h * e.low) )
        }.applying(mtx), with: .color(.blue)
        // Cannot convert value of type 'Triangle1' to expected argument type 'StrokeStyle'
      )
    }
  }
}
}
PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView())
