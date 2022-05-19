//
//  ViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/07.
//

import UIKit

class ToDoMainViewController: UIViewController {

    @IBOutlet weak var toDoListTable: UITableView!
    
    var testDate: [ToDoCellData] = [ToDoCellData(priority: 1, title: "test", date: Date(), description: nil, custom: nil, index: nil)]
    
    let spacingSection = 10.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("ToDoMainViewController - viewDidLoad")
        
        self.navigationItem.title = "To Do List"
        toDoListTable.dataSource = self
        toDoListTable.delegate = self
        toDoListTable.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        toDoListTable.sectionHeaderTopPadding = 0
        toDoListTable.cellLayoutMarginsFollowReadableWidth = false
    }
    
    
    @IBAction func reload(_ sender: Any) {
        print("ToDoMainViewController - reload")
        toDoListTable.reloadData()
    }
    
}

extension ToDoMainViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - section 간격 설정
    //셀 간격을 위하여 section 활용
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ToDoMainViewController - tableview(numberOfRowsInSection)")
        return 1
    }
    
    //각 cell 간격을 위한 section number 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        print("ToDoMainViewController - numberOfSections")
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print("ToDoMainViewController - tableview(heightForHeaderInSection)")
        return CGFloat(spacingSection / 2)
    }
    // 간격을 위한 view 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("ToDoMainViewController - tableview(viewForHeaderInSection)")
        return nil
    }
    // 간격을 위한 view 설정
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        print("ToDoMainViewController - tableview(viewForFooterInSection)")
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        print("ToDoMainViewController - tableview(heightForFooterInSection)")
        return CGFloat(spacingSection / 2)
    }
    /////////////
    //cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ToDoMainViewController - tableview(cellForRowAt)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        let doData = testDate[0]
        
        //cell.layer.masksToBounds = true
        //cell.layer.backgroundColor = CGColor.init(red: 0, green: 0, blue: 255, alpha: 0.7)
        //외곽선
        //cell.layer.borderWidth = 1
        //cell.layer.cornerRadius = 35
        //cell.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 50, right: 10))
        cell.contentView.backgroundColor = .gray
        cell.selectionStyle = .none
        cell.listCellTitleLable.text = doData.title
        cell.listCellDate.text = doData.date.description
        
        return cell
    }
    
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("ToDoMainViewController - tableview(heightForRowAt)")
        return 70
    }
    
    // MARK: - animation display cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("ToDoMainViewController - tableview(willDisplay)")
        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height)
        UIView.animate(withDuration: 0.7, delay: 0.05 * Double(indexPath.section), animations: {
              cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selectCell!!!!!!")
    }
}

