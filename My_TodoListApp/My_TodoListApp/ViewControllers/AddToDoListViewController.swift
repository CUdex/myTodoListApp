//
//  AddToDoListViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/22.
//

import UIKit

class AddToDoListViewController: UIViewController {
    
    @IBOutlet weak var taskLable: UITextField!
    @IBOutlet weak var discriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddToDoListViewController - viewDidLoad")
        taskLable.delegate = self
    }
}


// MARK: - 글자 수 제한
extension AddToDoListViewController: UITextFieldDelegate, UITextViewDelegate {
    
    //task
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("AddToDoListViewController - textField")

        let maxLenth = 10
        
        guard let text = textField.text else { return false }
        
        if text.count >= maxLenth && range.length == 0 {
            return false
        }
        
        return true
    }
    
    //discription
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("AddToDoListViewController - textView")

        let maxLenth = 200
        
        guard let text = textView.text else { return false }
        
        if text.count >= maxLenth && range.length == 0 {
            return false
        }
        
        return true
    }

}
