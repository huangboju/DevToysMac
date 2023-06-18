//
//  DeeplinkConverterView+.swift
//  DevToys
//
//  Created by 黄伯驹 on 2023/6/18.
//

import CoreUtil

class DeeplinkConverterViewController: NSViewController {
    private let cell = DeeplinkConverterView()
    
    override func loadView() {
        view = cell
    }

    
    override func viewDidLoad() {
        cell.nowButton.actionPublisher.sink { [unowned self] in
            self.addDeeplinkCell()
        }.store(in: &objectBag)
    }
    
    func addDeeplinkCell() {
        let string = cell.idField.string
        if string.isEmpty { return }

        let field = TextField()
        field.isEditable = false
        field.string = string
        cell.addSection(Section(title: "deeplink", items: [
            field
        ]))
    }
    
    private lazy var deeplinks: [String] = {
        [
            "",
            "",
            ""
        ]
    }()
}


final private class DeeplinkConverterView: Page {
    
    let idField = TextField(showCopyButton: false)
    
    let nowButton = Button(title: "Now")
    
    
    override func onAwake() {
        addSection(Section(title: "id", items: [
            NSStackView() => {
                $0.distribution = .equalSpacing
                $0.addArrangedSubview(idField)
                $0.addArrangedSubview(nowButton)
            }
        ]))
        idField.snp.remakeConstraints{ make in
            make.right.equalTo(nowButton.snp.left).inset(-8)
        }
    }
}
