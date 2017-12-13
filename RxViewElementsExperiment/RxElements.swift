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



typealias ActivityPanelProps = (like: Variable<Bool>, likesCount: Variable<Int>)

class ActivityPanelComponent: ComponentOf<ActivityPanelProps> {
    
    override func shouldElementUpdate(oldProps: ActivityPanelProps, newProps: ActivityPanelProps) -> Bool {
        return oldProps.like.value != newProps.like.value || oldProps.likesCount.value != newProps.likesCount.value
    }
    
    override func render() -> StackProps {
        let obs: Observable<String?> = props.like.asObservable().map { (b) -> String? in
            return b ? "Liked!" : "Like it"
        }
//        let lb = ElementOf<RxLabel>.init(props: (text: obs, rx: nil))
        
//        let btn = ElementOfButtonWithAction(props: ("Like", { [unowned self] in
//            let originalValue = self.props.like.value
//            self.props.like.value = !originalValue
//            self.props.likesCount.value = self.props.likesCount.value + (originalValue ? -1 : 1)
//        }))
        

        let btn = ElementOf<RxButton>.init(props: (title: obs, rx: { [weak self] (rx: Reactive<RxButton>) -> [Disposable] in
            guard let `self` = self else { return [] }
            let dis = rx.tap.bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                let originalValue = self.props.like.value
                self.props.like.value = !originalValue
                self.props.likesCount.value = self.props.likesCount.value + (originalValue ? -1 : 1)
            })
            
            let dis2 = self.props.like.asObservable().bind(onNext: { (val) in
                rx.base.backgroundColor = val ? .green : .gray
            })
            
            return [dis, dis2]
        })).styles { (btn) in
            btn.backgroundColor = .green
        }
        
        let lbCount = ElementOf<RxLabel>.init(props: (text: self.props.likesCount.asObservable().map { (val: Int) -> String in
            return "\(val)"
        }, rx: nil))
        
        return
            HorizontalStack(
                distribute: .fillEqually,
                align: .center,
                spacing: 8, [
                    btn,
                    lbCount,
                ])
    }
}

class RxButton: BaseButton, OptionalTypedPropsAccessible {
    typealias PropsType = (title: Observable<String?>, rx: RxSetupBlock<RxButton>?)
    
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
        props.title.bind(to: self.rx.title()).disposed(by: disposeBag)
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
