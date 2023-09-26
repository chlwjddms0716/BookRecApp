//
//  Constants.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import Foundation

public struct Cell{
    
    static let bookCellIdentifier = "bookCell"
    static let searchBookCellIdentifier = "SearchCell"
    static let myBookCellIdentifier = "MyBookCell"
    static let keywordCellIdentifier = "KeywordCell"
    
    private init(){}
}

public struct BookApi{
    
    static let allBookURL = "https://data4library.kr/api/loanItemSrch?format=json&pageNo=1"
    static let searchBookURL = "https://data4library.kr/api/srchBooks?format=json"
    static let searchBookDescriptionURL = "https://data4library.kr/api/srchDtlList?format=json"
    
    static let apiKeyParam = "authKey=83026cff3c9d40dfccbd982eb52c9c134e2c332abcc02cde1bf1cfdb65149ca4"
    static let sizeParam = "pageSize=50"
    static let searchKeywordSizeParam = "pageSize=30"
    
    
    private init(){}
}

public struct CVCell{
    
    static let spacingWitdh: CGFloat = 1
    static let cellColumns: CGFloat = 2
    static let addHeight: CGFloat = 50
    
    private init(){}
}
