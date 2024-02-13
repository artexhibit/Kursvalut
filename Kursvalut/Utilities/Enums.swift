import Foundation

enum DateFormat: String {
    case dashYMD = "yyyy-MM-dd"
    case dotDMY = "dd.MM.yyyy"
    case slashYMD = "yyyy/MM/dd"
    case slashDMY = "dd/MM/yyyy"
}

enum QuickActionType: String {
    case openCurrencyScreen = "openCurrencyScreen"
    case openConverterScreen = "openConverterScreen"
    case showCBRFSource = "showCBRFSource"
    case showForexSource = "showForexSource"
}
