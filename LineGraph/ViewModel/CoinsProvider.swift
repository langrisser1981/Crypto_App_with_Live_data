//
//  CoinsProvider.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/23.
//

import Foundation

class CoinProvider: ObservableObject {
    @Published var coins: [CoinModel]?
    @Published var currentCoin: CoinModel?
    private var loader: HttpDataLoader

    init(loader: HttpDataLoader) {
        self.loader = loader
        Task {
            await fetch()
        }
    }

    func fetch() async {
        guard let url = url else {
            print("遠端網址錯誤")
            return
        }

        do {
            let data = try await loader.load(from: url)
            let _coins = try JSONDecoder().decode([CoinModel].self, from: data)
            // 在主執行緒中更新coin，讓UI隨著更新
            await MainActor.run {
                coins = _coins
                if let firstcoin = coins?.first {
                    currentCoin = firstcoin
                }
            }
        } catch {
            print(error.localizedDescription)
//            fatalError("抓不到資料")
        }
    }
}
