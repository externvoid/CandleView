// 📅2022/04/12Tu
import Foundation

public typealias candle = (date: String, open: Double, high: Double, low: Double,
                    close: Double, volume: Double)
public typealias gridline = (quote: Double, norm: Double)
public typealias xtick = (date: Date?, norm: Double)
 
public struct Candle {
  public static let ar: [candle] = [
    // 0        , 1   , 2   , 3   , 4   , 5
    ("2015/4/27",20063,20069,19909,19983,187004),
    ("2015/4/28",20068,20133,20031,20058,208721),
    ("2015/4/30",19847,19852,19502,19520,271949),
    ("2015/5/1",19510,19549,19399,19531,223184),
    ("2015/5/7",19356,19461,19257,19291,236567),
    ("2015/5/8",19315,19458,19302,19379,256526),
    ("2015/5/11",19637,19679,19586,19620,289377),
    ("2015/5/12",19608,19626,19467,19624,273127),
    ("2015/5/13",19568,19791,19494,19764,279159),
    ("2015/5/14",19661,19717,19546,19570,257484),
    ("2015/5/15",19693,19750,19633,19732,254872),
    ("2015/5/18",19766,19890,19741,19890,276495),
    ("2015/5/19",19977,20087,19946,20026,258423),
    ("2015/5/20",20175,20278,20148,20196,257091),
    ("2015/5/21",20215,20320,20175,20202,252498),
    ("2015/5/22",20208,20278,20130,20264,207480),
    ("2015/5/25",20331,20417,20318,20413,205248) ]
  public static let max = ar.reduce(into: -Double.infinity, { r, e in
    r = [e.1, e.2, e.3, e.4, r].max()!
  })
  public static let min = ar.reduce(into: +Double.infinity, { r, e in
    r = [e.1, e.2, e.3, e.4, r].min()!
  })
  public static let vmax = ar.reduce(into: -Double.infinity, { r, e in
    r = [e.5, r].max()!
  })
  static let qheight = max - min
  public static let ar2: [candle] = ar.map{ ( $0.0, ($0.1 - min) / qheight,
    ($0.2 - min) / qheight,
    ($0.3 - min) / qheight, ($0.4 - min) / qheight, $0.5 / vmax )
  }
  public static let ticks2: [gridline] = ticks.map{
    ($0, ($0 - min)/qheight)  }
  public static var ticks: [Double] {
    var ret: [Double] = []
    let n =  floor(log10(qheight)) // number of digits
    let npow: Double = pow(10, n) // 1160.0, 1000.0
    let r: Double = qheight/npow // 1.16
    var interval: Double = 0.0
    switch r {
      case 1.0..<3.0:
        interval = npow / 4.0 // 250.0
      case 3.0..<5.0:
        interval = npow
      case 5.0..<10.0:
        interval = npow * 2.0
      default:
        interval = npow
    }
    debugPrint(qheight)
    debugPrint(npow)
    let start: Double = Double(Int(min / interval) + 1) * interval
    var tick: Double = start
    while tick < max {
      ret.append(tick)
      tick += interval
    }
    return ret
  }
  public static let xticks: [xtick] = {
    var ret: [xtick] = []
    for (i, e) in ar.enumerated() {
      ret.append((Date(dateString: e.date), Double(i)))
    }
    return ret
  }()
}
//
private let formatter: DateFormatter = {
    let formatter: DateFormatter = DateFormatter()
    formatter.timeZone = NSTimeZone.system
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
}() // 理由は不明だが、計算型プロパティは不可。clousureの即時呼出で値をセット

public extension Date {

    // Date→String
    func string(format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> String {
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    // String → Date
    init?(dateString: String, dateFormat: String = "yyyy/MM/dd") {
        formatter.dateFormat = dateFormat
        guard let date = formatter.date(from: dateString) else { return nil }
        self = date
    }
}
extension Array {
  func revert<T>(ar: Array<T>) -> Array<T> {
    var ret: [T] = []
    for e in ar.reversed() {
      ret.append(e)
    }
    return ret
  }
}

// [新しいアプリを作るときによく使うSwift Extension集 - Qiita](https://qiita.com/WorldDownTown/items/cf59b0c70da9da61a875)
//Date().string(format: "yyyy/MM/dd") // 2017/02/26
//Date(dateString: "2016-02-26T10:17:30Z")  // Date
// reduceの使い方、into: 初期値、r: 戻値、e: iterated element
// heightを与えて..., e/quoteH * height, quote: 取引値、
// heightを与えず..., e - min /quoteH, quote: 取引値、
// quoteH = max - min
