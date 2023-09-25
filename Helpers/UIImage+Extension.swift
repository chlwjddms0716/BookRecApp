//
//  UIImage+Extension.swift
//  BookRecApp
//
//  Created by 최정은 on 2023/09/24.
//

import UIKit

extension UIImage {
    
    func resized(to size: CGSize, tintColor: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            // 적용할 tint 색상 설정
            tintColor.setFill()
            // 렌더링 모드 변경 후 이미지 그리기
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func loadImage(imageUrl: String?, completion: @escaping (UIImage) -> Void ) {
        
        if let imgUrl = imageUrl, let url = URL(string: imgUrl){
            DispatchQueue.global().async { [self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        completion(image)
                        return
                    }
                }
            }
        }
        
        completion(UIImage())
    }
}
