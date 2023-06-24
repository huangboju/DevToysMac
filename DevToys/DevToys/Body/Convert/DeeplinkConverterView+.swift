//
//  DeeplinkConverterView+.swift
//  DevToys
//
//  Created by 黄伯驹 on 2023/6/18.
//

import CoreUtil
import Alamofire

struct DeeplinkModel: Codable {
    let items: [Item]
}

struct Item: Codable {
    let title: String
    let deeplink: String

    func deeplink(with id: String) -> String {
        deeplink.replacingOccurrences(of: ":id", with: id)
    }
}

class DeeplinkConverterViewController: NSViewController {
    private let cell = DeeplinkConverterView()
    
    private var deeplinkModel: DeeplinkModel?
    
    override func loadView() {
        view = cell
    }

    
    override func viewDidLoad() {
        cell.nowButton.actionPublisher.sink { [unowned self] in
            self.addDeeplinkCell()
        }.store(in: &objectBag)
        
        fetchDeeplinkFile()
    }
    
    func fetchDeeplinkFile() {
        let destination: DownloadRequest.Destination = { _, _ in
            let directory = self.directory

            self.createDirectoryIfNeeded(directory)
            
            let fileURL = directory.appendingPathComponent("deeplink.json")

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        AF.download("https://raw.githubusercontent.com/huangboju/Actions/main/deeplink.json?token=GHSAT0AAAAAACC5BWYOO2Y6UYZYKUY6UAM6ZEWV7AA", to: destination).response { response in
            debugPrint(response)

            if response.error == nil, let filePath = response.fileURL?.path {
                if #available(macOS 13.0, *) {
                    do {
                        let data = try Data(contentsOf: URL(filePath: filePath), options: .mappedIfSafe)
                        let model = try JSONDecoder().decode(DeeplinkModel.self, from: data)
                        self.deeplinkModel = model
                    } catch {
                        print(error)
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    func createDirectoryIfNeeded(_ directory: URL) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch let error {
            print("❌\(error)")
        }
    }
    
    var directory: URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent("com.bula.deeplink")
    }
    
    func addDeeplinkCell() {
        guard let deeplinkModel else { return }

        let string = cell.idField.string
        if string.isEmpty { return }

        deeplinkModel.items.map { item -> TextFieldSection in
            let section = TextFieldSection(title: item.title, isEditable: false)
            section.string = item.deeplink(with: string)
            return section
        }.forEach {
            cell.addSection($0)
        }
    }
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
