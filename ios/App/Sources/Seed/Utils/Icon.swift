import SwiftUI

// Icon unifies custom font glyphs and SF Symbols.
//
// Usage:
//   Icon(.mic)
//   Icon(.mic, size: 24)
//   Icon("person.circle", size: .t3)
//   let src: IconSource = .font(.mic)   // store identifier, render later
//
// color is optional — nil inherits foreground from the SwiftUI environment.

/// Stores just the icon identifier without size/color, so parent views can
/// render it at whatever size and color they need.
enum IconSource: Equatable {
    case font(FontIcon)
    case system(String)
}

struct IconConfig {
    let source: IconSource
    let size: CGFloat?
    let color: Color?

    init(_ source: IconSource, size: CGFloat? = nil, color: Color? = nil) {
        self.source = source
        self.size = size
        self.color = color
    }

    init(_ systemName: String) { self.init(.system(systemName)) }
    init(_ systemName: String, size: CGFloat) { self.init(.system(systemName), size: size) }
    init(_ systemName: String, size: FontSize) { self.init(.system(systemName), size: size.rawValue) }

    init(_ fontIcon: FontIcon) { self.init(.font(fontIcon)) }
    init(_ fontIcon: FontIcon, size: CGFloat) { self.init(.font(fontIcon), size: size) }
    init(_ fontIcon: FontIcon, size: FontSize) { self.init(.font(fontIcon), size: size.rawValue) }

}


struct Icon: View {
    let source: IconSource
    let size: CGFloat

    init (_ source: IconSource, size: CGFloat? = nil) {
        self.source = source;
        self.size = size ?? FontSize.t4.rawValue
    }

    init(_ systemName: String) { self.init(.system(systemName)) }
    init(_ systemName: String, size: CGFloat) { self.init(.system(systemName), size: size) }
    init(_ systemName: String, size: FontSize) { self.init(.system(systemName), size: size.rawValue) }

    init(_ fontIcon: FontIcon) { self.init(.font(fontIcon)) }
    init(_ fontIcon: FontIcon, size: CGFloat) { self.init(.font(fontIcon), size: size) }
    init(_ fontIcon: FontIcon, size: FontSize) { self.init(.font(fontIcon), size: size.rawValue) }
    
    var body: some View {
        switch source {
        case .font(let icon):
            Text(icon.rawValue).font(.custom("iconfont", size: size))
        case .system(let name):
            Image(systemName: name).font(.system(size: size))
        }
    }
}

// Keep syncing with iconfont.json
enum FontIcon: String {
    case icoShow = "\u{e635}"
    case icoHidden = "\u{e65f}"
    case exchange = "\u{e60f}"
    case closedEye = "\u{e610}"
    case cross = "\u{e611}"
    case edit = "\u{e612}"
    case labelO = "\u{e613}"
    case toys = "\u{eaad}"
    case linearEleOtherPrizeTrophy = "\u{e717}"
    case linearEleOtherToiletPaper = "\u{e718}"
    case linearNewOtherTechnologyEngineAtomNuclear = "\u{e724}"
    case broadcast = "\u{e7ec}"
    case appsO = "\u{e60c}"
    case bookmarkO = "\u{e60d}"
    case awardO = "\u{e600}"
    case barChartO = "\u{e601}"
    case balancePay = "\u{e602}"
    case chartTrendingO = "\u{e603}"
    case hotelO = "\u{e604}"
    case giftO = "\u{e605}"
    case gemO = "\u{e606}"
    case goodsCollectO = "\u{e607}"
    case paid = "\u{e608}"
    case flagO = "\u{e609}"
    case smileO = "\u{e60a}"
    case wapHome = "\u{e60b}"
    case settingsDev = "\u{e6cd}"
    
    // Additional icons from iconfont.json
    case notification = "\u{e679}"
    case mic = "\u{e678}"
    case minus = "\u{e67a}"
    case group = "\u{e719}"
    case people = "\u{e615}"
    case right = "\u{e665}"
    case left = "\u{e666}"
    case level = "\u{e688}"
    case upgrade = "\u{e62a}"
    case increaseFill = "\u{e8d5}"
    case iconOptionIncrease = "\u{e620}"
    case lineIncrease = "\u{e6b2}"
    case replace = "\u{e786}"
    case add = "\u{e60e}"
    case chartPie = "\u{e668}"
    case download = "\u{e66c}"
    case picture = "\u{e67c}"
    case share = "\u{e67d}"
    case select = "\u{e67e}"
    case calendar = "\u{e699}"
    // 新增：iconfont.json未包含的图标
    case comment = "\u{e616}"
    case check = "\u{e617}"
    case close = "\u{e618}"
    case income = "\u{e619}"
    case info = "\u{e61a}"
    case minusAlt = "\u{e61b}" // 避免与已存在的 minus 重名
    case expense = "\u{e61d}"
    case tag = "\u{e61e}"
    case tagFill = "\u{e61f}"
    case warn = "\u{e621}"
    case update = "\u{e64c}" // 避免与已存在的 update 重名
    case reconcile = "\u{e672}"
    case bottomLeft = "\u{ed4e}"
    case topRight = "\u{ed53}"
    case up = "\u{e61c}"
    case down = "\u{e614}"
    case refresh = "\u{e71e}"
    case icon_service_config = "\u{e63c}"
    case moneyExchange = "\u{e7c6}"
    case calculator = "\u{e72d}"
    case calc = "\u{e622}"
    case muma = "\u{e63f}"
    case huojian = "\u{e623}"
    case spyLine = "\u{ef61}"
    case ghost = "\u{e7f3}"
    case appicon = "\u{e67f}"
}
