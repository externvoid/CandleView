import SwiftUI

// MARK: ListItemView
struct ListItemView: View {
  @ObservedObject var c: VM
  var title: String
  @Binding var txt: String
  @Binding var code: String
  @Environment(\.dismiss) private var dismiss
  var body: some View {
    Button {
      print("\(title) Pressed!")
      print("\(title2code(title)) Pressed!")
      txt = title
      code = title2code(title)
      c.ticker = code
      dismiss()
    } label: {
      HStack {
        Text(title).foregroundStyle(.blue)
        Spacer()
      }
      .padding([.leading], 5)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    // ButtonStyleでタップ中のスタイルを指定
    .buttonStyle(ListItemButtonStyle())
  }
  func title2code(_ title: String) -> String {
    let prefix = String(title.prefix(4))
    let reg = try! Regex("^[a-zA-Z0-9]+$")
    if prefix.contains(reg) {
      return prefix
    } else {
      return ""
    }
  }  //  先頭4文字取り出してTickerなら値をセット
}
// 🔹ボタンスタイルを使って押下時にボタンを変化させる。Gestureは不要！
/// Listで押下時の背景色を変える場合に使うButtonStyle
protocol ListButtonStyle: ButtonStyle {
  /// 通常の背景色
  var backgroundColor: Color { get }
  /// 押下時の背景色
  var pressedBackgroundColor: Color { get }
  /// 背景色を取得する
  /// - Parameter isPressed: 押下時かどうか
  /// - Returns: Color
  func backgroundColor(isPressed: Bool) -> Color
}

extension ListButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(backgroundColor(isPressed: configuration.isPressed))
  }

  func backgroundColor(isPressed: Bool) -> Color {
    return isPressed ? pressedBackgroundColor : backgroundColor
  }
}

struct ListItemButtonStyle: ListButtonStyle {
  var backgroundColor: Color = .init(
    red: 245 / 255, green: 245 / 255, blue: 245 / 255)
  var pressedBackgroundColor: Color = .init(
    red: 255 / 255, green: 192 / 255, blue: 203 / 255)
}
// MARK: CodeOrNameView
struct CodeOrNameView: View {
  @ObservedObject var c: VM
  @State var ar: [[Any]] = []
  //  @State var ar: [[Any]] = await fetchCodeTbl(url)
  @State var txt: String = ""
  // @Binding var txt: String
  @Binding var code: String
  let url = "https://stock.bad.mn/jsonCode2"
  var allItems: [String] {
    ar.map { e in
      let s1 = e[0] as! String
      let s2 = e[1] as! String
      let s3 = e[2] as! String
      return s1 + ": " + s2 + ": " + s3
      //      let s1 = e[0] as! String ,s2 = e[1] as! String; return s1 + ": " + s2
    }
  }
  var items: [String] {
    txt.isEmpty ? allItems : Array(allItems.filter { $0.contains(txt) })
  }
  // MARK: - codeOrNameView
  var codeOrNameView: some View {
    List {
      Section(header: textBox(txt: $txt)) {
        ForEach(items, id: \.self) { item in
          ListItemView(c: c, title: item, txt: $txt, code: $code)
            .listRowInsets(.init())
        }
      }
      //      .task { ar = await fetchCodeTbl(url) }
      //      .task { if ar.isEmpty { ar = await fetchCodeTbl(url) } }
    }
    .listStyle(.plain)
    .navigationTitle("ListView")
    .frame(width: 300, height: 300)
  }
  // MARK: - body
  var body: some View {
    codeOrNameView
    //    Text("Code Or Name")
  }
  // MARK: textBox
  func textBox(txt: Binding<String>) -> some View {
    HStack {
      Spacer()
      TextField("code or name", text: txt).font(.title)
      Spacer()
      Button {
        self.txt = ""
      } label: {
        Image(systemName: "xmark.circle").resizable()
          .scaledToFit().frame(width: 15)
      }
    }
  }

  func fetchCodeTbl(_ str: String) async -> [[Any]] {
    let url = URL(string: str)!
    let request = URLRequest(url: url)
    var ar: [[Any]] = []
    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      if let jsonArray = try? JSONSerialization.jsonObject(
        with: data,
        options: []) as? [[Any]]
      {
        ar = jsonArray
      }
      puts("OK")
    } catch {
      print(error)
    }
    return ar
  }
}
struct ContentView0: View {  // for playground
  //  @State var txt: String = ""
  @State var code: String = ""
  @StateObject var c: VM = .init()  // Candle is in Sources
  var body: some View {
    CodeOrNameView(c: c, code: $code)  // 三菱
    // CodeOrNameView(txt: $txt, code: $code) // 三菱
    let _ = print(code)  // 6503
  }
}
#Preview {
  ContentView0()
}
//[SwiftUIのListでタップ中の背景色を変える｜TAAT](https://note.com/taatn0te/n/n225eb65839bc)
//[swift - SwiftUI: Actors and Views - Mutable capture of 'inout' parameter 'self' is not allowed in concurrently-executing code - Stack Overflow](https:stackoverflow.com/questions/74508254/swiftui-actors-and-views-mutable-capture-of-inout-parameter-self-is-not-a)
// 📅2024/07/14Sn 表示に10sec@Xcocd16beta3
