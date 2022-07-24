//
//  SqlLiteController.swift
//  My_TodoListApp
//
//  Created by cudex on 2022/07/23.
//

import Foundation
import SQLite3

class SqlLiteController {
    
    static let share = SqlLiteController()
    var db: OpaquePointer?
    let databaseName = "mydb.sqlite"
    let TABLE_NAME: String = "BackgroundSet"
    let COL_NAME: String = "IsDarkMode"
    var isDarkMode: Int32 = 1
    
    private init() {
        self.db = createDB()
        createTable()
        insertRow()
        selectRow()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    private func createDB() -> OpaquePointer? {
        
        var cdb: OpaquePointer? = nil
        
        do {
            
            let dbpath: String = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(databaseName).path
            
            if sqlite3_open(dbpath, &cdb) == SQLITE_OK {
                
                print("success create DB : \(dbpath)")
                return cdb
            } else {
                
                print("error while opening database")
                sqlite3_close(cdb)
            }
        } catch {
            
            print("Error while create DB : \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private func createTable() {
        
        var statement: OpaquePointer?
        let query = "CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (id INTEGER PRIMARY KEY, \(COL_NAME) INTEGER);"
        
        // query 준비, sql에 대한 객체 전환 진행
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            
            // sql 실행 및 결과 평가 진행
            if sqlite3_step(statement) == SQLITE_DONE{
                
                print("\nsuccess crate table \(TABLE_NAME) : \(String(describing: self.db))")
            } else {
                
                print("\nfailure create table \(TABLE_NAME) : \(String(cString: sqlite3_errmsg(self.db)))")
            }
        } else {
            
            print("prepare v2 error : \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement) // 메모리에서 statement 할당 해제
    }
    
    // insert의 경우 하나의 row만 필요하기 때문에 private 함수로 이용하여 구현
    private func insertRow() {
        
        var statement: OpaquePointer?
        let query = "INSERT OR IGNORE INTO \(TABLE_NAME)(id, \(COL_NAME)) VALUES (1, 1);"
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_DONE{
                
                print("\nsuccess query \(TABLE_NAME) : \(String(describing: self.db))")
            } else {
                
                print("\nfailure query \(TABLE_NAME) : \(String(cString: sqlite3_errmsg(self.db)))")
            }
        } else {
            
            print("prepare v2 error : \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
    
    // viewcontroller들이 view load 시 mode 조회를 위한 db 조회
    private func selectRow() {
        
        var statement: OpaquePointer?
        let query = "SELECT \(COL_NAME) FROM \(TABLE_NAME)"
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_ROW{
                
                let resultCol = sqlite3_column_int(statement, 0)
                
                isDarkMode = resultCol
                print("\nsuccess query \(TABLE_NAME) : \(String(describing: self.db))")
                print("\nquery result : \(COL_NAME) - \(resultCol)")
            } else {
                
                print("\nfailure query \(TABLE_NAME) : \(String(cString: sqlite3_errmsg(self.db)))")
            }
        } else {
            
            print("prepare v2 error : \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
    
    func updateRow(_ selectMode: Int32) {
        
        isDarkMode = selectMode
        var statement: OpaquePointer?
        let query = "UPDATE \(TABLE_NAME) SET \(COL_NAME) = \(selectMode)"
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_DONE{
                
                print("\nsuccess query \(TABLE_NAME) : \(String(describing: self.db))")
            } else {
                
                print("\nfailure query \(TABLE_NAME) : \(String(cString: sqlite3_errmsg(self.db)))")
            }
        } else {
            
            print("prepare v2 error : \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
}
