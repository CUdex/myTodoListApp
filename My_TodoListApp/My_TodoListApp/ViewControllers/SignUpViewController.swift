//
//  SignUpViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/06.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBOutlet weak var emailCheckLable: UILabel! {
        didSet {
            emailCheckLable.textColor = .clear
        }
    }
    @IBOutlet weak var passwordCheckLable: UILabel! {
        didSet {
            passwordCheckLable.textColor = .clear
        }
    }
    @IBOutlet weak var passwordCaseCheck: UILabel! {
        didSet {
            passwordCaseCheck.textColor = .clear
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let db = Firestore.firestore()
    
    
    //MARK: - DidLoad start
    override func viewDidLoad() {
        super.viewDidLoad()

        self.downKeyboardWhenTappedBackground()
        self.view.backgroundColor = .clear
        self.userName.delegate = self
        self.userEmail.delegate = self
        self.userPhoneNumber.delegate = self
        self.repeatPassword.delegate = self
        self.userPassword.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.removeKeyboardNotifications()
    }
    
    //MARK: - 키보드 만큼 스크롤 조절
    override func keyboardWillShow(_ noti: NSNotification) {
        guard let userInfo = noti.userInfo else {
            return
        }
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardFrame, to: view.window)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - 150, right: 0)
        //scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    // 복구
    override func keyboardWillHide(_ noti: NSNotification) {
        //스크롤 뷰 최상단 이동
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    //MARK: - 회원가입
    @IBAction func signUpAction(_ sender: Any) {
        guard let name = userName.text else { return }
        guard let email = userEmail.text else { return }
        guard let phoneNumber = userPhoneNumber.text else { return }
        guard let password = userPassword.text else { return }
        guard let repeatPassword = repeatPassword.text else { return }
        
        let signUpUser = UserDataModel(userEmail: email, password: password, userName: name, userPhoneNumber: phoneNumber)
        
        var attriString = NSAttributedString(string: "")
        let alert = UIAlertController(title: "check your email", message: "check your email", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(alertAction)
        
        if !isValidEmail(signUpUser.userEmail) {
            self.present(alert, animated: true, completion: nil)
        } else if !isValidPassword(signUpUser.password) {
            attriString = NSAttributedString(string: "check your password")
            alert.setValue(attriString, forKey: "attributedTitle")
            self.present(alert, animated: true, completion: nil)
        } else if !isSamePasswod(password, repeatPassword) {
            attriString = NSAttributedString(string: "not same password")
            alert.setValue(attriString, forKey: "attributedTitle")
            self.present(alert, animated: true, completion: nil)
        } else {
            
            // 모든 조건을 만족하면 회원가입 시작
            Auth.auth().createUser(withEmail: signUpUser.userEmail, password: signUpUser.password) { (result : AuthDataResult?, error : Error?) in
                
                if let user = result?.user {
                    
                    //firestore user collection에 유저 데이터도 함께 저장
                    self.db.collection("User").document(signUpUser.userEmail).setData([
                        "email" : signUpUser.userEmail,
                        "name" : signUpUser.userName ?? "nil name",
                        "phoneNumber" : signUpUser.userPhoneNumber ?? "nil phone"
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                    
                    // root VC인 mainTableview까지 dismiss 후 토스트로 로그인 성공 메시지 출력
                    guard let rootVC = self.view.window?.rootViewController else { return }
                    rootVC.dismiss(animated: true) {
                        rootVC.view.makeToast("welcome \(user.email ?? "goodman" )")
                    }
                } else {
                    print(error?.localizedDescription ?? "nil message")
                    attriString = NSAttributedString(string: "failed sign up")
                    alert.setValue(attriString, forKey: "attributedTitle")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    
    // 회원가입 시에 필요한 조건 lable로 표시
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let email = userEmail.text else { return }
        guard let pass = userPassword.text else { return }
        guard let repeatPass = repeatPassword.text else { return }
        
        if textField == userEmail {
            if isValidEmail(email) {
                emailCheckLable.textColor = .clear
            } else {
                emailCheckLable.textColor = .red
            }
        } else if textField == repeatPassword{
            if isSamePasswod(pass, repeatPass) {
                passwordCheckLable.textColor = .clear
            } else {
                passwordCheckLable.textColor = .red
            }
        } else {
            if isValidPassword(pass) {
                passwordCaseCheck.textColor = .clear
            } else {
                passwordCaseCheck.textColor = .red
            }
        }
        
    }
    
    //MARK: - done 버튼을 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
