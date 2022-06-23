//
//  ViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/07.
//

import UIKit
import FirebaseAuth
import Toast

class ToDoMainViewController: UIViewController {

    @IBOutlet weak var toDoListTable: UITableView!
    
    var testDate: [ToDoCellDataModel] = [ToDoCellDataModel(priority: 1, title: "test", startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, description: "",isAllDay: true,isFinish: true)]

    fileprivate let buttonWidth: CGFloat = 80
    fileprivate let buttonHeight: CGFloat = 80
    var addListButton: MyCustomCircleButton = MyCustomCircleButton()
    //let spacingSection = 10.0
    
    //storyboard 연결
    let addDataStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let refresh = UIRefreshControl()
    
    
    //diffable을 위한 설정
    var dataSource: UITableViewDiffableDataSource<Int, ToDoCellDataModel>!
    var snapshot: NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("ToDoMainViewController - viewDidLoad")
        
        self.downKeyboardWhenTappedBackground()
        
        //toDoListTable.dataSource = self
        toDoListTable.dataSource = dataSource
        toDoListTable.delegate = self
        toDoListTable.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        toDoListTable.sectionHeaderTopPadding = 0
        toDoListTable.cellLayoutMarginsFollowReadableWidth = false
        
        //create button
        createButton()
        
        addSignInSuccessNotifications() //로그인 성공 시 데이터 리로드
        //refresh 기능 추가
        toDoListTable.refreshControl = refresh
        toDoListTable.refreshControl?.addTarget(self, action: #selector(reFreshAction), for: .valueChanged)
        
        
        //diffable 구현
        dataSource = UITableViewDiffableDataSource<Int, ToDoCellDataModel>(tableView: toDoListTable, cellProvider: { tableView, indexPath, itemIdentifier in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            
            cell.contentView.backgroundColor = .systemBrown
            cell.selectionStyle = .none
            cell.listCellTitleLable.text = itemIdentifier.title
            cell.listCellDate.text = itemIdentifier.startDate.description
            
            return cell
        })
        //현재 상태인 snapshot 설정
        snapshot = NSDiffableDataSourceSnapshot<Int, ToDoCellDataModel>()
        //섹션 추가
        snapshot.appendSections([0])
        // 아이템 추가
        snapshot.appendItems(testDate, toSection: 0)
        // 현재 스냅샷 구현
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ToDoMain - willappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("ToDoMain - willdisappear")
    }
    
    @IBAction func scopeButtonAction(_ sender: Any) {
        
        testDate.append(ToDoCellDataModel(priority: 1, title: "test", startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, description: "",isAllDay: true,isFinish: true))
        snapshot.appendItems(testDate, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        
    }
    //MARK: - refresh 시 사용되는 액션
    @objc func reFreshAction() {
        testDate.append(ToDoCellDataModel(priority: 1, title: "test", startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, description: "",isAllDay: true,isFinish: true))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.snapshot.appendItems(self.testDate, toSection: 0)
            self.dataSource.apply(self.snapshot, animatingDifferences: true, completion: nil)
            self.refresh.endRefreshing()
        }
    }
    
}

extension ToDoMainViewController: UITableViewDelegate {
    
    // MARK: - section 간격 설정
    //셀 간격을 위하여 section 활용
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("ToDoMainViewController - tableview(numberOfRowsInSection)")
//        return 1
//    }
    
    //각 cell 간격을 위한 section number 설정
//    func numberOfSections(in tableView: UITableView) -> Int {
//        print("ToDoMainViewController - numberOfSections")
//        return testDate.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        print("ToDoMainViewController - tableview(heightForHeaderInSection)")
//        return CGFloat(spacingSection / 2)
//    }
//    // 간격을 위한 view 설정
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        print("ToDoMainViewController - tableview(viewForHeaderInSection)")
//        return nil
//    }
//    // 간격을 위한 view 설정
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        print("ToDoMainViewController - tableview(viewForFooterInSection)")
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        print("ToDoMainViewController - tableview(heightForFooterInSection)")
//        return CGFloat(spacingSection / 2)
//    }
    
    //cell data
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("ToDoMainViewController - tableview(cellForRowAt)")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
//
//        let doData = testDate[0]
//
//        cell.contentView.backgroundColor = .systemBrown
//        cell.selectionStyle = .none
//        cell.listCellTitleLable.text = doData.title
//        cell.listCellDate.text = doData.startDate.description
//
//        return cell
//    }
    
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("ToDoMainViewController - tableview(heightForRowAt)")
        return 80
    }
    
    // MARK: - animation display cell
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("ToDoMainViewController - tableview(willDisplay)")
//        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height)
//        UIView.animate(withDuration: 0.7, delay: 0.05 * Double(indexPath.section), animations: {
//              cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
//        })
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selectCell!!!!!!")
    }
}


// MARK: - add data button function
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
    
    
    //MARK: - 로그인 성공 시 데이터 리로드
    func addSignInSuccessNotifications(){
        // 로그인 성공 시 설정 화면의 멘트 수정을 위한 노티 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.notiReload(_:)), name: Notification.Name("SuccessSignIn") , object: nil)
    }
    
    @objc func notiReload(_ noti: NSNotification) {
        self.toDoListTable.reloadData()
    }
}
