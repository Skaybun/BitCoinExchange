//
//  CoinManager.swift
//  BitCoinExchange
//
//  Created by Ali KINU on 24.04.2023.
//

import Foundation
protocol CoinManagerDelegate {
    func didUpdateCoin(price: String, currency: String)
    func didFailWithError(error: Error)
}
struct CoinManager {
    var delegate : CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "02827A0E-A47E-44CF-93FA-8C081881C2C3"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR","TRY"]
    
    func getCoinPrice (for currency : String ){
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print(urlString)
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let ratedPrice = parseJSON(safeData){
                        let bitcoinPrice = String(format: "%.2f", ratedPrice)
                        delegate?.didUpdateCoin(price: bitcoinPrice, currency: currency)
                        
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ cData : Data) -> Double?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: cData)
            let ratedPrice = decodedData.rate
            return ratedPrice
          
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
