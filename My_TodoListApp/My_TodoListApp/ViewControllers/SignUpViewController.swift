//
//  SignUpViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/06.
//

import UIKit
import FirebaseFirestore
import SwiftUI

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
        
        
        
        
        
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    
    // 회원가입 시에 필요한 조건 검사
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
