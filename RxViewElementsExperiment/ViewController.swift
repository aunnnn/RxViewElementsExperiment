//
//  ViewController.swift
//  RxViewElementsExperiment
//
//  Created by Wirawit Rueopas on 12/7/2560 BE.
//  Copyright © 2560 Wirawit Rueopas. All rights reserved.
//

import ViewElements
import RxSwift
import RxCocoa

class ViewController: TableModelViewController {
    
    let disposeBag = DisposeBag()
    
    let username = Variable<String?>("")
    let password = Variable<String?>("")
    
    let msg = Variable<String?>("Please login!")
    
    var btnRow: Row?
    
    let like = Variable<Bool>(false)
    let likesCount = Variable<Int>(1000)
    
    override func setupTable() {
        
        let welcome = Row(ElementOfLabel(props: "Welcome!").styles { (lb) in
            lb.font = UIFont.boldSystemFont(ofSize: 40)
            lb.textAlignment = .center
        })
        let spc44 = RowOfEmptySpace(height: 44)
        
        let tf1 = Row(ElementOf<RxTextField>.init(props: ("Your username", self.username, nil)))
        let tf2 = Row(ElementOf<RxTextField>.init(props: ("Your password", self.password, nil)).styles({ (tf) in
            tf.isSecureTextEntry = true
        }))
        
        [tf1,tf2].forEach { (row) in
            row.backgroundColor = .groupTableViewBackground
            row.rowHeight = 44
            row.layoutMarginsStyle = .each(vertical: 0, horizontal: 12)
        }
        
        let msg = Row(ElementOf<RxLabel>.init(props: (self.msg.asObservable(), nil)).styles({ (lb) in
            lb.font = .systemFont(ofSize: 12)
            lb.textColor = .black
            lb.textAlignment = .center
        }))
        
        // **
        msg.rowHeight = 44
        
        username.asObservable().subscribe { [unowned self] (e) in
            
            let s = (e.element ?? "")
            let s_ = s ?? ""
            let ok = s_.count > 4
            self.msg.value = ok ?
                "Username OK! (\(s_.count))"
                :
                "Username must have length more than 4! (\(s_.count))"
            
        }.disposed(by: self.disposeBag)
        
        // ------
        // BUTTON
        // ------
        let btn = Row(ElementOf<RxButton>.init(props: (Observable<String?>.just("Login"), { [unowned self] rx in
            
            // Input Valid?
            let validInputs = Observable
                .combineLatest([self.username.asObservable(), self.password.asObservable()])
                .map { (vals) -> Bool in
                    return vals[0]!.count > 4 && vals[1]!.count > 4
            }.share()
            
            // 1. Add event action
            let d1 = rx.tap.subscribe({ [unowned self] (e) in
                let loading = Row(ElementOfActivityIndicator(props: true))
                
                let btnInd = self.table.sections.first!.rows.enumerated().filter({ (off, el) -> Bool in
                    el.tag == "btn"
                }).first!.offset
                
                self.btnRow = self.table.sections.first?.rows.remove(at: btnInd)
                self.table.sections.first?.rows.insert(loading, at: btnInd)
                self.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
                    guard let `self` = self else { return }
                    self.table.sections.first?.rows.remove(at: btnInd)
                    self.table.sections.first?.rows.insert(self.btnRow!, at: btnInd)
                    self.msg.value = "Wow, you just logged in."
                    self.tableView.reloadData()
                })
            })
            
            // 2. Bind button's enabled
            let d2 = validInputs.bind(to: rx.isEnabled)

            // 3. Bind alpha
            let d3 = validInputs.bind(onNext: { (valid) in
                rx.base.alpha = valid ? 1.0 : 5.0
                rx.base.titleLabel?.font = valid ? UIFont.boldSystemFont(ofSize: 25) : UIFont.systemFont(ofSize: 18)
            })

            return [d1, d2, d3]
        })).styles({ (btn) in
            btn.setTitleColor(.blue, for: .normal)
            btn.setTitleColor(.red, for: UIControlState.highlighted)
        }))
        btn.tag = "btn"
        
        
        // Testing Component
        
        
        let panel = ActivityPanelComponent(props: (self.like, self.likesCount))≥
        
        
        let test = (1...10).flatMap { (val) -> [Row] in
            let panel = Row(ActivityPanelComponent(props: (Variable<Bool>(val % 2 == 0), Variable<Int>(val))))
            return [
                panel,
                spc44,
                spc44,
            ]
        }
        
        let rows = [
            spc44,
            welcome,
            spc44,
            tf1,
            tf2,
            spc44,
            btn,
            spc44,
            msg,
            tf1,
            ] + test
        
        let section = Section(header: SectionHeader(panel), footer: nil, rows: rows)
        let table = Table(sections: [section])
        table.centersContentIfPossible = true
        self.table = table
    }
}
