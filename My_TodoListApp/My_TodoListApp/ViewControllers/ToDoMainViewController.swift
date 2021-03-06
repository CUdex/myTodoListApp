//
//  ViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/07.
//

import UIKit
import FirebaseAuth
import Toast

class ToDoMainViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var toDoListTable: UITableView!
    @IBOutlet weak var mainLable: UILabel!
    
    let singletonTaskData = TaskData.share
    let sqliteDB = SqlLiteController.share

    fileprivate let buttonWidth: CGFloat = 80
    fileprivate let buttonHeight: CGFloat = 80
    var addListButton: MyCustomCircleButton = MyCustomCircleButton()
    
    let refresh = UIRefreshControl()
    
    //diffable을 위한 설정
    var dataSource: UITableViewDiffableDataSource<Int, ToDoCellDataModel>!
    var snapshot: NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>!
    
    let dataController = FireDataController()
    var filterSet = FilterSettingData() // filter 조건
    var filteredTaskData = [ToDoCellDataModel]() // filter된 data
    var isDarkMode = SqlLiteController.share.isDarkMode == 0 ? true : false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        if isDarkMode {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downKeyboardWhenTappedBackground()
        
        //toDoListTable.dataSource = self
        toDoListTable.dataSource = dataSource
        toDoListTable.delegate = self
        toDoListTable.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        toDoListTable.sectionHeaderTopPadding = 0
        toDoListTable.cellLayoutMarginsFollowReadableWidth = false
        
        //create button
        createButton()
        
        addNotifications() //notifications observer 등록
        //refresh 기능 추가
        toDoListTable.refreshControl = refresh
        toDoListTable.refreshControl?.addTarget(self, action: #selector(reFreshAction), for: .valueChanged)
        
        setDataSource()
        backgroundSet()
        getTaskData()
        addLongGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        changeFilterSet(filterSet)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            self.view.makeToast("please Sign In!!")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    //MARK: - data source setting
    func setDataSource() {
        //diffable 구현
        dataSource = UITableViewDiffableDataSource<Int, ToDoCellDataModel>(tableView: toDoListTable, cellProvider: { tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            cell.taskData = itemIdentifier
            
            //priority에 따른 cell color 변경
            switch itemIdentifier.priority {
            case 0:
                cell.contentView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
                cell.listCellImageView.tintColor = .green
            case 1:
                cell.contentView.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
                cell.listCellImageView.tintColor = .yellow
            default:
                cell.contentView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
                cell.listCellImageView.tintColor = .red
            }
            
            cell.selectionStyle = .none
            cell.listCellTitleLable.text = itemIdentifier.title
            let startDate = Date(timeIntervalSince1970: itemIdentifier.startDate)
            let endDate = Date(timeIntervalSince1970: itemIdentifier.isAllDay ? itemIdentifier.endDate - 1: itemIdentifier.endDate)
            
            cell.listCellDate.text = self.taskChangeDateToString(startDate, endDate, itemIdentifier.isAllDay)
            
            if self.isDarkMode {
                
                cell.listCellDate.textColor = .white
                cell.listCellTitleLable.textColor = .white
            } else {
                
                cell.listCellDate.textColor = .black
                cell.listCellTitleLable.textColor = .black
            }
            
            // 완료 여부에 따른 image 및 attribute 변경
            if itemIdentifier.isFinish {
                
                cell.listCellImageView.image = UIImage(systemName: "circlebadge.fill")
                cell.listCellTitleLable.attributedText = self.changeStrikeFont(text: cell.listCellTitleLable.text!, isFinish: itemIdentifier.isFinish, isDarkMode: self.isDarkMode)
                cell.listCellDate.attributedText = self.changeStrikeFont(text: cell.listCellDate.text!, isFinish: itemIdentifier.isFinish, isDarkMode: self.isDarkMode)
            } else {
                
                cell.listCellImageView.image = UIImage(systemName: "circlebadge")
                cell.listCellTitleLable.attributedText = self.changeStrikeFont(text: cell.listCellTitleLable.text!, isFinish: itemIdentifier.isFinish, isDarkMode: self.isDarkMode)
                cell.listCellDate.attributedText = self.changeStrikeFont(text: cell.listCellDate.text!, isFinish: itemIdentifier.isFinish, isDarkMode: self.isDarkMode)
            }
            
            return cell
        })
    }
    
    //tableview에 long gesture 추가
    func addLongGesture() {
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureToDetail))
        longGesture.minimumPressDuration = 1.0
        
        toDoListTable.addGestureRecognizer(longGesture)
    }
    
    
    //long gesture 시 detail view로 이동
    @objc func longGestureToDetail(longPressGesture: UILongPressGestureRecognizer) {
  
        // 선택된 cell 위치 구하기
        let p = longPressGesture.location(in: self.toDoListTable)
        guard let indexPath = self.toDoListTable.indexPathForRow(at: p) else { return }
        let row = indexPath.row
        
        // detail view 생성
        let bundle = Bundle(for: detailViewController.self)
        let detailVC = detailViewController(nibName: "detailViewController", bundle: bundle)
        detailVC.modalTransitionStyle = .crossDissolve
        detailVC.modalPresentationStyle = .overCurrentContext
        
        detailVC.delegate = self
        
        detailVC.data = filteredTaskData[row]
        
        self.present(detailVC, animated: true)
    }
    
    //MARK: - diffable apply
    func applySnapshot() {
        
        //현재 상태인 snapshot 설정
        snapshot = NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>()
        //섹션 추가
        snapshot.appendSections([0])
        // 아이템 추가
        snapshot.appendItems(filteredTaskData, toSection: 0)
        // 현재 스냅샷 구현
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    //MARK: - get data
    func getTaskData() {
        
        guard let user = Auth.auth().currentUser else {
            applySnapshot()
            return
        }
        
        dataController.getData(user) { data in
            
            self.singletonTaskData.data = data
            NotificationCenter.default.post(name: Notification.Name("CalendarReloadTask"), object: nil)
            self.changeFilterSet(self.filterSet)
        }
    }
    
    @IBAction func scopeButtonAction(_ sender: Any) {
        
        let filterVC = FilterViewController()
        
        filterVC.delegate = self
        filterVC.ViewDataSetting(filterSet)
        filterVC.sheetPresentationController?.detents = [.medium()]
        
        present(filterVC, animated: true)
    }
    
    //MARK: - refresh 시 사용되는 액션
    @objc func reFreshAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.getTaskData()
            self.refresh.endRefreshing()
        }
    }
    
}

