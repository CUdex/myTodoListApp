//
//  CalendarViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/26.
//

import UIKit
import FSCalendar
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CalendarViewController: UIViewController {

    
    @IBOutlet weak var calnedarView: FSCalendar!
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    var taskData = [ToDoCellDataModel]()
    var calendarData = [[String:Any]]()
    
    //diffable을 위한 설정
    var dayTaskData: UICollectionViewDiffableDataSource<Int, ToDoCellDataModel>!
    var snapshot: NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>!
    
    let oneDay: Double = 86400
    
    var countPriority = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("calendarVIew - Didload")
        settingCalendar()
        settingCollectionView()
        getTaskData()
        
    }
    
    //MARK: - calendar setting
    func settingCalendar()  {
        calnedarView.dataSource = self
        calnedarView.delegate = self
        self.calnedarView.appearance.headerMinimumDissolvedAlpha = 0 // 양옆 년월 삭제
        self.calnedarView.appearance.headerDateFormat = "YYYY년 MM월"
    }
    
    func settingCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 390, height: 80)
        collectionVIew.collectionViewLayout = layout
        collectionVIew.delegate = self
        collectionVIew.dataSource = dayTaskData
        setCell()
    }
}

extension CalendarViewController {
    
    //MARK: - get data
    func getTaskData()  {
        print("ToDoMain - getTaskData")
        guard let user = Auth.auth().currentUser else { return }
        
        let userUid = user.uid
        let db = Firestore.firestore()
        
        db.collection("ToDoList").document(userUid).collection("Task").order(by: "startDate").getDocuments { (QuerySnapshot, Error) in
            if let err = Error {
                print("Error getting document: \(err)")
            } else {
                guard let queryData = QuerySnapshot?.documents else { return }
                let dicData = queryData.compactMap({ $0.data() })
                self.taskData = dicData.compactMap { (dicData) -> ToDoCellDataModel in
                    return ToDoCellDataModel(priority: dicData["priority"] as! Int,
                                             title: dicData["title"] as! String,
                                             startDate: dicData["startDate"] as! TimeInterval,
                                             endDate: dicData["endDate"] as! TimeInterval,
                                             description: dicData["description"] as! String,
                                             isAllDay: dicData["isAllDay"] as! Bool,
                                             isFinish: dicData["isFinish"] as! Bool)
                }
                self.calendarData = self.changeTimeAndPriorityToCalendarData()
                self.calnedarView.reloadData()
            }
        }
    }
    
    //MARK: - set datasource sell
    func setCell() {
        
        dayTaskData = UICollectionViewDiffableDataSource<Int, ToDoCellDataModel>(collectionView: collectionVIew, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
            
            //priority에 따른 cell color 변경
            switch itemIdentifier.priority {
            case 0:
                cell.imgView.tintColor = .green
            case 1:
                cell.imgView.tintColor = .yellow
            default:
                cell.imgView.tintColor = .red
            }
            
            cell.titleLable.text = itemIdentifier.title
            let startDate = Date(timeIntervalSince1970: itemIdentifier.startDate)
            cell.dateLable.text = self.changeDateToString(startDate, itemIdentifier.isAllDay)
            
            // 완료 여부에 따른 image 및 attribute 변경
            if itemIdentifier.isFinish {
                cell.imgView.image = UIImage(systemName: "circlebadge.fill")
                cell.titleLable.attributedText = self.changeStrikeFont(text: cell.titleLable.text!, isFinish: itemIdentifier.isFinish)
                cell.dateLable.attributedText = self.changeStrikeFont(text: cell.dateLable.text!, isFinish: itemIdentifier.isFinish)
            } else {
                cell.imgView.image = UIImage(systemName: "circlebadge")
                cell.titleLable.attributedText = self.changeStrikeFont(text: cell.titleLable.text!, isFinish: itemIdentifier.isFinish)
                cell.dateLable.attributedText = self.changeStrikeFont(text: cell.dateLable.text!, isFinish: itemIdentifier.isFinish)
            }
            
            return cell
        })
    }
    
    func applyData(_ getDayTaskData: [ToDoCellDataModel]) {
        
        snapshot = NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>()
        //섹션 추가
        snapshot.appendSections([0])
        // 아이템 추가
        snapshot.appendItems(getDayTaskData, toSection: 0)
        // 현재 스냅샷 구현
        dayTaskData.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    //해당 계정이 가지고 있는 전체 데이터에서 선택된 날짜에 포함된 데이터 객체 filter
    func setDateData(date dateData: Date) {
        
        let start = dateData.timeIntervalSince1970
        let end = start + oneDay
        let getDayTaskData = taskData.filter { $0.startDate >= start && $0.endDate < end }
        
        
        print(getDayTaskData)
        
        applyData(getDayTaskData)
        
    }
}

extension CalendarViewController: FSCalendarDataSource {
    
    func changeTimeAndPriorityToCalendarData() -> [[String:Any]] {
        
        print("changeTimeToDate")
        var originDateData = [[String:Any]]()
        
        for slicingData in taskData {
            originDateData.append(contentsOf: getArrayDateAndPriority(startDate: slicingData.startDate, endDate: slicingData.endDate, priority: slicingData.priority))
        }
        
        return originDateData
    }
    
    func getArrayDateAndPriority(startDate: TimeInterval, endDate: TimeInterval, priority: Int) -> [[String:Any]] {
        
        var resultDate = [[String:Any]]()
        var time: TimeInterval = startDate + oneDay
        var currentDate = Date(timeIntervalSince1970: startDate).zeroOfDay
        
        resultDate.append(["Date": currentDate, "priority": priority])
        
        while time <= endDate {
            currentDate = Date(timeIntervalSince1970: time).zeroOfDay
            resultDate.append(["Date": currentDate, "priority": priority])
            time += oneDay
        }
        return resultDate
    }
    
    //이벤트 중요도에 따른 dot 갯수 설정
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        var setPriority = [Int]()

        for data in calendarData {

            guard let dateData = data["Date"] as? Date else {
                print("fail to convert data[] to Date")
                return 0
            }
            guard let priorityData = data["priority"] as? Int else {
                print("fail to convert data[] to Int")
                return 0
            }
            if dateData == date {
                setPriority.append(priorityData)
            }
        }

        print("sadasdasdasdasdasddsdsadsasdas")
        print(setPriority)
        countPriority = Set(setPriority)
        return countPriority.count
    }
    
}

extension CalendarViewController:FSCalendarDelegateAppearance {
    
    //달력에 표시될 dot 색깔 설정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        if countPriority.count ==  1 {
            
            switch countPriority {
            case [0]:
                return [UIColor.green]
            case [1]:
                return [UIColor.black]
            default:
                return [UIColor.red]
            }
            
        } else if countPriority.count == 2 {
            
            switch countPriority {
            case [0,1]:
                return [UIColor.green, UIColor.black]
            case [1,2]:
                return [UIColor.black, UIColor.red]
            default:
                return [UIColor.green, UIColor.red]
            }
            
        }
        
        return [UIColor.green, UIColor.black, UIColor.red]
    }
}
extension CalendarViewController: FSCalendarDelegate {
    
    //해당 날짜 클릭 시 date정보 가져오기
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("\(date)")
        setDateData(date: date)
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    
}
