//
//  detailViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/07/04.
//

import UIKit

class detailViewController: UIViewController {

    @IBOutlet weak var datailView: UIView!
    @IBOutlet weak var optionView: UIView!
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var priorityText: UITextField!
    @IBOutlet weak var finishedText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: TaskDataDeleteDelegate?
    
    var data: ToDoCellDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackView()
        setBlur()
        appearData()
        print("sadasdasdasdsasd \(delegate)")
    }
    
    // radius 설정
    func initBackView() {
        
        self.view.backgroundColor = .clear
        datailView.layer.cornerRadius = datailView.bounds.height / 20
        optionView.layer.cornerRadius = optionView.bounds.height / 10
    }
    
    // 배경 blur 처리
    func setBlur() {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualBlur = UIVisualEffectView(effect: blurEffect)
        
        visualBlur.frame = view.frame
        
        self.view.insertSubview(visualBlur, at: 0)
    }
    
    //view 터치 시 view 종료
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
    
    // delete to task
    @IBAction func deleteToTask(_ sender: Any) {
        
        guard let taskData = data else { return }
        delegate?.deleteTaskData(taskData)
        
        self.dismiss(animated: true)
    }
    
}

extension detailViewController {
    
    func appearData() {
        
        guard let detailData = data else { return }
        
        print(detailData)
        
        titleText.text = detailData.title
        dateText.text = detailData.startDate.description
        priorityText.text = detailData.priority.description
        finishedText.text = detailData.isFinish.description
        descriptionText.text = detailData.description
    }
}
