//
//  SignInViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/06.
//

import UIKit
import FirebaseAuth
import Toast

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var checkEmailFormLable: UILabel!
    @IBOutlet weak var checkPasswordFormLable: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downKeyboardWhenTappedBackground()
        emailTextField.tag = 100
        passwordTextField.tag = 200
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        checkEmailFormLable.text = "please check your email"
        checkPasswordFormLable.text = "please check your password"
        checkEmailFormLable.textColor = .clear
        checkPasswordFormLable.textColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("SignInViewController - viewDidAppear")
        
        // 만약 로그인이 된 상태에서 sign in view가 표시되면 dismiss
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: true)
        }
    }
    
    //MARK: - 로그인 버튼 기능 구현
    @IBAction func signInAction(_ sender: UIButton) {
        
        guard let userEmail = emailTextField.text else { return }
        guard let userPassword = passwordTextField.text else { return }
        var checkValidPass = true
        
        let userInput = UserDataModel(userEmail: userEmail, password: userPassword)
        
        if !isValidEmail(userInput.userEmail) || userEmail == "" {
            shakeTextField(textField: emailTextField)
            checkEmailFormLable.textColor = .red
            checkValidPass = false
        }
        
        if userPassword == "" {
            checkPasswordFormLable.textColor = .red
            shakeTextField(textField: passwordTextField)
            checkValidPass = false
        }
        
        if checkValidPass {
            Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
                
                if user != nil {
                    print("login success")
                    NotificationCenter.default.post(name: NSNotification.Name("reloadTask"), object: nil)
                    self.dismiss(animated: true)
                } else {
                    print(error!.localizedDescription)
                    self.view.makeToast("Sign In Failed")
                }
            }
        }
        
        
    }
    
    //MARK: - 회원가입 창 이동
    @IBAction func signUpAction(_ sender: Any) {
        
        guard let signUpView = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") else {
            return
        }
        signUpView.modalPresentationStyle = .formSheet
        present(signUpView, animated: true, completion: nil)
    }

}


// 기타 기능 구현
extension SignInViewController: UITextFieldDelegate {
    
    // 잘못된 입력 시 textfield 진동
    func shakeTextField(textField: UITextField) -> Void{
        UIView.animate(withDuration: 0.2, animations: {
            textField.frame.origin.x = 10
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                textField.frame.origin.x -= 15
             }, completion: { _ in
                 UIView.animate(withDuration: 0.2, animations: {
                    textField.frame.origin.x += 15
                })
            })
        })
    }
    
    
    //done 입력 시 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.checkPasswordFormLable.textColor = .clear
        self.checkEmailFormLable.textColor = .clear
        
    }
}
