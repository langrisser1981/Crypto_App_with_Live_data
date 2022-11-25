//
//  TestLoader.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/23.
//

import Foundation

class TestLoader: HttpDataLoader {
    func load(from: URL) async throws -> Data {
        // 模擬網路載入所需的時間，隨機停止1~5秒
//        try await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000 ... 5_000_000_000))

        // 取得檔案url
        guard let fileUrl = Bundle.main.url(forResource: "sample.json", withExtension: nil) else {
            throw GraphError.urlError
        }

        // 載入檔案並回傳(格式為data)
        return try Data(contentsOf: fileUrl)
    }
}

func load<T: Decodable>(filename: String) -> T {
    let data: Data

    // 取得檔案url
    guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("could not find file:\(filename)")
    }

    // 載入檔案並回傳(格式為data)
    do {
        // 在do-catch中宣告的變數，其scope只在do-catch範圍中；但在guard敘述中宣告的變數，可以在後面繼續使用
        data = try Data(contentsOf: fileUrl)
    } catch {
        fatalError("could not load file:\(filename), error:\(error)")
    }

    // 將資料轉匯為自訂型別
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("could not parse \(filename) to :\(T.self), error:\(error)")
    }
}
