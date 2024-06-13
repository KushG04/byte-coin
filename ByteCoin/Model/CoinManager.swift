import Foundation

protocol CoinManagerDelegate {
    func updatedPrice(_ coinManager: CoinManager, coin: CoinModel)
    func failedWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "28B7A2E6-1FDD-4565-A4F7-97B5FC4FBA99"
    let currencyArray = ["AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY",
                         "MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var delegate: CoinManagerDelegate?

    func getCoinPrice(for currency: String) {
        let stringURL = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: stringURL)
    }
    
    func performRequest(with stringURL: String) {
        if let url = URL(string: stringURL) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.failedWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let price = self.parseJSON(safeData) {
                        self.delegate?.updatedPrice(self, coin: price)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            let name = decodedData.asset_id_quote
            
            let price = CoinModel(coinPrice: rate, currency: name)
            return price
        } catch {
            delegate?.failedWithError(error: error)
            return nil
        }
    }
    
}
