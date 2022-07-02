//
//  CalendarCollectionViewCell.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/29.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("CalendarCollectionViewCell - awakeFromNib")
    }
    
}
