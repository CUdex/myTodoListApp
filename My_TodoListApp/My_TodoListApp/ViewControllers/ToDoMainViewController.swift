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
        
        self.navigationItem.title = "To Do List"
        toDoListTable.dataSource = self
        toDoListTable.delegate = self
        toDoListTable.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        toDoListTable.sectionHeaderTopPadding = 0
        

    }

}

extension ToDoMainViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    //셀 간격을 위하여 section 활용
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //각 cell 간격을 위한 section number 설정
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(spacingSection / 2)
    }
    // 간격을 위한 view 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
    // 간격을 위한 view 설정
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(spacingSection / 2)
    }
    
    //cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        let doData = testDate[0]
        
        cell.listCellTitleLable.text = doData.title
        cell.listCellDate.text = doData.date.description
        
        return cell
    }
    
    //cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    

    
}

