//
//  AddToDoListViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class AddToDoListViewController: UIViewController {
    
    @IBOutlet weak var taskText: UITextField!
    @IBOutlet weak var discriptionText: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startDateText: UITextField!
    @IBOutlet weak var endDateText: UITextField!
    @IBOutlet weak var priority: UISegmentedControl! 
    @IBOutlet weak var allDayBtn: UIButton! {
        didSet {
            guard let text = self.allDayBtn.titleLabel!.text else { return }
            let attributeString = NSMutableAttributedString(string: text)
            
            attributeString.addAttribute(.strikethroughColor, value: UIColor.white, range: (text as NSString).range(of: text))
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: (text as NSString).range(of: text))
            allDayBtn.setAttributedTitle(attributeString, for: .normal)
        }
    }
    let datePicker = UIDatePicker()
    var startDate = Date().timeIntervalSince1970
    var endDate = Date().timeIntervalSince1970
    var isAllDay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddToDoListViewController - viewDidLoad")
        self.downKeyboardWhenTappedBackground() // 화면 터치시 키보드 내려감
        taskText.delegate = self // 글자 수 제한을 위한 delegate 설정
        discriptionText.delegate = self // ''
        self.placeholderSetting() // textview placeholder 설정을 위한 함수 구현
        datePicker.datePickerMode = .dateAndTime // datepicker 설정
        datePicker.preferredDatePickerStyle = .wheels // wheel 설정
        datePicker.frame = CGRect(x: 0, y: 300, width: self.view.frame.width, height: 150) //datepicker 위치 설정
        datePicker.setValue(UIColor.clear, forKey: "backgroundColor")
        
        //pickerview 툴바 추가
        let pickerTool = UIToolbar()
        pickerTool.barStyle = .default
        pickerTool.sizeToFit() //서브뷰만큼 툴바 크기를 맞춤
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
        
        priority.selectedSegmentTintColor = .green
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AddToDoListViewController - viewWillAppear")
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("AddToDoListViewController - viewWillDisappear")
        self.removeKeyboardNotifications()
    }
    
    //MARK: - 텍스트 필드 클릭 시 datepicker 출력 및 텍스트 필드에 세팅
    @objc private func onClickDone() {
        print("AddToDoListViewController - onClickDone")
        
        if startDateText.resignFirstResponder() {
            if isAllDay {
                startDate = datePicker.date.zeroOfDay.timeIntervalSince1970
            } else {
                startDate = datePicker.date.timeIntervalSince1970
            }

            startDateText.text = self.changeDateToString(datePicker.date, isAllDay)
        } else {
            if isAllDay {
                endDate = datePicker.date.zeroOfDay.timeIntervalSince1970
            } else {
                endDate = datePicker.date.timeIntervalSince1970
            }
            endDateText.text = self.changeDateToString(datePicker.date, isAllDay)
        }
        self.view.endEditing(true)
    }
    @objc private func onClickCancel() {
        print("AddToDoListViewController - onClickCancel")
        self.view.endEditing(true)
    }
    
    //MARK: - all day 설정에 따른 버튼 변화
    @IBAction func changeSettingAllDay(_ sender: Any) {
        print("AddToDoListViewController - changeSettingAllDay")
        
        isAllDay = isAllDay ? false : true
        
        if isAllDay {
            datePicker.datePickerMode = .date
            allDayBtn.tintColor = .systemBlue
            changeButtonFont()
            startDateText.text = ""
            endDateText.text = ""
        } else {
            datePicker.datePickerMode = .dateAndTime
            allDayBtn.tintColor = .black
            changeButtonFont()
            startDateText.text = ""
            endDateText.text = ""
        }
    }
    
    @IBAction func changeSegmentColor(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            sender.selectedSegmentTintColor = .green
        } else if sender.selectedSegmentIndex == 1 {
            sender.selectedSegmentTintColor = .yellow
        } else {
            sender.selectedSegmentTintColor = .red
        }
    }
    
    
    func changeButtonFont() {
        
        guard let text = self.allDayBtn.titleLabel!.text else { return }
        let attributeString = NSMutableAttributedString(string: text)
        
        if isAllDay {
            attributeString.removeAttribute(.strikethroughColor, range: (text as NSString).range(of: text))
            attributeString.removeAttribute(.strikethroughStyle, range: (text as NSString).range(of: text))
            allDayBtn.setAttributedTitle(attributeString, for: .normal)
        } else {
            attributeString.addAttribute(.strikethroughColor, value: UIColor.white, range: (text as NSString).range(of: text))
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: (text as NSString).range(of: text))
            allDayBtn.setAttributedTitle(attributeString, for: .normal)
        }
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
    
    //MARK: - Task 추가
    @IBAction func addTask(_ sender: Any) {
        
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        
        if taskText.text == "" || endDateText.text == "" || startDateText.text == "" {
            self.view.makeToast("please write title or date")
        } else {
            
            let db = Firestore.firestore()
            
            let addTaskData = ToDoCellDataModel(priority: self.priority.selectedSegmentIndex, title: self.taskText.text!, startDate: startDate, endDate: endDate, description: discriptionText.text!, isAllDay: isAllDay, isFinish: false)
            
            
            //MARK: - 데이터 추가
            do {
                try _ = db.collection("ToDoList").document(userUid).collection("Task").addDocument(from: addTaskData) { err in
                    if err == nil {
                        print("add document -- who \(userUid)")
                        
                        NotificationCenter.default.post(name: NSNotification.Name("reloadTask") , object: nil)
                        self.dismiss(animated: true)
                    }
                }
            } catch let error {
                self.view.makeToast("error")
                print("Error writing city to Firestore: \(error)")
            }
        }
        
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
