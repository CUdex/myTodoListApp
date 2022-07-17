//
//  FilterViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/07/15.
//

import UIKit

class FilterViewController: UIViewController {
    
    lazy var safeArea = view.safeAreaLayoutGuide
    
    let mainTitleLable: UILabel = {
        
        let addLable = UILabel()
        
        addLable.text = "조건 검색"
        addLable.font = UIFont.boldSystemFont(ofSize: 20)
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let periodTitleLable: UILabel = {
        
        let addLable = UILabel()
        
        addLable.text = "Period"
        addLable.font = addLable.font.withSize(25)
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let startDateLable: UILabel = {
        
        let addLable = UILabel()
        
        addLable.font = UIFont.systemFont(ofSize: 20)
        
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let middleLable: UILabel = {
        
        let addLable = UILabel()
        
        addLable.text = "~"
        addLable.font = UIFont.systemFont(ofSize: 20)
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let endDateLable: UILabel = {
        
        let addLable = UILabel()
        
        addLable.font = UIFont.systemFont(ofSize: 20)
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let priorityTitleLable: UILabel = {
       
        let addLable = UILabel()
        
        addLable.text = "Priority"
        addLable.font = addLable.font.withSize(25)
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let prioritySegmentControll: UISegmentedControl = {
       
        let addSeg = UISegmentedControl(items: ["Low", "Middle", "High", "All"])
        
        addSeg.translatesAutoresizingMaskIntoConstraints = false
        addSeg.selectedSegmentIndex = 3
        return addSeg
    }()
    
    let finishTitleLable: UILabel = {
       
        let addLable = UILabel()
        
        addLable.text = "IsFinished"
        addLable.font = addLable.font.withSize(25)
        addLable.translatesAutoresizingMaskIntoConstraints = false
        return addLable
    }()
    
    let isFinishedSegmentControll: UISegmentedControl = {
       
        let addSeg = UISegmentedControl(items: ["not Finished", "Finished", "All"])
        
        addSeg.translatesAutoresizingMaskIntoConstraints = false
        addSeg.selectedSegmentIndex = 2
        return addSeg
    }()
    
    let clickButton: UIButton = {
        
        let addBtn = UIButton()
        
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        addBtn.setTitle("try", for: .normal)
        addBtn.backgroundColor = .systemBlue
        return addBtn
    }()
    
    weak var delegate: FilterSettingDelegate?
    var filterData: FilterSettingData = FilterSettingData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSetTitleLable() // 조건 검색 타이틀
        layoutSetPeriodLable() // 기간 타이틀
        stringPeriodDate() // 기간 text Lable
        layoutSetPriorityLable() // 중요도 타이틀
        addPrioritySegmentControll() // 중요도 선택 세그먼트 추가
        layoutSetFinishedLable() // 완료 타이틀
        addFinishedSegmentControll() // 완료 선택 세그먼트 추가
        addButton() // 필터 적용 액션 버튼
        self.view.backgroundColor = .white
    }
    
    func stringPeriodDate() {
        
        self.view.addSubview(middleLable)
        
        middleLable.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 0).isActive = true
        middleLable.topAnchor.constraint(equalTo: periodTitleLable.bottomAnchor, constant: 10).isActive = true

        self.view.addSubview(startDateLable)
        
        startDateLable.text = changeDateToString(Date(), true)
        startDateLable.leadingAnchor.constraint(greaterThanOrEqualTo: safeArea.leadingAnchor, constant: 20).isActive = true
        startDateLable.topAnchor.constraint(equalTo: periodTitleLable.bottomAnchor, constant: 10).isActive = true
        startDateLable.trailingAnchor.constraint(equalTo: middleLable.leadingAnchor, constant: -20).isActive = true
        
        self.view.addSubview(endDateLable)
        
        endDateLable.text = changeDateToString(Date(), true)
        endDateLable.leadingAnchor.constraint(equalTo: middleLable.trailingAnchor, constant: 20).isActive = true
        endDateLable.topAnchor.constraint(equalTo: periodTitleLable.bottomAnchor, constant: 10).isActive = true
        endDateLable.trailingAnchor.constraint(greaterThanOrEqualTo: safeArea.trailingAnchor, constant: -20).isActive = true
    }
    
    func addButton() {
        
        view.addSubview(clickButton)
        
        clickButton.addTarget(self, action: #selector(tryFiltering), for: .touchUpInside)
        clickButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        clickButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        clickButton.topAnchor.constraint(equalTo: isFinishedSegmentControll.bottomAnchor, constant: 40) .isActive = true
        clickButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true
    }
    
    func layoutSetTitleLable() {
        
        self.view.addSubview(mainTitleLable)
        
        mainTitleLable.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10).isActive = true
        mainTitleLable.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
    }
    
    func layoutSetPeriodLable() {
        
        self.view.addSubview(periodTitleLable)
        
        periodTitleLable.topAnchor.constraint(equalTo: mainTitleLable.bottomAnchor, constant: 20).isActive = true
        periodTitleLable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    }
    
    func layoutSetPriorityLable() {
        
        self.view.addSubview(priorityTitleLable)
        
        priorityTitleLable.topAnchor.constraint(equalTo: startDateLable.bottomAnchor, constant: 20).isActive = true
        priorityTitleLable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    }
    
    func addPrioritySegmentControll() {
        
        self.view.addSubview(prioritySegmentControll)
        
        prioritySegmentControll.addTarget(self, action: #selector(changePrioritySelectedColor), for: .valueChanged)
        prioritySegmentControll.topAnchor.constraint(equalTo: priorityTitleLable.bottomAnchor, constant: 10).isActive = true
        prioritySegmentControll.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        prioritySegmentControll.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true
        prioritySegmentControll.heightAnchor.constraint(equalToConstant: prioritySegmentControll.frame.width / 7).isActive = true
    }
    
    func layoutSetFinishedLable() {
        
        self.view.addSubview(finishTitleLable)
        
        finishTitleLable.translatesAutoresizingMaskIntoConstraints = false
        finishTitleLable.topAnchor.constraint(equalTo: prioritySegmentControll.bottomAnchor, constant: 20).isActive = true
        finishTitleLable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    }
    
    func addFinishedSegmentControll() {
        
        self.view.addSubview(isFinishedSegmentControll)
        
        isFinishedSegmentControll.topAnchor.constraint(equalTo: finishTitleLable.bottomAnchor, constant: 10).isActive = true
        isFinishedSegmentControll.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20).isActive = true
        isFinishedSegmentControll.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20).isActive = true
        isFinishedSegmentControll.heightAnchor.constraint(equalToConstant: isFinishedSegmentControll.frame.width / 7).isActive = true
    }
}


//MARK: - func 기능 정리
extension FilterViewController {
    
    //view dismiss
    @objc func dismissFunc() {
        self.dismiss(animated: true)
    }
    
    //change priority segment selected color
    @objc func changePrioritySelectedColor() {
        
        switch prioritySegmentControll.selectedSegmentIndex {
        case 0:
            prioritySegmentControll.selectedSegmentTintColor = .green
        case 1:
            prioritySegmentControll.selectedSegmentTintColor = .yellow
        case 2:
            prioritySegmentControll.selectedSegmentTintColor = .red
        default:
            prioritySegmentControll.selectedSegmentTintColor = .white
        }
    }
    
    //filtering
    @objc func tryFiltering() {
        
        filterData.isFinished = IsFinishedCase(rawValue: isFinishedSegmentControll.selectedSegmentIndex) ?? .all
        filterData.priority = PriorityCase(rawValue: prioritySegmentControll.selectedSegmentIndex) ?? .all
        
        self.delegate?.changeFilterSet(filterData)
        self.dismiss(animated: true)
    }
    
    func ViewDataSetting(_ data: FilterSettingData) {
        
        filterData = data
        
        startDateLable.text = changeDateToString(Date(timeIntervalSince1970: filterData.startDay), true)
        endDateLable.text = changeDateToString(Date(timeIntervalSince1970: filterData.endDay), true)
        prioritySegmentControll.selectedSegmentIndex = filterData.priority.rawValue
        changePrioritySelectedColor()
        isFinishedSegmentControll.selectedSegmentIndex = filterData.isFinished.rawValue
    }
}


//ui 확인
import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = FilterViewController

    func makeUIViewController(context: Context) -> FilterViewController {
        return FilterViewController()
    }

    func updateUIViewController(_ uiViewController: FilterViewController, context: Context) {
    }
}

@available(iOS 13.0.0, *)
struct ViewPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
    }
}
