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
		guard let modelURL = Bundle.main.url(forResource: "LocalData", withExtension: "momd") else {
			fatalError("Error loading model from bundle")
		}
		// The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
		guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
			fatalError("Error initializing mom from: \(modelURL)")
		}
		
		let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
		managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = psc
		
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let docURL = urls[urls.endIndex - 1]
		/* The directory the application uses to store the Core Data store file.
		 */
		let storeURL = docURL.appendingPathComponent("LocalData.sqlite")
		do {
			try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
		} catch {
			fatalError("Error migrating store: \(error)")
		}
	}
	
	func fetchLocalSoundCount() -> Int {
		let soundsFetch: NSFetchRequest<Sound> = Sound.fetchRequest()
		soundsFetch.resultType = .countResultType
		do {
			let count = try managedObjectContext.count(for: soundsFetch)
            return count
		} catch {
			fatalError("Failed to fetch sounds: \(error)")
		}
	}
	
	func fetchLocalSounds(_ offset: Int, limit: Int) -> [Sound] {
		let soundsFetch: NSFetchRequest<Sound> = Sound.fetchRequest()
        soundsFetch.fetchOffset = offset
		soundsFetch.fetchLimit = limit
		do {
			let sounds = try managedObjectContext.fetch(soundsFetch)
			return sounds
		} catch {
			fatalError("Failed to fetch sounds: \(error)")
		}
	}
	
	func saveRemoteSound(_ remoteSound: RemoteSound, file: String) -> Bool {
		let soundsFetch: NSFetchRequest<Sound> = Sound.fetchRequest()
		let predicate = NSPredicate(format: "id == %d", remoteSound.id)
		soundsFetch.predicate = predicate
		do {
			let sounds = try managedObjectContext.fetch(soundsFetch)
            if sounds.count > 0 {
				return false
			}
		} catch {
			fatalError("Failed to fetch sounds: \(error)")
		}
		
		let sound = NSEntityDescription.insertNewObject(forEntityName: "Sound", into: self.managedObjectContext) as! Sound
		
		sound.id = remoteSound.id as NSNumber?
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
	
	func deleteSound(_ sound: Sound) {
		if let file = sound.file {
			let fileManager = FileManager.default
			let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let fileUrl = directoryURL.appendingPathComponent(file)
			let exist = fileManager.fileExists(atPath: fileUrl.absoluteString)
			print("\(fileUrl) ====== \(exist)")
			if exist {
				try! fileManager.removeItem(at: fileUrl)
			}
		}
		
		managedObjectContext.delete(sound)
		do {
			try managedObjectContext.save()
		} catch {
			fatalError("Failure to save context: \(error)")
		}
	}
}
