//
//  ViewController.swift
//  w3wDemo
//
//  Created by Thảo Nguyên on 18/08/2024.
//

import UIKit
import W3WSwiftCore
import W3WSwiftApi
import W3WSwiftComponents
import CoreLocation

class ViewController: W3WMapViewController {

    let testData = ClippingSettings()
    let vm = MapWordsViewModel()
    
    var textField: W3WAutoSuggestTextField?
    var hisBtn: UIButton {
        let btn = UIButton(frame: CGRect(x: 16 , y: 50, width: 150, height: 30))
        btn.isUserInteractionEnabled = true
        btn.setTitle("View History", for: .normal)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(tapViewHistoy), for: .touchUpInside)
        return btn
        
    }
    var languageBtn: UIButton {
        let btn = UIButton(frame: CGRect(x: hisBtn.frame.width + 20 , y: 50, width: 150, height: 30))
        btn.isUserInteractionEnabled = true
        btn.setTitle("Select language", for: .normal)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(tapSelectLanguage), for: .touchUpInside)
        return btn
        
    }
    var clipppingOptions : [W3WOption]
    {
        let testData = ClippingSettings()
        if let shape = UserDefaults.standard.string(forKey: "Clipping")
        {
            if let clipping = ClippingType(rawValue: shape)
            {
                return testData.getClippingOptions(option : clipping)
            }
        }
        return testData.getClippingOptions(option : ClippingType.NoClipping)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIHistory()
        setupUILanguage()
        setupInputField()
        setupMap()
    }
    func setupUIHistory() {
        view.addSubview(hisBtn)
    }
    func setupUILanguage() {
        view.addSubview(languageBtn)
    }
   
    func setupInputField() {
        guard let api = vm.api else { return  }
        // assign the API to it
        textField = W3WAutoSuggestTextField(frame: CGRect(x: 16,y: 90, width: UIScreen.main.bounds.width - 32, height: 32.0))
        guard let textField else { return }
        textField.accessibilityIdentifier = "w3wTextField"
        textField.set(api)
        textField.set(options: clipppingOptions)
        // turn on voice support
        textField.set(voice: true)
        textField.set(language: W3WBaseLanguage(code: "en"))

        // assign a code block to execute when the user has selected an address
        textField.onSuggestionSelected = { suggestion in
            guard let words = suggestion.words, !words.isEmpty else {return}
            self.searchPlace(words: words)
        }
        // the exact error can be captured using onError for whatever purpose you might have
        textField.onError = { error in
        self.showError(error: error)
        }
        view.addSubview(textField)

    }
    func setupMap(){
        guard let api = vm.api else { return  }
        set(api)

        // when a point on the map is touched, highlight that square, and put it's word into the text field
        self.onSquareSelected = { square in
            guard let words = square.words, !words.isEmpty else {return}
            self.searchPlace(words: words)
        }

        // make a satelite/map button, and attach it
        let button = W3WMapTypeButton()
        attach(view: button, position: .bottomRight)

        // if the is an error then put it into an alert
        onError = { error in self.showError(error: error) }

    }
    func showPlaceOpposit(words: String) {
        DispatchQueue.main.async {
            if let foundView = self.view.viewWithTag(999) {
                foundView.removeFromSuperview()
            }
            let label = UILabel(frame: CGRect(x: 16, y: 100, width: self.view.frame.width, height: 100))
            label.text = "Words opposite: \(words)"
            label.textColor = .red
            label.tag = 999
            self.view.addSubview(label)
        }
    }
    func searchPlace(words: String) {
        self.removeAllMarkers()
        self.vm.addCoreDataWord(words: words)
        self.addMarker(at: words, camera: .zoom)
        self.vm.findPlaceOpposite(input: words) { [weak self] word in
            self?.showPlaceOpposit(words: word)
        }
    }
    func showError(error: Error) {
      DispatchQueue.main.async {
        print(String(describing: error))
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
      }
    }
    @objc func tapViewHistoy(sender: UIButton){
        let vc = ListHisWordsViewController()
        vc.delegete = self
        self.present(vc, animated: true)
    }
    @objc func tapSelectLanguage(sender: UIButton){
        let vc = SelectLangugeViewController()
        vc.delegete = self
        self.present(vc, animated: true)
    }
}
   
    
extension ViewController : ListHisWordsViewControllerDelegate {
    func selectHistoryWord(words: String) {
        let suggest = W3WBaseSuggestion(words: words)
        print("Words selected: \(suggest)")
        textField?.update(selected: suggest)
    }
}
extension ViewController : SelectLangugeViewControllerDelegate {
    func selectLanguage(lang: String) {
        print("Language selected: \(lang)")
        textField?.set(language: W3WBaseLanguage(code: lang))
        textField?.set(vm.api!, language: W3WBaseLanguage(code: lang))
    }
   
}




