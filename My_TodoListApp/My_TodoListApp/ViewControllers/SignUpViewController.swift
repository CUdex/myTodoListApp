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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.downKeyboardWhenTappedBackground()
        self.view.backgroundColor = .clear
        self.userEmail.delegate = self
        self.repeatPassword.delegate = self
        self.userPassword.delegate = self
        // Do any additional setup after loading the view.
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
                    self.view.makeToast("\(user) sign up!")
                    self.dismiss(animated: true)
                } else {
                    print(error?.localizedDescription)
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
    
    
    
}
