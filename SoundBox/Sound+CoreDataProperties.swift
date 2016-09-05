//
//  Sound+CoreDataProperties.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Sound {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var desc: String?
    @NSManaged var shake: NSNumber?
    @NSManaged var file: String?

}
