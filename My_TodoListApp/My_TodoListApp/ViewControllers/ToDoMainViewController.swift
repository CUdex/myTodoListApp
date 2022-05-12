//
//  ViewController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/05/07.
//

import UIKit

class ToDoMainViewController: UIViewController {

    @IBOutlet weak var toDoListTable: UITableView!
    
    var testDate: ToDoCellData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "To Do List"
    }


}