extension ToDoMainViewController: FilterSettingDelegate {
    
    //data filtering
    func changeFilterSet(_ data: FilterSettingData) {
        
        filterSet = data

        filteredTaskData = singletonTaskData.data.filter { inTaskData in
            
            let firstCondition = inTaskData.endDate <= filterSet.endDay && inTaskData.endDate >= filterSet.startDay
            let secondCondition = inTaskData.startDate >= filterSet.startDay && inTaskData.endDate <= filterSet.endDay
            let thirdCondition = inTaskData.startDate >= filterSet.startDay && inTaskData.startDate <= filterSet.endDay
            let fourthCondition = inTaskData.startDate <= filterSet.startDay && inTaskData.endDate >= filterSet.endDay
            var checkPriority = true
            var checkFinished = true
            
            if filterSet.priority != .all {
                checkPriority = (inTaskData.priority == filterSet.priority.rawValue)
            }
            if filterSet.isFinished != .all {
                
                let finish = (filterSet.isFinished == .finished ? true : false)
                checkFinished = (finish == inTaskData.isFinish)
            }
            return (firstCondition || secondCondition || thirdCondition || fourthCondition) && checkPriority && checkFinished
        }
        applySnapshot()
    }
}

extension ToDoMainViewController: UITableViewDelegate {
    
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    //cell 선택 시 해당 cell ui 변경
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        //update 진행
        dataController.updateData(filteredTaskData[indexPath.row], user) {
            self.getTaskData()
        }
    }
}

extension ToDoMainViewController {
    
    func createButton() -> Void {
        // MARK: - create add data buttion
        self.view.addSubview(addListButton)
        
        //constaraint를 수정할 수 있도록 false 설정
        addListButton.translatesAutoresizingMaskIntoConstraints = false
        //button size
        addListButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        addListButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        //button location
        addListButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        addListButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        addListButton.layer.cornerRadius = buttonHeight / 2
        addListButton.addTarget(self, action: #selector(presentAddToDoListView), for: .touchUpInside)
    }
    
    @objc func presentAddToDoListView() -> Void {
        
        if Auth.auth().currentUser == nil {
            self.view.makeToast("please sign in")
        } else {
            
            //view 이동을 위한 ID로 view 확인
            guard let addDataView = storyboard?.instantiateViewController(withIdentifier: "AddToDoListViewController") else {
                return
            }
            present(addDataView, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - 로그인 성공 시 데이터 리로드 및 background 변경에 따른 mode 변경
    func addNotifications(){
        
        // 로그인 성공 시 설정 화면의 멘트 수정을 위한 노티 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiReload), name: Notification.Name("reloadTask") , object: nil)
        // 로그아웃 시 데이터 초기화
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiClear), name: Notification.Name("logoutTask"), object: nil)
        // background mode 변경
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeBackgroundMode), name: Notification.Name("changeBackgroundMode"), object: nil)
    }
    
    @objc func notiReload() {
        
        getTaskData()
    }
    
    @objc func notiClear() {
        
        //self.taskData.removeAll()
        self.singletonTaskData.data.removeAll()
        getTaskData()
    }
    
    
    @objc func changeBackgroundMode() {
        
        isDarkMode = SqlLiteController.share.isDarkMode == 0 ? true : false
        backgroundSet()
        toDoListTable.reloadData()
    }
    
    // int 값 조회하여 background mode 변경
    func backgroundSet() {
        
        if isDarkMode {
            
            mainLable.textColor = .white
            toDoListTable.backgroundColor = .black
            self.view.backgroundColor = .black
        } else {
            
            mainLable.textColor = .black
            toDoListTable.backgroundColor = .white
            self.view.backgroundColor = .white
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
}


extension ToDoMainViewController: TaskDataDeleteDelegate {
    
    //MARK: - detail view에서 modify view로 넘김
    func modifyTaskData(_ data: ToDoCellDataModel) {
        
        guard let modifyDataView = storyboard?.instantiateViewController(withIdentifier: "AddToDoListViewController") as? AddToDoListViewController else {
            return
        }
        
        modifyDataView.originTaskData = data
        self.present(modifyDataView, animated: true)
    }
    
    func deleteTaskData(_ data: ToDoCellDataModel) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        dataController.deleteData(data, user) {
            self.getTaskData()
        }
    }
}
