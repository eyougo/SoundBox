//
//  LocalDataController.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import CoreData

class LocalDataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("LocalData", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         */
        let storeURL = docURL.URLByAppendingPathComponent("LocalData.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func fetchLocalSoundCount() -> Int{
        let soundsFetch = NSFetchRequest(entityName: "Sound")
        soundsFetch.resultType = .CountResultType
        do {
            let counts = try managedObjectContext.executeFetchRequest(soundsFetch) as! [NSNumber]
            return counts[0].integerValue
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    func fetchLocalSounds(offset:Int, limit:Int) -> [Sound]{
        let soundsFetch = NSFetchRequest(entityName: "Sound")
        soundsFetch.fetchOffset = offset
        soundsFetch.fetchLimit = limit
        do {
            let sounds = try managedObjectContext.executeFetchRequest(soundsFetch) as! [Sound]
            return sounds
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    
    
    func saveRemoteSound(remoteSound:RemoteSound, file: String) {
        let sound = NSEntityDescription.insertNewObjectForEntityForName("Sound", inManagedObjectContext: self.managedObjectContext) as! Sound

        sound.id = remoteSound.id
        sound.name = remoteSound.name
        sound.desc = remoteSound.description
        sound.file = file
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func deleteSound(sound: Sound) {
        managedObjectContext.deleteObject(sound)
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}