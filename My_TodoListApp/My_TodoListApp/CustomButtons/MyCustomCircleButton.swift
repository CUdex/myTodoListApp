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
        print("MyCustomCircleButton - init")
        
        self.backgroundColor = .blue
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
