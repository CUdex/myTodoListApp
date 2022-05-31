//
//  AddToDoListViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/22.
//

import UIKit

class AddToDoListViewController: UIViewController {
    
    @IBOutlet weak var taskText: UITextField!
    @IBOutlet weak var discriptionText: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddToDoListViewController - viewDidLoad")
        self.downKeyboardWhenTappedBackground()
        taskText.delegate = self
        discriptionText.delegate = self
        //scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 400)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
    }
    
    //MARK: - 키보드 만큼 스크롤 조절
    override func keyboardWillShow(_ noti: NSNotification) {
        guard let userInfo = noti.userInfo else {
            return
        }
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardFrame, to: view.window)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    // 복구
    override func keyboardWillHide(_ noti: NSNotification) {
        
        //스크롤 뷰 최상단 이동
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        
        
//        let contextInset = UIEdgeInsets.zero
//        scrollView.contentInset = contextInset
//        scrollView.scrollIndicatorInsets = contextInset
//
//        guard let userInfo = noti.userInfo else {
//            return
//        }
//
//        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardFrame, to: view.window)
//
//        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -(keyboardViewEndFrame.height + 100), right: 0)
//        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
}


//MARK: - 글자 수 제한
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
