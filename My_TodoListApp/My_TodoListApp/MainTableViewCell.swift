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
        print("MainTableViewCell - awakeFromNib")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        print("MainTableViewCell - setSelected")

        if selected {
//            UIView.animate(withDuration: 0.7, delay: 0.1, animations: {
//                  self.transform = CGAffineTransform(translationX: self.contentView.frame.width, y: self.contentView.frame.height)
//            })
            
            // cell 선택 시 애니메이션
            UIView.animate(withDuration: 0.5, delay: 0, options: []) {
                self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
            }

            //let cellXFrame = self.frame.width
            
//            UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [], animations: {
//                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
//                    self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0.1, left: 0.1, bottom: 0.1, right: 0.1))
//                }
                
//                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
//                    self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0.1, left: 0.1, bottom: 0.1, right: 0.1))
//                }
                
//            }, completion: nil)
        } else {
            self.contentView.alpha = 1
        }
    }
    
    // custom cell의 layout 부분을 정의
    override func layoutSubviews() {
        super.layoutSubviews()
        print("MainTableViewCell - layoutSubviews")
        
        contentView.layer.cornerRadius = 25
        //contentView.backgroundColor = .blue
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20))
        

    }
    
}
