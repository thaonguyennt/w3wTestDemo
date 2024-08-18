//
//  MapWordsViewModel.swift
//  w3wDemo
//
//  Created by Thảo Nguyên on 18/08/2024.
//

import Foundation
import CoreData
import UIKit
import W3WSwiftCore
import W3WSwiftApi
import W3WSwiftComponents
import CoreLocation

class MapWordsViewModel {
    var apiKey: String = "CTF89056"
    var api: What3WordsV4?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var listWord = [Word]()
    var listLanguage = [W3WLanguage]()
    
    init() {
        api = What3WordsV4(apiKey: apiKey)
    }
    func getApikeyFromFile() -> String? {
      var apikey: String? = nil

      let url = URL(fileURLWithPath: "/tmp/key.txt")
      if let key = try? String(contentsOf: url, encoding: .utf8) {
        apikey = key.trimmingCharacters(in: .whitespacesAndNewlines)
      }

      return apikey
    }
    func findPlaceOpposite(input: String, completed: @escaping (String) -> ()) {
        guard let api = api else { return  }
        api.convertToCoordinates(words: input)  { (square, error) in

          // if there was an error, print it
          if let e = error {
            print(String(describing: e))

            // on success print the result
          } else if let s = square {
              guard let lat = s.coordinates?.latitude,
                    let lng = s.coordinates?.longitude else {return}
            print("The coordinates for ", (s.words ?? ""), " are ", ( lat ?? "?"), ", ", (lng ?? "?"))
              self.convertToTextInputOppo(lat: lat, lng: lng, completed: { word in
                  completed(word)
              })
          }

        }
    }
    func convertToTextInputOppo(lat: CLLocationDegrees, lng: CLLocationDegrees, completed: @escaping (String) -> ()) {
        let oppositeLng = lng > 0 ? lng - 180 : lng + 180
        let coords = CLLocationCoordinate2D(latitude: -lat, longitude: oppositeLng)
        print("Lat-Lng Opposite: \(lat) -- \(oppositeLng)")
        api?.convertTo3wa(coordinates: coords, language: W3WApiLanguage(locale: "en")) { square, error in
            completed(square?.words ?? "")
        }
    }
    func addCoreDataWord(words: String) {
        let word = Word(context: context)
        word.words = words
        word.createAt = Date.now
        do {
            try context.save()
        } catch {
            print("error-Saving data")
        }
    }
    func getCoreDataWords() {
        do {
            let results = try context.fetch(Word.fetchRequest())
                
                // Remove duplicates based on a unique attribute
                var uniqueResults = [String: Word]()
                for result in results {
                    uniqueResults[result.words ?? ""] = result
                }
                
                listWord = Array(uniqueResults.values)
            
        }
        catch {
            print("error-Get data")
        }
    }
    func getListLanguageSupport(completed: @escaping (() ->())) {
        api?.availableLanguages() { (languages, error) in
            guard let languages = languages else {
                print("Error get list language: \(error)")
                return
            }
            self.listLanguage.append(contentsOf: languages)
            completed()
        }
    }
}
