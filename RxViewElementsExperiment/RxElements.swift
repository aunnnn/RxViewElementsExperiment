//
//  RxElements.swift
//  RxViewElementsExperiment
//
//  Created by Wirawit Rueopas on 12/8/2560 BE.
//  Copyright © 2560 Wirawit Rueopas. All rights reserved.
//

import RxSwift
import RxCocoa
import ViewElements

typealias RxSetupBlock<U: UIView & OptionalTypedPropsAccessible> = (Reactive<U>) -> [Disposable]

class RxButton: BaseButton, OptionalTypedPropsAccessible {
    typealias PropsType = (title: String, rx: RxSetupBlock<RxButton>?)
    
    private var disposeBag: DisposeBag?
    
    override func setup() {
        
    }
    
    override func update() {
        guard let props = self.props else {
            self.setTitle(nil, for: .normal)
            self.disposeBag = nil
            return
        }
        
        let disposeBag = DisposeBag()
        
        if let rx = props.rx {
            rx(self.rx).forEach({ (d) in
                d.disposed(by: disposeBag)
            })
        }
        self.setTitle(props.title, for: .normal)
        self.disposeBag = disposeBag
    }
}

class RxTextField: BaseTextField, OptionalTypedPropsAccessible {
    typealias PropsType = (placeholder: String, text: Variable<String?>, rx: RxSetupBlock<RxTextField>?)
    
    private var disposeBag: DisposeBag?
    
    override func setup() {
    }
    
    override func update() {
        guard let props = self.props else {
            self.text = nil
            self.placeholder = nil
            self.disposeBag = nil
            return
        }
        
        let disposeBag = DisposeBag()
        
        if let rx = props.rx {
            rx(self.rx).forEach({ (d) in
                d.disposed(by: disposeBag)
            })
        }
        self.text = props.text.value
        self.placeholder = props.placeholder
        
        // Two-way bindings
        self.rx.text.asObservable().bind(to: props.text).disposed(by: disposeBag)
        props.text.asObservable().bind(to: rx.text).disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }
}

class RxLabel: BaseLabel, OptionalTypedPropsAccessible {
    
    typealias PropsType = (text: Observable<String?>, rx: RxSetupBlock<RxLabel>?)
    private var disposeBag: DisposeBag?
    
    override func setup() {
        self.numberOfLines = 0
        self.textColor = .black
        self.isUserInteractionEnabled = false
        //        self.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        //        self.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
    }
    
    override func update() {
        guard let props = self.props else {
            self.disposeBag = nil
            self.text = nil
            return
        }
        
        let disposeBag = DisposeBag()
        
        if let rx = props.rx {
            rx(self.rx).forEach({ (d) in
                d.disposed(by: disposeBag)
            })
        }
        
        props.text.bind(to: self.rx.text).disposed(by: disposeBag)
        
        self.disposeBag = disposeBag
    }
}
