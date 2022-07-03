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
    
    var getTaskDayData = [ToDoCellDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("calendarVIew - Didload")
        settingCalendar()
        settingCollectionView()
        getTaskData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTaskData()
    }
    
    //MARK: - calendar setting
    func settingCalendar()  {
        calnedarView.dataSource = self
        calnedarView.delegate = self
        self.calnedarView.appearance.titleWeekendColor = UIColor.red //주말 컬러
        self.calnedarView.appearance.headerMinimumDissolvedAlpha = 0 // 양옆 년월 삭제
        self.calnedarView.appearance.headerDateFormat = "YYYY년 MM월"
        calnedarView.appearance.subtitleTodayColor = .brown
        calnedarView.appearance.titleTodayColor = .brown
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
                self.calendarData = self.changeTimeAndPriorityToCalendarData() // 전체 데이터 저장 후 calendar 표현을 위한 date, priority 저장
                
                self.calnedarView.reloadData() // 달력 dot 표시
                
                // 선택된 날짜의 데이터 표현
                guard let selectDate = self.calnedarView.selectedDate else { return }
                self.setDateData(date: selectDate)
            }
        }
    }
    
    //MARK: - set datasource sell
    func setCell() {
        
        dayTaskData = UICollectionViewDiffableDataSource<Int, ToDoCellDataModel>(collectionView: collectionVIew, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionViewCell
            
            cell.taskDataInCell = itemIdentifier
            
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
            
            //구분선 추가
            cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            cell.layer.borderWidth = 1
            
            return cell
        })
    }
    
    
    
    func applyData() {
        
        snapshot = NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>()
        //섹션 추가
        snapshot.appendSections([0])
        // 아이템 추가
        snapshot.appendItems(getTaskDayData, toSection: 0)
        // 현재 스냅샷 구현
        dayTaskData.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    //해당 계정이 가지고 있는 전체 데이터에서 선택된 날짜에 포함된 데이터 객체 filter
    func setDateData(date dateData: Date) {
        
        let start = dateData.timeIntervalSince1970
        
        getTaskDayData = taskData.filter { inTaskData in
            let startDate = Date(timeIntervalSince1970: inTaskData.startDate).zeroOfDay.timeIntervalSince1970
            
            return startDate <= start && inTaskData.endDate > start
        }
        
        applyData()
        
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
        
        while time < endDate {
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
        
        return Set(setPriority).count
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
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        
        if date == Date().zeroOfDay {
            return "Today"
        }
        return nil
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("selectCell!!!!!!")
        
        guard let user = Auth.auth().currentUser else { return }
        
        let userUid = user.uid
        let db = Firestore.firestore()
        let cellData = getTaskDayData[indexPath.row]
        
        
        //update 진행
        db.collection("ToDoList").document(userUid).collection("Task").whereField("title", isEqualTo: cellData.title ).whereField("description", isEqualTo: cellData.description).whereField("startDate", isEqualTo: cellData.startDate).getDocuments { (querySnapshot, err) in
            
            if let err = err {
                print("firestore update get document err \(err)")
            } else {
                
                guard let document = querySnapshot?.documents.first else { return }
                let changeIsFinish = document.data()
                let nowBool = !(changeIsFinish["isFinish"] as! Bool)
                
                document.reference.updateData([
                    "isFinish": nowBool
                ]) { err in
                    if let err = err {
                        print("firestore update err \(err)")
                    } else {
                        self.getTaskData()
                    }
                }
            }
        }
    }
    
    //cell 간 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    

}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        return CGSize(width: width, height: 80)
    }
}
