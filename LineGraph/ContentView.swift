//
//  ContentView.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Text("ok")
            VStack {
                GeometryReader { _ in
                }
            }
            .background(.red)
        }
        .frame(height: 300)
        .padding()
        .background(.yellow)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
