/// 📅2024/01/13St
// [Using onAppear Only Once in SwiftUI | DeveloperMemos](https://developermemos.com/posts/onappear-once-swiftui)
import SwiftUI

struct ContentView: View {
//    var c: Candle = .init() // Candle is in Sources
  @StateObject var c: VM = .init() // Candle is in Sources
//    let c = VM(ar: VM.dummy) // Candle is in Sources
  let fsize: CGSize = CGSize(width: 300, height: 200)
//  @State var fsize: CGSize// = NSScreen.main!.frame.size
//    let fsize: CGSize = CGSize(width: 175, height: 120)
  var body: some View {
    GeometryReader { p in
//      CandleView(c: c, fsize: p.size)
      let pp: CGSize = CGSize(width: p.size.width - 100,
                              height: p.size.height - 200)
      CandleView(c: c, fsize: pp)
      let _ = print("in body@ContentView \(p.size)")
    }
//      CandleView(c: c, fsize: fsize)
//      let _ = print("in body \(fsize)")
//      .redacted(reason: c.isLoading ? .placeholder: .init())
  }
}

struct CandleView: View {
  @ObservedObject var c: VM
  var fsize: CGSize
  @State var hoverLocation: CGPoint = .zero
  @State var isHovering = false
  @State var didFinishSetup = false
  var body: some View {
    ZStack {
      ZStack(alignment: .bottom) {
        VStack(spacing: -10) {
          // 1
          Canvas { ctx, size in // size: 描画エリア、ar: 正規化取引値(0 - 1.0)
            candlestick(ctx, size)
            gridlines(ctx, size)
          }
          .frame(width: fsize.width, height: fsize.height)
          // 2
          Canvas { ctx, size in // Volume
            volumes(ctx, size)
          }
          .frame(width: fsize.width, height: fsize.height/4.0)
          //        .offset(x: 0, y: -15)
        }
        //.onAppear(perform: { c.ticker = "1301" })
        // 3
        Canvas { ctx, size in // Date Caption
          dateCap(ctx, size)
        }
        .frame(width: fsize.width, height: 12) //, alignment: .bottom)
        .padding(.bottom, 2)
      } // ZStack
      .onAppear {
        if !didFinishSetup {
//          sleep(1); c.ticker = "6952"
          didFinishSetup = true
        }
      }
      .padding(2)
      .border(Color.yellow, width: 0.5) // VStack
      .onContinuousHover { phase in
        switch phase {
        case .active(let location):
          hoverLocation = location
          isHovering = true
        case .ended:
          isHovering = false
        }
      }
      .overlay {
        overlayView
        //        if isHovering { }
      }
    }//.onAppear(perform: { c.ticker = "1301" }) // ZStack2
      .onAppear {
        print("ZStack2")
      }
    .padding(16)
    .background(Color(.windowBackgroundColor))
    .cornerRadius(12)
  } // some View
} // 日足、出来高を描画
extension CandleView {
  // MARK: - draw 出来高グラフ
  /// - Parameter ctx: , size, ar: (0,0) - (1,1)areaに描く出来高グラフのY座標
  func volumes(_ ctx: GraphicsContext, _ size: CGSize) -> Void {
    //  let h = size.height
    let width = size.width, h = size.height, n = c.ar.count, w = width / CGFloat(n)
    let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -h/c.vmax, tx: 0.0, ty: h)
    //  let mt0 = CGAffineTransform.identity.translatedBy(x: 0, y: -c.min)
    var ps = Path(), pf = Path() // 陽線、白塗り, 陽線、枠だけ

