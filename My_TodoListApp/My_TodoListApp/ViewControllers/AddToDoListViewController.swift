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
        self.downKeyboardWhenTappedBackground()
        
        taskLable.delegate = self
        discriptionText.delegate = self
        
        //키보드에 따라 view를 올리는 기능 구현
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.addKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        //self.removeKeyboardNotifications()
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

        //done 누르면 키보드 내려감
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let maxLenth = 100
        
        guard let str = textView.text else { return false }
        
        if str.count >= maxLenth && range.length == 0 {
            return false
        }
        
        return true
    }
    
    //MARK: - done 버튼을 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
