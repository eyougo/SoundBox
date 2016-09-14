//
//  RemoteDataController.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//


import Foundation
import Alamofire
import SwiftyJSON

class RemoteDataController {
    
    let manager: Manager
    
    let ApiRoot = "http://soundbox.eyougo.com/"
    
    init(){
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 10 // seconds
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    func fetchSounds(offset:Int, limit:Int, finished: (success:Bool, message:String?, [RemoteSound], nextStart: Int) -> Void) {
        
        var remoteSounds = [RemoteSound]()
        
        let headers = [
            "Accept": "application/json"
        ]
        
        manager.request(.GET, ApiRoot + "/sounds?offset=\(offset)&limit=\(limit)", headers: headers, encoding: .JSON)
            .responseJSON{ response in
                if let error = response.result.error {
                    print(error.localizedDescription)
                    finished(success: false, message: "服务器错误，请稍候重试", remoteSounds, nextStart:-1)
                    
                    return
                }
                guard let data = response.result.value else {
                    finished(success: false, message: "服务器未知错误，请稍候重试", remoteSounds, nextStart:-1)
                    return
                }
                
                let json = JSON(data)
                
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 200:
                        let nextStart = json["nextStart"].intValue
                        if let soundArray = json["list"].array {
                            for soundData in soundArray {
                                if let sound = RemoteSound(data: soundData) {
                                    remoteSounds.append(sound)
                                }
                            }
                        }
                        finished(success: true, message: "", remoteSounds, nextStart:nextStart)
                    default:
                        let message = json["message"].string!
                        finished(success: false, message: message, remoteSounds, nextStart:-1)
                    }
                }
        }
    }
    
    func downloadSound(remoteSound: RemoteSound, finished: (success:Bool, message:String?, RemoteSound, file: String?) -> Void){
        
        if let url = remoteSound.url {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            var pathComponent = String(remoteSound.id)
            
            let components = url.componentsSeparatedByString(".")
            if components.count > 1 {
                let suffix = components[components.count-1]
                pathComponent = String(remoteSound.id) + "." + suffix
            }
            
            let desination = directoryURL.URLByAppendingPathComponent(pathComponent)
            
            manager.download(.GET, url) { temporaryURL, response in
                    return desination
                }.response { _, _, _, error in
                    if let error = error {
                        finished(success: false, message: error.localizedDescription, remoteSound, file: pathComponent)
                    } else {
                        finished(success: true, message: nil, remoteSound, file: pathComponent)
                    }
                }
        }
        
        
        
    
    }
}
