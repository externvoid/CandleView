import Combine
import NWer
//[【Xcode/Swift】APIエラー：App Transport Securityの解決方法 - iOS-Docs](https://ios-docs.dev/app-transport-security/)
// 📅2024/01/12Fr
import Foundation

public typealias candle = (
  date: String, open: Double, high: Double, low: Double,
  close: Double, volume: Double
)
public typealias xtick = (date: Date?, norm: Int, st: Bool)
// FIXME: conflicting code vs ticker

// MARK: VM
public class VM: ObservableObject {
  @Published public var ar: [candle] = []
  //  @Published public var isLoading: Bool = true
  @Published public var ticker: String = "1301"
  //  @Published public var ar: [candle] = []
  var cancelBag = Set<AnyCancellable>()
  public init(ar: [candle] = dummy, ticker: String = "0000") {
    print("N225")
    self.ar = ar
    self.ticker = ticker
  }
  
  public init() {
//    Task {
//      ar = try! await Networker.fetchHist(ticker) // 挙動がおかしい
//    }
    bind()
  }

  public var max: Double {
    ar.reduce(into: -Double.infinity) { r, e in
      r = [e.1, e.2, e.3, e.4, r].max()!
    }
  }
  public var min: Double {
    ar.reduce(into: +Double.infinity) { r, e in
      r = [e.1, e.2, e.3, e.4, r].min()!
    }
  }
  public var vmax: Double {
    ar.reduce(into: -Double.infinity) { r, e in
      r = [e.5, r].max()!
    }
  }
  public var qheight: Double { max - min }  //quote axis hieght
  public var yticks: [Double] {
    var ret: [Double] = []
    let n = floor(log10(qheight))  // number of digits
    let npow: Double = pow(10, n)  // 1160.0, 1000.0
    let r: Double = qheight / npow  // 1.16
    var interval: Double = 0.0
    switch r {
    case 1.0..<3.0:
      interval = npow / 4.0  // 250.0
    case 3.0..<5.0:
      interval = npow
    case 5.0..<10.0:
      interval = npow * 2.0
    default:
      interval = npow
    }
    //    debugPrint("Candle: \(qheight)")
    //    debugPrint("Candle: \(npow)")
    let start: Double = Double(Int(min / interval) + 1) * interval
    var tick: Double = start
    while tick < max {
      ret.append(tick)
      tick += interval
    }
    return ret
  }
  public var xticks: [xtick] {
    var ret: [xtick] = []
    var st: Bool = false
    var e_d = extractMonth(ar[0].date)
    for (i, e) in ar.enumerated() {
      if e_d != extractMonth(e.date) { st = true }
      ret.append((Date(dateString: e.date), i, st))
      st = false
      e_d = extractMonth(e.date)
    }
    // retをサーチして一つもtrueが無いと先頭をtrueに！
    if ret.map({ e in e.st }).allSatisfy({ $0 == false }) {
      ret[0].st = true
    }
    return ret
  }
  // MARK: - 日付文字列が月(Int)だけ取出し
  public func extractMonth(_ str: String) -> Int? {
    return Int(str.components(separatedBy: "/")[1])
  }
  // VM
  func bind() {
    $ticker /*.dropFirst(1)*/.flatMap { e in
      Future<[candle], Error> { promise in
        //        guard let self else { return }; isLoading = true
        //        print("isLoading = \(isLoading)")
        //        let baseUrl = "https://tw.local/jsonS/", str = baseUrl + e
        //        let baseUrl = "https://192.168.0.50/jsonS/", str = baseUrl + e
        let baseUrl = "https://stock.bad.mn/jsonS/"
        let str = baseUrl + e
        let url = URL(string: str)!
        let request = URLRequest(url: url)
        Task {
          var ar: [[Any]] = []
          var result: [candle] = []
          do {
            let (data, res) = try await URLSession.shared.data(for: request)
            let nsRes = res as! HTTPURLResponse
            print("response = \(nsRes.statusCode)")

            if let jsonArray = try? JSONSerialization.jsonObject(
              with: data,
              options: []) as? [[Any]]
            {
              ar = jsonArray
            }
            result = ar.map { subArray in
              let date = subArray[0] as! String
              let open = subArray[1] as! Double
              let high = subArray[2] as! Double
              let low = subArray[3] as! Double
              let close = subArray[4] as! Double
              let volume = subArray[5] as! Double
              return (date, open, high, low, close, volume)
            }
            promise(.success(result))  //promiseはclosureで引数はResult. 非同期処理の結果を下流に
          } catch {
            print("***error*** = \(error)")
            //            fatalError("*** catch ***")
            promise(.failure(error))
          }
        }
      }
    }
    //    .catch { err in print("catch = \(err)"); fatalError("catch"); Just(-1) }
    .receive(on: RunLoop.main)
    .sink {
      print("sink err = \($0)")
    } receiveValue: { [weak self] in
      guard let self else { return }
      ar = $0
      print("sink = \($0.count), \(ticker)")
      //      isLoading = false
      //      print("isLoading = \(isLoading)")
    }
    .store(in: &cancelBag)
  }
}  // end of class
