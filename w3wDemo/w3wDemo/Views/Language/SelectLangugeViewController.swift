//
//  SelectLangugeViewController.swift
//  w3wDemo
//
//  Created by Thảo Nguyên on 18/08/2024.
//

import UIKit
protocol SelectLangugeViewControllerDelegate: AnyObject {
    func selectLanguage(lang: String)
}

class SelectLangugeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    let vm = MapWordsViewModel()
    weak var delegete: SelectLangugeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        vm.getListLanguageSupport() { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.listLanguage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = vm.listLanguage[indexPath.row].locale
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lang = vm.listLanguage[indexPath.row].locale 
        self.delegete?.selectLanguage(lang: lang)
        self.dismiss(animated: true)
    }

}
