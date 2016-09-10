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
            fatalError("Failed to fetch sounds: \(error)")
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
            fatalError("Failed to fetch sounds: \(error)")
        }
    }
    
    
    
    func saveRemoteSound(remoteSound:RemoteSound, file: String) -> Bool{
        let soundsFetch = NSFetchRequest(entityName: "Sound")
        let predicate = NSPredicate(format: "id == %d", remoteSound.id)
        soundsFetch.predicate = predicate
        do {
            let sounds = try managedObjectContext.executeFetchRequest(soundsFetch) as! [Sound]
            if sounds.count > 0 {
                return false
            }
        } catch {
            fatalError("Failed to fetch sounds: \(error)")
        }
        
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
        return true
    }
    
    func deleteSound(sound: Sound) {
        if let file = sound.file {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileUrl = directoryURL.URLByAppendingPathComponent(file)
            let exist = fileManager.fileExistsAtPath(fileUrl.absoluteString)
            print("\(fileUrl) ====== \(exist)")
            if exist {
                try! fileManager.removeItemAtURL(fileUrl)
            }
        }
        
        managedObjectContext.deleteObject(sound)
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}