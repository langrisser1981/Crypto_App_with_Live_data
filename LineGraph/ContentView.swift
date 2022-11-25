//
//  ContentView.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/12.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var animation
    @StateObject var coinProvider = CoinProvider(loader: URLSession.shared)

    var body: some View {
        VStack {
            // 檢查資料是否已經載入完成
            if let coins = coinProvider.coins, let currentCoin = coinProvider.currentCoin {
                // 載入完成就畫出線段與幣別資訊
                tabView(coins: coins)
                detailView(coin: currentCoin)
                graphView(coin: currentCoin)

            } else {
                // 如果資料還沒有載入完成，就顯示載入進度指示器
                ProgressView()
                    .tint(Color.purple)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//        .background(.gray)
    }

    // MARK: 錢幣資料，包含圖片、名稱、縮寫、金額、漲跌幅

    @ViewBuilder
    func detailView(coin: CoinModel)->some View {
        HStack(alignment: .center) {
            // 載入對應的錢幣圖示，沒完成前放一個預設圖
            AsyncImage(url: URL(string: coin.image)!) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "dollarsign.circle")
            }
            .scaledToFit()
            .frame(width: 50)

            // 名稱與縮寫
            VStack(alignment: .leading) {
                Text(coin.id.uppercased())
                    .font(.title3)
                Text(coin.symbol)
                    .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing) {
                // 目前價位
                Text(coin.current_price.convertToCurrency())
                    .font(.largeTitle.bold())
                    .foregroundColor(coin.price_change_24h > 0 ? .red : .green)

                // 漲跌幅
                HStack {
                    // 根據漲跌顯示不同顏色，中西對紅綠的定義不一樣
                    Text(coin.price_change_24h.convertToCurrency())
                        .foregroundColor(coin.price_change_24h > 0 ? .red : .green)
                        .frame(maxWidth: .infinity)

                    // 利用c string format將數字精度更改為兩位%.2f，並加上百分比符號
                    // 格式指定一律以%為開始字元，型別指定(d(整數),s(字元),f(浮點數))為結束字元；中間的.2為精度小數點後兩位
                    Text("\(String(format: "%.2f", coin.price_change_24h))%")
                        .foregroundColor(coin.price_change_24h > 0 ? .red : .green)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            // 這邊利用fixedSize將vstack的尺寸(寬度)鎖定在理想尺寸，也就是內部元件最大的寬度
            // 而不會因為內部元件在frame中指定infinity，就讓vstack往外延伸，佔據其他可用空間
            .fixedSize(horizontal: true, vertical: false)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    // MARK: 錢幣選單，可以切換要看的幣別

    @ViewBuilder
    func tabView(coins: [CoinModel])->some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(coins) { coin in
                    tabItemView(coin: coin)
                }
            }
        }
        // 錢幣選單外框線
        .background {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        }
    }

    // MARK: 按鈕，點擊可以切換要看的錢幣

    @ViewBuilder
    func tabItemView(coin: CoinModel)->some View {
        Text(coin.symbol.uppercased())
            .font(.callout.bold())
            .foregroundColor(coinProvider.currentCoin?.id == coin.id ? .white : .gray)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
            .background(content: {
                // 背景透過matchedGeometryEffect，在切換時產生移動效果
                if coinProvider.currentCoin?.id == coin.id {
                    Rectangle()
                        .fill(Color.gray)
                        .matchedGeometryEffect(id: "SEGMENTEDTAB", in: animation)
                }
            })
            .onTapGesture {
                withAnimation { coinProvider.currentCoin = coin }
            }
    }

    // MARK: 折線圖

    @ViewBuilder
    func graphView(coin: CoinModel)->some View {
        LineGraph(data: coin.last_7days_price.price)
            .frame(height: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(coinProvider: CoinProvider(loader: TestLoader()))
    }
}

extension Double {
    // 將數值格式轉換為錢幣顯示專用，加上錢符號，每百位逗號
    func convertToCurrency()->String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: .init(value: self)) ?? ""
    }
}
