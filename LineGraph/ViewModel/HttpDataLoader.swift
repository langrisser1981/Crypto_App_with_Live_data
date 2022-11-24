//
//  HttpDataLoader.swift
//  LineGraph
//
//  Created by 程信傑 on 2022/11/23.
//

import Foundation

protocol HttpDataLoader {
    func load(from: URL) async throws -> Data
}

let validStatus = 200 ... 299
extension URLSession: HttpDataLoader {
    func load(from url: URL) async throws -> Data {
        // 抓取遠端資料，同時做型別轉換，並確保轉換後不為nil
        guard let (data, response) = try await self.data(from: url) as? (Data, HTTPURLResponse),
              // 檢查回傳的狀態碼是否有在成功的範圍內
              validStatus.contains(response.statusCode)
        else {
            throw GraphError.networkError
        }

        return data
    }
}
