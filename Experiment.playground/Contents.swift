//: Playground - noun: a place where people can play

import PlaygroundSupport
import ViewElements
import RxSwift
import RxCocoa

class ViewController: TableModelViewController {
    
    let username = Variable<String?>(nil)
    let password = Variable<String?>(nil)
    
    override func setupTable() {
        let tf1 = ElementOf<RxTextField>.init(props: ("Your username", username))
        let tf2 = ElementOf<RxTextField>.init(props: ("Your password", password))
    
        let btn = ElementOfButtonWithAction(props: ("Login", {
            print("pressed!")
        }))
        
        let all: [Row] = [tf1,tf2,btn].map { (el: ElementOfView) in
            return Row(el)
        }
        
        self.table = Table(sections: [Section.init(rows: all)])
    }
}


class RxTextField: BaseTextField, OptionalTypedPropsAccessible {
    typealias PropsType = (placeholder: String, text: Variable<String?>)
    
    private var disposable: Disposable?
    
    override func setup() {
    }
    
    override func update() {
        guard let props = self.props else {
            disposable?.dispose()
            disposable = nil
            self.text = nil
            self.placeholder = nil
            return
        }
        self.text = props.text.value
        self.placeholder = props.placeholder
        self.disposable = self.rx.text.bind(to: props.text)
    }
}

class RxLabel: BaseLabel, OptionalTypedPropsAccessible {
    
    typealias PropsType = (Variable<String?>)
    private var disposable: Disposable?
    
    override func setup() {
        
    }
    
    override func update() {
        guard let props = self.props else {
            disposable?.dispose()
            disposable = nil
            self.text = nil
            return
        }
        self.text = props.value
        self.disposable = props.asObservable().bind(to: self.rx.text)
    }
}

let vc = ViewController()
vc.view.frame = .init(x: 0, y: 0, width: 320, height: 400)
vc.preferredContentSize = vc.view.frame.size
PlaygroundPage.current.liveView = vc.view
PlaygroundPage.current.needsIndefiniteExecution = true
