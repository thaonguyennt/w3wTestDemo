//
//  Word+CoreDataProperties.swift
//  w3wDemo
//
//  Created by Thảo Nguyên on 18/08/2024.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var words: String?
    @NSManaged public var createAt: Date?

}

extension Word : Identifiable {

}
