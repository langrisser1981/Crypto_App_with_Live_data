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
                detailView(coin: currentCoin)
                tabView()
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
        HStack(alignment: .top) {
            Image(systemName: "dollarsign.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
            VStack(alignment: .leading) {
                Text(coin.id)
                    .font(.callout)
                Text(coin.symbol)
                    .font(.caption)
            }
            .background(.yellow)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.red)
    }

    // MARK: 錢幣選單，可以切換要看的幣別

    @ViewBuilder
    func tabView()->some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(coinProvider.coins!) { coin in
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
        Text(coin.symbol)
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
            .frame(height: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(coinProvider: CoinProvider(loader: TestLoader()))
    }
}
