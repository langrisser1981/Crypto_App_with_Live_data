//
//  LineGraph.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/17.
//

import SwiftUI

struct LineGraph: View {
    // MARK: 定義狀態變數

    var data: [Double]
    @State private var currentPlot = ""
    @State private var shouldShowPlot = false
    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            /*
             MARK: 資料轉換與相關尺寸參數
             segmentWidth: 線段寬度
             segmentHeight: 線段高度
             maxValue: 資料最大值
             points: 將資料轉換為CGPoint
             */
            let size = proxy.size
            let segmentWidth = size.width / CGFloat(data.count - 1)
            let segmentHeight = size.height
            let maxValue = (data.max() ?? 0) + 100
            let points: [CGPoint] = data.enumerated().compactMap { item in
                let x = segmentWidth * CGFloat(item.offset)
                let y = segmentHeight * (item.element / maxValue)
                return CGPoint(x: x, y: -y + size.height)
            }

            // MARK: 定義資料線段與背景

            ZStack {
                Path { path in
//                    path.move(to: CGPoint.zero)
                    path.addLines(points)
                }
                .strokedPath(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .fill(LinearGradient(colors: [.green, .red], startPoint: .leading, endPoint: .trailing))

                fillBG()
                    .clipShape(
                        Path { path in
                            path.addLines(points)
                            path.addLine(to: CGPoint(x: size.width, y: size.height))
                            path.addLine(to: CGPoint(x: 0, y: size.height))
                        }
                    )
                    .padding(.top, 12)
            }

            // MARK: 定義浮動指示器，跟隨手指移動

            // **關鍵** overlay的對齊設定要設為對齊左側&底部
            // 因為overlay的尺寸跟上層(zstack)相同，如果不額外指定對齊，預設會是置中，這樣後續套用offset會用偏移
            .overlay(alignment: .bottomLeading) {
                VStack(spacing: 0) {
                    Text(currentPlot)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(.gray, in: Capsule())
                        // 如果滑鼠靠近螢幕邊緣，要將文字往畫面中間移動，否則會被切掉
                        .offset(x: offset.width < 10 ? 20 : 0)
                        .offset(x: offset.width > size.width - 10 ? -20 : 0)

                    Rectangle()
                        .fill(.gray)
                        .frame(width: 1, height: 45)

                    Circle()
                        .fill(.gray)
                        .frame(width: 16)
                        .overlay {
                            Circle()
                                .fill(.white)
                                .frame(width: 6)
                        }
                }
                // 給予指示器一個固定尺寸，方便後續計算偏移量時，x軸置中，y軸對齊circle中心
                .frame(width: 80, height: 80)
                .opacity(shouldShowPlot ? 1 : 0)
                .offset(offset)
                // 讓指示器x軸置中(扣掉一半寬度 80/2=40)，y軸對齊circle中心(加上circle一半寬度 16/2=8)
                .offset(x: -40, y: 8)
            }
            // 定義手勢感應區域
            .contentShape(Rectangle())

            // MARK: 定義拖曳手勢，更新顯示的資料

            .gesture(DragGesture()
                .onChanged { value in
                    let tx = value.location.x
                    // 根據滑鼠位置計算對應的線段索引值，且限制計算結果不小於0，不大於資料數量
                    var index = Int((tx / segmentWidth).rounded())
                    index = max(min(index, points.count - 1), 0)
                    // 更新顯示的文字
                    currentPlot = "$ \(data[index])"
                    // 更新指示器的位置
                    withAnimation(.easeIn(duration: 0.1)) {
                        shouldShowPlot = true
                        offset = .init(width: points[index].x, height: points[index].y - segmentHeight)
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        shouldShowPlot = false
                    }
                }
            )
        }
        // 顯示資料的最大&最小值
        .overlay(content: {
            VStack {
                Text("$ \(Int(data.max() ?? 0))")
                    .font(.caption.bold())
                Spacer()
                Text("$ 0")
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        })
        .padding(10)
    }

    /// 繪製線段背景漸層
    @ViewBuilder
    func fillBG() -> some View {
        let c = Color.red
        let c1 = Array(repeating: c.opacity(0.1), count: 5)
        let c2 = Array(repeating: Color.clear, count: 2)
        let colors: [Color] = [c.opacity(0.3), c.opacity(0.2)] + c1 + c2
        LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(coinProvider: CoinProvider(loader: TestLoader()))
    }
}

// Sample Plot For Graph.....
let samplePlot: [Double] = [
    989, 1200, 750, 790, 650, 950, 1200, 600, 500, 600, 890, 1203, 1400, 900, 1250,
    1600, 1200
]
