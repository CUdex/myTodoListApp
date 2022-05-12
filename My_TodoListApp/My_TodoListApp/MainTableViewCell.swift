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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // custom cell의 layout 부분을 정의
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }
    
}
