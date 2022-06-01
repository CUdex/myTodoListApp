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
    @IBOutlet weak var startDateText: UITextField!
    @IBOutlet weak var endDateText: UITextField!
    let datePicker = UIDatePicker()
    var startDate = Date()
    var endDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddToDoListViewController - viewDidLoad")
        self.downKeyboardWhenTappedBackground() // 화면 터치시 키보드 내려감
        taskText.delegate = self // 글자 수 제한을 위한 delegate 설정
        discriptionText.delegate = self // ''
        self.placeholderSetting() // textview placeholder 설정을 위한 함수 구현
        datePicker.datePickerMode = .dateAndTime // datepicker 설정
        datePicker.preferredDatePickerStyle = .wheels // wheel 설정
        datePicker.frame = CGRect(x: 0, y: 300, width: self.view.frame.width, height: 200) //datepicker 위치 설정
        //datePicker.addTarget(self, action: #selector(changeDateInPicker(_:)), for: .valueChanged) // 날짜 선택 시 해당 날짜를 저장하는 함수 사용
        
        //pickerview 툴바 추가
        let pickerTool = UIToolbar()
        pickerTool.barStyle = .default
        pickerTool.isTranslucent = true // 툴바 반투명 여부
        pickerTool.sizeToFit() // 서브뷰만큼 툴바 크기를 맞춤
        pickerTool.barTintColor = .gray
        //pickerview 툴바에 버튼 추가
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onClickDone))
        let spaceInBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(onClickCancel))
        pickerTool.setItems([cancelBtn, spaceInBar, doneBtn], animated: true)
        pickerTool.isUserInteractionEnabled = true
        
        //툴바 추가
        startDateText.inputView = datePicker // pickerview 추가
        startDateText.inputAccessoryView = pickerTool // toolbar 추가
        endDateText.inputView = datePicker
        endDateText.inputAccessoryView = pickerTool
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AddToDoListViewController - viewWillAppear")
        self.addKeyboardNotifications()
    }
    
    //MARK: - 텍스트 필드 클릭 시 datepicker 출력 및 텍스트 필드에 세팅
    @objc private func onClickDone() {
        print("AddToDoListViewController - onClickDone")
        
        if startDateText.resignFirstResponder() {
            startDate = datePicker.date
            startDateText.text = changeDateToString(startDate)
        } else {
            endDate = datePicker.date
            endDateText.text = changeDateToString(endDate)
        }
        self.view.endEditing(true)
    }
    @objc private func onClickCancel() {
        print("AddToDoListViewController - onClickCancel")
        self.view.endEditing(true)
    }
    
    //MARK: - 날짜 선택 시 변수에 날짜 저장하도록 구현
    private func changeDateToString(_ dateDate: Date) -> String {
        print("AddToDoListViewController - changeDateToString")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd HH시 mm분(E)"
        
        return dateFormatter.string(from: dateDate)
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
    }
}

extension AddToDoListViewController: UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: - 글자 수 제한
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
    
    
    //MARK: - textview placeholder 설정
    func placeholderSetting() {
        discriptionText.text = "describe a task in detail"
        discriptionText.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "describe a task in detail"
            textView.textColor = UIColor.lightGray
        }
    }

}
