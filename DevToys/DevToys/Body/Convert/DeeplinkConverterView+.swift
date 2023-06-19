//
//  DeeplinkConverterView+.swift
//  DevToys
//
//  Created by 黄伯驹 on 2023/6/18.
//

import CoreUtil

struct Item {
    let title: String
    let deeplink: String

    func deeplink(with id: String) -> String {
        deeplink.replacingOccurrences(of: ":id", with: id)
    }
}

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

        deeplinks.map { item -> TextFieldSection in
            let section = TextFieldSection(title: item.title, isEditable: false)
            section.string = item.deeplink(with: string)
            return section
        }.forEach {
            cell.addSection($0)
        }
    }
    
    private lazy var deeplinks: [Item] = {
        [
            Item(title: "图文笔详", deeplink: "xhsdiscover://item/:id"),
            Item(title: "视频笔详", deeplink: "xhsdiscover://item/:id?type=viedeo"),
            Item(title: "笔记商详", deeplink: "xhsdiscover://mini_goods_detail/:id"),
            Item(title: "主商详", deeplink: "xhsdiscover://goods_detail/:id"),
        ]
    }()
}


final private class DeeplinkConverterView: Page {
    
    let idField = TextField(showCopyButton: false)
    
    let nowButton = Button(title: "Done")
    
    
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
