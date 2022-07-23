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
    
    var taskDataInCell: ToDoCellDataModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //cell 재사용 초기화
    override func prepareForReuse() {
    }
    
    
    //MARK: - selected animation
    override var isHighlighted: Bool {
        didSet {
            guard self.isHighlighted else { return }
            guard let data = taskDataInCell?.priority else { return }
            
            UIView.animate(withDuration: 0.1, animations: {
                
                var cellColor = UIColor.green
                
                switch data {
                case 0 :
                    break
                case 1:
                    cellColor = UIColor.yellow
                default:
                    cellColor = UIColor.red
                    
                }
                self.backgroundColor = cellColor
            }) {
                finished in
                UIView.animate(withDuration: 0.1) {
                    self.backgroundColor = .clear
                }
            }
        }
    }
    
    
    //MARK: - 위치에 따른 Border 추가
    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.tag = 100
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.tag = 101
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.tag = 102
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }

    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.tag = 103
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
    
}
