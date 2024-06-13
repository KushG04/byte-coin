import Foundation

struct CoinModel {
    
    let coinPrice: Double
    let currency: String
    
    var coinPriceString: String {
        return String(format: "%.2f", coinPrice)
    }
    
}
