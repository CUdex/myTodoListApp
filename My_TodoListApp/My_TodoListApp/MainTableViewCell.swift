//
//  MainTableViewCell.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/12.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var listCellTitleLable: UILabel!
    @IBOutlet weak var listCellDate: UILabel!
    @IBOutlet weak var listCellImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.contentView.frame.size.width = 50
        //contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            contentView.alpha = 0.7
                } else {
                    contentView.alpha = 1
                }
    }
    
    // custom cell의 layout 부분을 정의
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 35
        //contentView.backgroundColor = .blue
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        

    }
    
}
