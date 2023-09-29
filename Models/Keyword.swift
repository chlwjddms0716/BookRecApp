//
//  Keyword.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/27.
//

import Foundation

// MARK: - KeywordData
struct KeywordData: Codable {
    let response: KeywordResponse
}

// MARK: - Response
struct KeywordResponse: Codable {
    let resultNum: Int
    let keywords: [KeywordElement]
}

// MARK: - KeywordElement
struct KeywordElement: Codable {
    let keyword: Keyword?
}

// MARK: - KeywordKeyword
struct Keyword: Codable {
    let word: String
    let weight: Double
    
    
}

