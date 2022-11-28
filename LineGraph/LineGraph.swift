//
//  LineGraph.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/17.
//

import SwiftUI

struct LineGraph: View {
    // MARK: 定義狀態變數

    var data: [Double] // 價位資料
    var profit: Bool // 漲跌狀況，決定紅色或綠色
    @State private var currentPlot = "" // 目前選中的價位
    @State private var shouldShowPlot = false // 是否顯示細節指示器
    @State private var offset: CGSize = .zero // 細節指示器的位置
    @State private var graphProgress: CGFloat = 0 // 線段動畫進度

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
            let maxValue = (data.max() ?? 0)
            let minValue = (data.min() ?? 0)
            // 將資料轉換為CGPoint
            let points: [CGPoint] = data.enumerated().compactMap { item in
                let x = segmentWidth * CGFloat(item.offset)
                let y = segmentHeight * ((item.element - minValue) / (maxValue - minValue))
                return CGPoint(x: x, y: -y + size.height)
            }

            // MARK: 定義資料線段與背景

            ZStack {
                // 漸層線段
                AnimatedGraphPath(progress: graphProgress, points: points)
                    .fill(profit ? .red : .green)
                // .fill(LinearGradient(colors: [.green, .red], startPoint: .leading, endPoint: .trailing))

                // 先畫出整個漸層，再根據線段裁剪顯示範圍
                fillBG()
                    .opacity(graphProgress)
                    .clipShape(
                        Path { path in
                            path.addLines(points)
                            path.addLine(to: CGPoint(x: size.width, y: size.height))
                            path.addLine(to: CGPoint(x: 0, y: size.height))
                        }
                    )
                    .padding(.top, 14)
            }

            // 在線段上方放置一個浮動細節指示器，隨著手指點擊拖曳移動
            // 對齊要設為左側&底部，因為overlay的尺寸跟上層(zstack)相同
            // 如果不額外指定對齊，預設會是置中，這樣後續套用offset會用偏移
            .overlay(alignment: .bottomLeading) {
                indicatorView()
                    // 是否顯示指示器
                    .opacity(shouldShowPlot ? 1 : 0)
                    // 如果滑鼠靠近螢幕邊緣，要將文字往畫面中間移動，否則會被切掉
                    .offset(x: offset.width < 10 ? 20 : 0)
                    .offset(x: offset.width > size.width - 10 ? -20 : 0)
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
                    currentPlot = data[index].convertToCurrency()
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
                })
        }
        .overlay { labelView() }
        .padding(10)
        .onAppear {
            // 一進入畫面就開始繪製線段
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 1.2)) {
                    graphProgress = 1
                }
            }
        }
        .onChange(of: data) { _ in
            // 資料更新要重新畫出線段
            // 但因為線段已經在畫面，就算data更新，progress也不會跟著更新，所以要先歸零，再重新開始動畫
            graphProgress = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 1.2)) {
                    graphProgress = 1
                }
            }
        }
    }

    // 定義浮動細節指示器，跟隨手指移動
    @ViewBuilder
    func indicatorView() -> some View {
        VStack(spacing: 0) {
            // 顯示目前價位
            Text(currentPlot)
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(.gray, in: Capsule())

            // 線段
            Rectangle()
                .fill(.gray)
                .frame(width: 1, height: 45)

            // 在線段上的原點
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

        // 移動指示器到手指的位置
        .offset(offset)
        // 讓指示器x軸置中(扣掉一半寬度 80/2=40)，y軸對齊circle中心(加上circle一半寬度 16/2=8)
        .offset(x: -40, y: 8)
    }

    // 顯示資料的最大&最小值
    @ViewBuilder
    func labelView() -> some View {
        VStack {
            let max = data.max() ?? 0
            let min = data.min() ?? 0
            // 最大值
            Text(max.convertToCurrency())
                .font(.caption.bold())
                .offset(y: -20)

            Spacer()

            VStack(alignment: .leading) {
                // 最小值
                Text(min.convertToCurrency())
                    .font(.caption.bold())
                Text("last 7 days")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .offset(y: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 將線段封閉之後，根據漲跌狀況(紅、綠)，使用漸層繪製線段背景
    @ViewBuilder
    func fillBG() -> some View {
        let c: Color = profit ? .red : .green
        let c1 = Array(repeating: c.opacity(0.1), count: 5)
        let c2 = Array(repeating: Color.clear, count: 2)
        let colors: [Color] = [c.opacity(0.3), c.opacity(0.2)] + c1 + c2
        LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}

// MARK: 建立一個自訂path的shape

/// 根據傳入的頂點 (points) 畫出線段
/// 且具有動畫屬性 (progress) 能控制畫線的進度
struct AnimatedGraphPath: Shape {
    var progress: CGFloat
    var points: [CGPoint]

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        return Path { path in
            // 根據頂點將線段依次連起來
            path.move(to: CGPoint.zero)
            path.addLines(points)
        }
        // 根據動畫進度，回傳指定部分的路徑
        .trimmedPath(from: 0, to: progress)
        // 線段的寬度與樣式
        .strokedPath(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
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
