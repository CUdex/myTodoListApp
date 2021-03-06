//
//  CalendarViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/06/26.
//

import UIKit
import FSCalendar
import FirebaseAuth

class CalendarViewController: UIViewController {

    
    @IBOutlet weak var calnedarView: FSCalendar!
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    let singletonTaskData = TaskData.share
    var calendarData = [[String:Any]]()
    var isDarkMode = SqlLiteController.share.isDarkMode == 0 ? true : false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if isDarkMode {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    //diffable을 위한 설정
    var dayTaskData: UICollectionViewDiffableDataSource<Int, ToDoCellDataModel>!
    var snapshot: NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>!
    
    let oneDay: Double = 86400
    var countPriority = Set<Int>()
    var getTaskDayData = [ToDoCellDataModel]()
    let dataController = FireDataController()
    var lastSelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("calendarVIew - Didload")
        settingCalendar()
        settingCollectionView()
        getTaskData()
        addNotifications()
        addLongGesture()
        backgroundSet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("calendar - viewWillAppear")
        setDateData(date: lastSelectedDate)
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
        
        guard let user = Auth.auth().currentUser else {
            self.calnedarView.reloadData()
            self.applyData()
            return
        }
        
        dataController.getData(user) { data in
            
            self.singletonTaskData.data = data
            self.calendarData = self.changeTimeAndPriorityToCalendarData() // 전체 데이터 저장 후 calendar 표현을 위한 date, priority 저장
            self.calnedarView.reloadData() // 달력 dot 표시
            self.setDateData(date: self.lastSelectedDate)// 선택된 날짜의 데이터 표현
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
            let endDate = Date(timeIntervalSince1970: itemIdentifier.isAllDay ? itemIdentifier.endDate - 1: itemIdentifier.endDate)
            cell.dateLable.text = self.taskChangeDateToString(startDate, endDate, itemIdentifier.isAllDay)
            
            if self.isDarkMode {
                
                cell.titleLable.textColor = .white
                cell.dateLable.textColor = .white
            } else {
                
                cell.titleLable.textColor = .black
                cell.dateLable.textColor = .black
            }
            
            // 완료 여부에 따른 image 및 attribute 변경
            if itemIdentifier.isFinish {
                
                cell.imgView.image = UIImage(systemName: "circlebadge.fill")
                cell.titleLable.attributedText = self.changeStrikeFont(text: cell.titleLable.text!, isFinish: itemIdentifier.isFinish,isDarkMode: self.isDarkMode)
                cell.dateLable.attributedText = self.changeStrikeFont(text: cell.dateLable.text!, isFinish: itemIdentifier.isFinish,isDarkMode: self.isDarkMode)
            } else {
                
                cell.imgView.image = UIImage(systemName: "circlebadge")
                cell.titleLable.attributedText = self.changeStrikeFont(text: cell.titleLable.text!, isFinish: itemIdentifier.isFinish,isDarkMode: self.isDarkMode)
                cell.dateLable.attributedText = self.changeStrikeFont(text: cell.dateLable.text!, isFinish: itemIdentifier.isFinish,isDarkMode: self.isDarkMode)
            }
            
            //구분선 추가
            //cell.addBottomBorder(with: .black, andWidth: 1)
           
            return cell
        })
    }
    
    func applyData() {
        
        snapshot = NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>()
        snapshot.appendSections([0])//섹션 추가
        snapshot.appendItems(getTaskDayData, toSection: 0)// 아이템 추가
        dayTaskData.apply(snapshot, animatingDifferences: true, completion: nil)// 현재 스냅샷 구현
    }
    
    //해당 계정이 가지고 있는 전체 데이터에서 선택된 날짜에 포함된 데이터 객체 filter
    func setDateData(date dateData: Date) {
        
        let start = dateData.timeIntervalSince1970
        getTaskDayData = singletonTaskData.data.filter { inTaskData in
            let startDate = Date(timeIntervalSince1970: inTaskData.startDate).zeroOfDay.timeIntervalSince1970
            
            return startDate <= start && inTaskData.endDate > start
        }
        
        applyData()
    }
    
    //notification 추가
    func addNotifications(){
        // 로그인 성공 시 설정 화면의 멘트 수정을 위한 노티 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiReload), name: Notification.Name("CalendarReloadTask") , object: nil)
        // 로그아웃 시 데이터 초기화
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiClear), name: Notification.Name("logoutTask"), object: nil)
        // background mode 변경
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeBackgroundMode), name: Notification.Name("changeBackgroundMode"), object: nil)
    }
    
    @objc func notiReload(_ noti: NSNotification) {

        self.calendarData = self.changeTimeAndPriorityToCalendarData()
        calnedarView.reloadData()
        lastSelectedDate = Date()
        setDateData(date: lastSelectedDate)
    }
    
    @objc func notiClear(_ noti: NSNotification) {
        
        getTaskDayData.removeAll()
        applyData()
        calendarData.removeAll()
        calnedarView.reloadData()
    }
    
    @objc func changeBackgroundMode() {
        
        isDarkMode = SqlLiteController.share.isDarkMode == 0 ? true : false
        backgroundSet()
        calnedarView.reloadData()
        collectionVIew.reloadData()
    }
    
    // int 값 조회하여 background mode 변경
    func backgroundSet() {
        
        if isDarkMode {
            
            collectionVIew.backgroundColor = .black
            calnedarView.backgroundColor = .black
            calnedarView.appearance.titleDefaultColor = .white
            self.view.backgroundColor = .black
        } else {
            
            collectionVIew.backgroundColor = .white
            calnedarView.backgroundColor = .white
            calnedarView.appearance.titleDefaultColor = .black
            self.view.backgroundColor = .white
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    //MARK: - detail view
    //tableview에 long gesture 추가
    func addLongGesture() {
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureToDetail))
        longGesture.minimumPressDuration = 1.0
        
        collectionVIew.addGestureRecognizer(longGesture)
    }
    
    
    //long gesture 시 detail view로 이동
    @objc func longGestureToDetail(longPressGesture: UILongPressGestureRecognizer) {
  
        // 선택된 cell 위치 구하기
        let p = longPressGesture.location(in: self.collectionVIew)
        guard let indexPath = self.collectionVIew.indexPathForItem(at: p) else { return }
        let row = indexPath.row
        // detail view 생성
        let bundle = Bundle(for: detailViewController.self)
        let detailVC = detailViewController(nibName: "detailViewController", bundle: bundle)
        detailVC.modalTransitionStyle = .crossDissolve
        detailVC.modalPresentationStyle = .overCurrentContext
        
        detailVC.delegate = self
        
        detailVC.data = getTaskDayData[row]
        
        self.present(detailVC, animated: true)
    }
}

