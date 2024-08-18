//
//  ListHisWordsViewController.swift
//  w3wDemo
//
//  Created by Thảo Nguyên on 18/08/2024.
//

import UIKit
protocol ListHisWordsViewControllerDelegate: AnyObject {
    func selectHistoryWord(words: String)
}
class ListHisWordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let vm = MapWordsViewModel()
    weak var delegete: ListHisWordsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        vm.getCoreDataWords()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.listWord.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "///\(vm.listWord[indexPath.row].words ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let words = vm.listWord[indexPath.row].words ?? ""
        self.delegete?.selectHistoryWord(words: words)
        self.dismiss(animated: true)
    }

}
