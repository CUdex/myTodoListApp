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
    @IBOutlet weak var backgrounLable: UILabel!
    @IBOutlet weak var blackModeSwitch: UISwitch!
    let fireDataController = FireDataController()
    var isDarkStatusBarStyle = false
    let sqliteDB = SqlLiteController.share
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if isDarkStatusBarStyle {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSignInSuccessNotifications()
        settingSwitchUISwitch()
        reloadLableAndButtonTitle()
    }

    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func settingSwitchUISwitch() {
        
        let isDarkMode = sqliteDB.isDarkMode
        
        if isDarkMode == 1 {
            
            blackModeSwitch.isOn = false
            helloUserLable.textColor = .black
            backgrounLable.textColor = .black
            self.view.backgroundColor = .white
            isDarkStatusBarStyle = false
        } else {
            
            blackModeSwitch.isOn = true
            helloUserLable.textColor = .white
            backgrounLable.textColor = .white
            self.view.backgroundColor = .black
            isDarkStatusBarStyle = true
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func signOutAction(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            
            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { _ in
                
                do {
                    try Auth.auth().signOut()
                    self.view.makeToast("Sign Out")
                    self.reloadLableAndButtonTitle()
                    NotificationCenter.default.post(name: Notification.Name("logoutTask"), object: nil)
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
            })
            self.present(alert, animated: true)
        } else {
            
            guard let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") else { return }
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }
        
        
    }
    @IBAction func changeBackground(_ sender: UISwitch) {
        
        if sender.isOn {
            
            sqliteDB.updateRow(0)
            helloUserLable.textColor = .white
            backgrounLable.textColor = .white
            self.view.backgroundColor = .black
            isDarkStatusBarStyle = true
        } else {
            
            sqliteDB.updateRow(1)
            helloUserLable.textColor = .black
            backgrounLable.textColor = .black
            self.view.backgroundColor = .white
            isDarkStatusBarStyle = false
        }
        
        NotificationCenter.default.post(name: Notification.Name("changeBackgroundMode"), object: nil)
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension AppSettingViewController {
    
    
    func addSignInSuccessNotifications(){
        // 로그인 성공 시 설정 화면의 멘트 수정을 위한 노티 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiReload(_:)), name: Notification.Name("reloadTask") , object: nil)
    }
    
    @objc func notiReload(_ noti: NSNotification) {
        
        reloadLableAndButtonTitle()
    }
    
    func reloadLableAndButtonTitle() {
        
        if let user = Auth.auth().currentUser {
            
            fireDataController.getUserName(user) { userName in
                
                self.helloUserLable.text = "Hello \(userName)"
            }
            signOutButton.setTitle("Sign Out", for: .normal)
        } else {
            
            helloUserLable.text = "Please Sign In!"
            signOutButton.setTitle("Sign In", for: .normal)
        }
    }
    
    
}