extension CalendarViewController: TaskDataDeleteDelegate {
    
    func deleteTaskData(_ data: ToDoCellDataModel) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        dataController.deleteData(data, user) {
            self.getTaskData()
        }
    }
    
    func modifyTaskData(_ data: ToDoCellDataModel) {
        
        guard let modifyDataView = storyboard?.instantiateViewController(withIdentifier: "AddToDoListViewController") as? AddToDoListViewController else {
            return
        }
        
        modifyDataView.originTaskData = data
        self.present(modifyDataView, animated: true)
    }
}

extension CalendarViewController: FSCalendarDataSource {
    
    func changeTimeAndPriorityToCalendarData() -> [[String:Any]] {
        
        var originDateData = [[String:Any]]()
        
        for slicingData in singletonTaskData.data {
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
                return isDarkMode ? [UIColor.yellow] : [UIColor.black]
            default:
                return [UIColor.red]
            }
            
        } else if countPriority.count == 2 {
            
            switch countPriority {
            case [0,1]:
                return isDarkMode ? [UIColor.green, UIColor.yellow] : [UIColor.green, UIColor.black]
            case [1,2]:
                return isDarkMode ? [UIColor.yellow, UIColor.red] : [UIColor.black, UIColor.red]
            default:
                return [UIColor.green, UIColor.red]
            }
            
        }
        
        return isDarkMode ? [UIColor.green, UIColor.yellow, UIColor.red] : [UIColor.green, UIColor.black, UIColor.red]
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
        
        lastSelectedDate = date
        setDateData(date: lastSelectedDate)
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        //update 진행
        dataController.updateData(getTaskDayData[indexPath.row], user) {
            self.getTaskData()
        }
    }
    
    //cell 간 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    

}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        return CGSize(width: width, height: 80)
    }
}
