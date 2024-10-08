import Combine
// 📅2023/06/01Th
// 📅2024/01/12Fr
import Foundation

public typealias candle = (
  date: String, open: Double, high: Double, low: Double,
  close: Double, volume: Double
)
public typealias xtick = (date: Date?, norm: Int, st: Bool)
// conflicting code vs ticker
public class VM: ObservableObject {
  public var ar: [candle] = []
  public init(ar: [candle] = dummy, ticker: String = "N225") {
    print("N225")
    self.ar = ar
    self.ticker = ticker
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
  @Published public var ticker: String = "1301"
  //  @Published public var ar: [candle] = []
  var cancelBag = Set<AnyCancellable>()
  func bind() {
    $ticker.dropFirst(1).flatMap { e in
      Future<[candle], Error> { promise in
        let baseUrl = "http://stock.bad.mn/jsonS/"
        let str = baseUrl + e
        let url = URL(string: str)!
        let request = URLRequest(url: url)
        Task {
          var ar: [[Any]] = []
          var result: [candle] = []
          do {
            let (data, _) = try await URLSession.shared.data(for: request)
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
            print(error)
            promise(.failure(error))
          }
        }
      }
    }
    .sink {
      print($0)
    } receiveValue: { [weak self] in
      guard let self else { return }
      self.ar = $0
    }
    .store(in: &cancelBag)
  }
  public init() {
    bind()
    //    print("bind OK")
    sleep(3)  // Playgroundだから必要なのか？
  }
}  // end of class
extension VM {
  public static let dummy: [candle] = [
    // 0        , 1   , 2   , 3   , 4   , 5
    ("2015/4/27", 20063, 20069, 19909, 19983, 187004),
    ("2015/4/28", 20068, 20133, 20031, 20058, 208721),
    ("2015/4/30", 19847, 19852, 19502, 19520, 271949),
    ("2015/5/1", 19510, 19549, 19399, 19531, 223184),
    ("2015/5/7", 19356, 19461, 19257, 19291, 236567),
    ("2015/5/8", 19315, 19458, 19302, 19379, 256526),
    ("2015/5/11", 19637, 19679, 19586, 19620, 289377),
    ("2015/5/12", 19608, 19626, 19467, 19624, 273127),
    ("2015/5/13", 19568, 19791, 19494, 19764, 279159),
    ("2015/5/14", 19661, 19717, 19546, 19570, 257484),
    ("2015/5/15", 19693, 19750, 19633, 19732, 254872),
    ("2015/5/18", 19766, 19890, 19741, 19890, 276495),
    ("2015/5/19", 19977, 20087, 19946, 20026, 258423),
    ("2015/5/20", 20175, 20278, 20148, 20196, 257091),
    ("2015/5/21", 20215, 20320, 20175, 20202, 252498),
    ("2015/5/22", 20208, 20278, 20130, 20264, 207480),
    ("2015/5/25", 20331, 20417, 20318, 20413, 205248),
  ]
  public static let dummy2: [candle] = [
    ("1987/9/5", 25355, 25355, 25355, 25355, 42972),
    ("1987/9/7", 25004, 25004, 25004, 25004, 37928),
    ("1987/9/8", 25204, 25204, 25204, 25204, 54604),
    ("1987/9/9", 24937, 24937, 24937, 24937, 62002),
    ("1987/9/10", 24795, 24795, 24795, 24795, 56583),
    ("1987/9/11", 24828, 24828, 24828, 24828, 86229),
    ("1987/9/14", 24954, 24954, 24954, 24954, 75032),
    ("1987/9/16", 24967, 24967, 24967, 24967, 82164),
    ("1987/9/17", 24855, 24855, 24855, 24855, 120292),
    ("1987/9/18", 24844, 24844, 24844, 24844, 160561),
    ("1987/9/21", 24912, 24912, 24912, 24912, 91207),
    ("1987/9/22", 24866, 24866, 24866, 24866, 127891),
    ("1987/9/24", 24944, 24944, 24944, 24944, 152886),
    ("1987/9/25", 25095, 25095, 25095, 25095, 94594),
    ("1987/9/26", 25512, 25512, 25512, 25512, 145413),
    ("1987/9/28", 25837, 25837, 25837, 25837, 150412),
    ("1987/9/29", 25998, 25998, 25998, 25998, 117722),
    ("1987/9/30", 26010, 26010, 26010, 26010, 128074),
    ("1987/10/1", 25721, 25721, 25721, 25721, 146229),
    ("1987/10/2", 25862, 25862, 25862, 25862, 83769),
    ("1987/10/3", 26006, 26006, 26006, 26006, 57241),
    ("1987/10/5", 26018, 26018, 26018, 26018, 78606),
    ("1987/10/6", 26088, 26088, 26088, 26088, 114217),
    ("1987/10/7", 25952, 25952, 25952, 25952, 110088),
    ("1987/10/8", 26286, 26286, 26286, 26286, 167081),
    ("1987/10/9", 26338, 26338, 26338, 26338, 150361),
    ("1987/10/12", 26284, 26284, 26284, 26284, 66232),
    ("1987/10/13", 26400, 26400, 26400, 26400, 133672),
    ("1987/10/14", 26646, 26646, 26646, 26646, 140180),
    ("1987/10/15", 26428, 26428, 26428, 26428, 95289),
    ("1987/10/16", 26366, 26366, 26366, 26366, 76785),
  ]

}

// [新しいアプリを作るときによく使うSwift Extension集 - Qiita](https://qiita.com/WorldDownTown/items/cf59b0c70da9da61a875)
//Date().string(format: "yyyy/MM/dd") // 2017/02/26
//Date(dateString: "2016-02-26T10:17:30Z")  // Date
// reduceの使い方、into: 初期値、r: 戻値、e: iterated element
// heightを与えて..., e/quoteH * height, quote: 取引値、
// heightを与えず..., e - min /quoteH, quote: 取引値、
// quoteH = max - min