    for (i, e) in c.ar.enumerated() {
      let rect = CGRect(x: CGFloat(i) * w, y: 0.0, width: w, height: e.volume)
      pf.addRect(rect)
      ps.addRect(rect)
    }
    ctx.fill(pf.applying(mtx), with: .color(.blue))
    ctx.stroke(ps.applying(mtx), with: .color(.red))
  }
  // MARK: - draw 日付キャプション
  /// - Parameter ctx: , size, xticks: (0,0) - (1,1)areaに描く出来高グラフのY座標
  func dateCap(_ ctx: GraphicsContext, _ size: CGSize) {
    if c.ar.isEmpty { return }
    let width = size.width, _ = size.height, n = c.ar.count, w = width / CGFloat(n)
    //    let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: h)

    for (i, e) in c.xticks.enumerated() {
      //    print(i, e.st)
      let point = CGPoint(x: CGFloat(i) * w, y: 0.0)
      if e.st == true {
        let strDate = Date.formatter.string(from: e.date!) // => 2023/05/25
        let mo: Int = c.extractMonth(strDate)!
        var text: Text { Text("\(mo)月").font(.system(size: 11.5)) }
        ctx.draw(text,// no affine trs frm
                 at: point, anchor: UnitPoint(x: 0.0, y:  0.0))//.bottomLeading)
      }
    }
  }

  // MARK: - draw 価格、横軸 & Caption
  func gridlines(_ ctx: GraphicsContext, _ size: CGSize) {
    if c.ar.isEmpty { return }
    let h = size.height
    let rect = CGRect(origin: .zero, size: size) // 描画エリア
    let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -h/c.qheight, tx: 0.0, ty: h)
    let mt0 = CGAffineTransform.identity.translatedBy(x: 0, y: -c.min)
    var ps = Path() // 陽線、白塗り, 陽線、枠だけ
    c.yticks.forEach { e in
      ps.move(to: CGPoint(x: rect.minX, y: e))
      ps.addLine(to: CGPoint(x: rect.maxX, y: e))
    }
    ctx.stroke(ps.applying(mt0).applying(mtx), with: .color(.gray), style: StrokeStyle(dash:[2, 2, 2, 2]))
    // Axis Labels▶️ticks2の中身を再考
    var rticks: [Int] = []
    for e in c.yticks.reversed() { rticks.append(Int(e)) }

    for (i, e) in rticks.enumerated() {
      let y: Double = -(Double(e) - c.min) * h / c.qheight + h
      //    print("y: \(y)")
      ctx.draw(Text(String(rticks[i])).font(.system(size: 10.5)),
               at: CGPoint(x: rect.minX, y: y), anchor: UnitPoint(x: -0.0, y:  -0.1))//.bottomLeading)
    }
    ctx.draw(Text(c.ticker).font(.system(size: 10.5)), // no affine trs frm
             at: CGPoint(x: 0, y: 0), anchor: UnitPoint(x: -0.0, y:  -0.1))//.bottomLeading)
  }
  // MARK: - draw 日足 チャート座標系に描画してCanvas Viewの座標系へaffine transform
  func candlestick(_ ctx: GraphicsContext, _ size: CGSize) -> Void {
    let width = size.width, h = size.height, n = c.ar.count, w = width / CGFloat(n)
    let mtx = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -h/c.qheight, tx: 0.0, ty: h)
    let mt0 = CGAffineTransform.identity.translatedBy(x: 0, y: -c.min)
    //  let mt1 = CGAffineTransform.identity.translatedBy(x: 0, y: -c.min).concatenating(mtx)
    //  let mt2 = mtx.concatenating(CGAffineTransform.identity.translatedBy(x: 0, y: -c.min))
    var pf = Path(), ps = Path() // 陽線、白塗り, 陽線、枠だけ

    for (i, e) in c.ar.enumerated() {
      //    let point = CGPoint(x: CGFloat(i) * w, y: min(e.open, e.close)) // 日足左下座標
      //    let csize = CGSize(width: w, height: abs(e.open - e.close)) //実体縦横
      let rect = CGRect(x: CGFloat(i) * w, y: min(e.open, e.close), width: w, height: abs(e.open - e.close))
      if e.open < e.close { // 引け値高, 陽線
        pf.addRect(rect) // addLine can't be contained in fill method
      } else {
        ps.addRect(rect)
      }
      ps.move(to: CGPoint(x: rect.midX, y: rect.maxY))
      ps.addLine(to: CGPoint(x: rect.midX, y: e.high) )
      ps.move(to: CGPoint(x: rect.midX, y: rect.minY))
      ps.addLine(to: CGPoint(x: rect.midX, y: e.low) )
      // Cannot convert value of type 'Triangle1' to expected argument type 'StrokeStyle'
    }
    ctx.fill(pf.applying(mt0).applying(mtx), with: .color(.blue))
    //  ctx.fill(pf.applying(mt1), with: .color(.blue))
    //  ctx.stroke(pf.applying(mt2), with: .color(.blue))
    ctx.stroke(ps.applying(mt0).applying(mtx), with: .color(.blue))
  }

  // MARK: - describe code, volume, dateレジェンド
  /// - Parameter none
  @ViewBuilder
  var overlayView: some View {
    if c.ar.isEmpty { EmptyView() } else {
//    if false { EmptyView() } else {
      ZStack(alignment: .topLeading) {
//      let i = Int(hoverLocation.x/fsize.width * Double(c.ar.count))
      var i: Int {
        let n = Int(hoverLocation.x/fsize.width * Double(c.ar.count))
        let cnt = c.ar.count; return n >= cnt ? cnt - 1 : n
      }
      let v = Int(c.ar[i].volume)
      let d = c.ar[i].date
      Text("v: \(String(format: "%6d", v)), d: \(d)")
        .foregroundColor(.white)
        .font(.system(size: 9.5, design: .monospaced))
        .padding(.top, 13)
        .padding(.leading, 2)
      //        .offset(x: 10, y: 10)
      Rectangle()
        .fill(.white)
        .opacity(0.5)
        .frame(width: 01, height: fsize.height*1.20)
        .position(x: hoverLocation.x, y: (fsize.height*1.20)/2.0 + 0.0) // locate the center of View.
      }
    }
  }
}
