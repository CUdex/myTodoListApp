//
//  DatePickerViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/07/19.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    lazy var safeArea = view.safeAreaLayoutGuide

    let datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    let filterButton: UIButton = {
        
        let addButton = UIButton()
       
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("set filter", for: .normal)
        addButton.backgroundColor = .systemBlue
        return addButton
    }()
    
    var textHandler: ((Date) -> (Void))?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDatePicker()
        setButton()
        setBlur()
    }
    
    func setButton() {
        
        self.view.addSubview(filterButton)
        
        filterButton.addTarget(self, action: #selector(settingFilterFunc), for: .touchUpInside)
        filterButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 30).isActive = true
        filterButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        filterButton.widthAnchor.constraint(equalTo: datePicker.widthAnchor).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: datePicker.bounds.width / 8).isActive = true
    }
    
    func setDatePicker() {
        
        self.view.addSubview(datePicker)
        
        datePicker.backgroundColor = .white
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true
    }
    
    // 배경 blur 처리
    func setBlur() {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualBlur = UIVisualEffectView(effect: blurEffect)
        
        visualBlur.frame = view.frame
        
        self.view.insertSubview(visualBlur, at: 0)
    }

    @objc func settingFilterFunc() {
    
        print("set")
        textHandler?(datePicker.date)
        self.dismiss(animated: true)
    }
    
    // 달력 이외 영역 터치 시 view dismiss
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }
}
