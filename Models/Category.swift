//
//  Category.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/27.
//

import UIKit

struct Category {
    
    let word: String
    let code: String
    var icon: UIImage?
    
}

public struct CategoryManager {
    
    private init() {}
    
    static let categoryArray: [Category] = [
    
        Category(word: "언론", code: "07", icon: UIImage().setCategoryImage(imageName: "news")),
        Category(word: "철학", code: "10", icon: UIImage().setCategoryImage(imageName: "philosophy")),
        Category(word: "심리", code: "18", icon: UIImage().setCategoryImage(imageName: "psychology")),
        Category(word: "논리", code: "17", icon: UIImage().setCategoryImage(imageName: "logic")),
        Category(word: "종교", code: "20", icon: UIImage().setCategoryImage(imageName: "religion")),
        Category(word: "과학", code: "40", icon: UIImage().setCategoryImage(imageName: "science")),
        Category(word: "경제", code: "32", icon: UIImage().setCategoryImage(imageName: "economy")),
        Category(word: "정치", code: "34", icon: UIImage().setCategoryImage(imageName: "political")),
        Category(word: "법학", code: "36", icon: UIImage().setCategoryImage(imageName: "law")),
        Category(word: "수학", code: "41", icon: UIImage().setCategoryImage(imageName: "mathematics")),
        Category(word: "화학", code: "43", icon: UIImage().setCategoryImage(imageName: "chemistry")),
        Category(word: "천문", code: "44", icon: UIImage().setCategoryImage(imageName: "astrology")),
        Category(word: "공학", code: "53", icon: UIImage().setCategoryImage(imageName: "engineering")),
        Category(word: "예술", code: "60", icon: UIImage().setCategoryImage(imageName: "art")),
        Category(word: "언어", code: "70", icon: UIImage().setCategoryImage(imageName: "language")),
        Category(word: "역사", code: "90", icon: UIImage().setCategoryImage(imageName: "history")),
    ]
}
