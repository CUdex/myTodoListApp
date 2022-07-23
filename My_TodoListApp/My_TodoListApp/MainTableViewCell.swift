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
    
    var taskData: ToDoCellDataModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            // cell 선택 시 애니메이션
            UIView.animate(withDuration: 0.5, delay: 0, options: []) {
                self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
            }
        }
    }
    
    // custom cell의 layout 부분을 정의
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 25
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20))
        

    }
    
}
