//
//  extensions.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/26.
//

import Foundation
import UIKit


extension UIViewController {
    
    //MARK: - 날짜 선택 시 변수에 날짜 저장하도록 구현
    //date -> formatter
    func changeDateToString(_ dateDate: Date, _ isAllDay: Bool) -> String {
        
        let dateFormatter = DateFormatter()
        
        if isAllDay {
            dateFormatter.dateFormat = "MM. dd (E)"
        } else {
            dateFormatter.dateFormat = "MM. dd HH:mm (E)"
        }
        return dateFormatter.string(from: dateDate)
    }
    
    func taskChangeDateToString(_ dateDate: Date, _ endDate: Date, _ isAllDay: Bool) -> String {
        
        let dateFormatter = DateFormatter()
        
        if isAllDay {
            dateFormatter.dateFormat = "MM. dd (E)"
        } else {
            dateFormatter.dateFormat = "MM. dd HH:mm (E)"
        }
        return "\(dateFormatter.string(from: dateDate)) ~ \(dateFormatter.string(from: endDate))"
    }
    
    
    //MARK: - 배경 터치 시 키보드 다운
    func downKeyboardWhenTappedBackground() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(downKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func downKeyboard() {
        view.endEditing(true)
    }
    
    //방식 변경
    //MARK: - 키보드만큼 화면 올리기는 기능 구현
    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 노티피케이션을 제거하는 메서드
    //ios 9.0 이하에서만 사용 이상은 사용하지 않아도 무관
    func removeKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillShow(_ noti: NSNotification){
        // 키보드의 높이만큼 화면을 올려준다.
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y -= keyboardHeight
        }
    }

    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc func keyboardWillHide(_ noti: NSNotification){
        // 키보드의 높이만큼 화면을 내려준다.
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y += keyboardHeight
        }
    }
    
    //MARK: - 완료에 따른 텍스트 변화
    func changeStrikeFont(text: String, isFinish: Bool, isDarkMode: Bool) -> NSMutableAttributedString {
        
        let attributeString = NSMutableAttributedString(string: text)
        
        if isDarkMode {
            
            attributeString.addAttribute(.strikethroughColor, value: UIColor.white, range: (text as NSString).range(of: text))
        } else {
            
            attributeString.addAttribute(.strikethroughColor, value: UIColor.black, range: (text as NSString).range(of: text))
        }
        
        if isFinish {
            
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: (text as NSString).range(of: text))
        } else {
            
            attributeString.addAttribute(.strikethroughStyle, value: 0, range: (text as NSString).range(of: text))
        }
        
        return attributeString
    }
}


extension UITextFieldDelegate {
    
    // 아이디 형식 검사
    func isValidEmail(_ userEmail: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: userEmail)
    }
        
    // 비밀번호 형식 검사
    func isValidPassword(_ userPassowrd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: userPassowrd)
    }
    
    // 비밀번호 일치 검사
    func isSamePasswod(_ userPass: String, _ repeatPass: String) -> Bool {
        return userPass == repeatPass ? true : false
    }
}

extension Date {
    // 선택된 날짜의 00시 00분 00초 값
    var zeroOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(backgroundImage, for: state)
    }
}

public extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//MARK: - statusBar 설정을 마지막으로 한 설정으로 가져오기
extension UINavigationController {
    
    open override var childForStatusBarHidden: UIViewController? {
        return viewControllers.last
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return viewControllers.last
    }
}

extension UITabBarController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.children.first
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.children.first
    }
}

extension UISplitViewController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.children.first
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.children.first
    }
}
