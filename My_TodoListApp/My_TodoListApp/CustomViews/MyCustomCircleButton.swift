//
//  MyCustomCircleButton.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/18.
//

import UIKit

class MyCustomCircleButton: UIButton {
    
    //위치 이니셜라이즈
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .blue
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        self.setPreferredSymbolConfiguration(.init(pointSize: 40, weight: .regular, scale: .default), forImageIn: .normal)
        self.tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
