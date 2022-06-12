//
//  AppSettingViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/04.
//

import UIKit
import FirebaseAuth

class AppSettingViewController: UIViewController {

    @IBOutlet weak var helloUserLable: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addSignInSuccessNotifications()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        reloadLableAndButtonTitle()
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            
            do {
                try Auth.auth().signOut()
                self.view.makeToast("Sign Out")
                reloadLableAndButtonTitle()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
        } else {
            
            guard let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") else { return }
            signInVC.modalPresentationStyle = .fullScreen
            present(signInVC, animated: true, completion: nil)
        }
    }
}

extension AppSettingViewController {
    
    
    func addSignInSuccessNotifications(){
        // 로그인 성공 시 설정 화면의 멘트 수정을 위한 노티 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiReload(_:)), name: Notification.Name("SuccessSignIn") , object: nil)
    }
    
    @objc func notiReload(_ noti: NSNotification) {
        reloadLableAndButtonTitle()
    }
    
    func reloadLableAndButtonTitle() {
        
        if let user = Auth.auth().currentUser {
            print("UID ! : \(user.uid)")
            let name = user.email!
            helloUserLable.text = "Hello \n\(name)"
            signOutButton.setTitle("Sign Out", for: .normal)
        } else {
            helloUserLable.text = "Please Sign In!"
            signOutButton.setTitle("Sign In", for: .normal)
        }
    }
}
