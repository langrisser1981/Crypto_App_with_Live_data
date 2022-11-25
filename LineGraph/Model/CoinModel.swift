//
//  CoinModel.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/22.
//

import Foundation

@propertyWrapper struct prefixProfit {
    var wrappedValue: Double

    var projectedValue: String {
        if wrappedValue > 0 {
            return "+\(wrappedValue.formatted())"
        } else {
            return wrappedValue.formatted()
        }
    }
}

extension prefixProfit: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(Double.self)) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: prefixProfit.Type, forKey key: Key) throws -> prefixProfit {
        return (try? decodeIfPresent(type, forKey: key)) ?? prefixProfit(wrappedValue: 0)
    }
}

struct CoinModel: Identifiable, Codable {
    var id: String
    var symbol: String
    var name: String
    var image: String
    var current_price: Double = 0
    var high_24h: Double
    var low_24h: Double
    @prefixProfit var price_change_24h: Double
    var price_change_percentage_24h: Double
    var last_7days_price: GraphModel
    var price_change_7d: (Double, Double) {
        let t1 = last_7days_price.price[0]
        let t2 = last_7days_price.price[last_7days_price.price.count-1]
        let diff = t2-t1
        return (diff, diff / t2)
    }

    // 將json key轉換為自訂的屬性名稱，注意:就算只有改其中一個，也需要全部定義，否則會報錯
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case current_price
        case high_24h
        case low_24h
        case price_change_24h
        case price_change_percentage_24h
        case last_7days_price = "sparkline_in_7d"
    }
}

extension CoinModel {
    static var sample: Self {
        load(filename: "sample.json")
    }
}

struct GraphModel: Codable {
    var price: [Double]
}

let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&sparkline=true&price_change_percentage=24h")
