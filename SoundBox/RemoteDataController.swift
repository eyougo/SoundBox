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
    
    let manager: SessionManager
    
    let ApiRoot = "http://soundbox.eyougo.com/"
    
    init(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 10 // seconds
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func fetchSounds(_ offset:Int, limit:Int, finished: @escaping (_ success:Bool, _ message:String?, [RemoteSound], _ nextStart: Int) -> Void) {
        
        var remoteSounds = [RemoteSound]()
        
        let headers = [
            "Accept": "application/json"
        ]
        
        manager.request(ApiRoot + "/sounds?offset=\(offset)&limit=\(limit)", headers: headers)
            .responseJSON{ response in
                if let error = response.result.error {
                    print(error.localizedDescription)
                    finished(false, "服务器错误，请稍候重试", remoteSounds, -1)
                    
                    return
                }
                guard let data = response.result.value else {
                    finished(false, "服务器未知错误，请稍候重试", remoteSounds, -1)
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
                        finished(true, "", remoteSounds, nextStart)
                    default:
                        let message = json["message"].string!
                        finished(false, message, remoteSounds, -1)
                    }
                }
        }
    }
    
    func downloadSound(_ remoteSound: RemoteSound, finished: @escaping (_ success:Bool, _ message:String?, RemoteSound, _ file: String?) -> Void){
        
        if let url = remoteSound.url {
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var pathComponent = String(remoteSound.id)
            
            let components = url.components(separatedBy: ".")
            if components.count > 1 {
                let suffix = components[components.count-1]
                pathComponent = String(remoteSound.id) + "." + suffix
            }
            
            let desination = directoryURL.appendingPathComponent(pathComponent)
            
            manager.download(url) { _, _ in
                return (desination, [.removePreviousFile, .createIntermediateDirectories])
                }.response{ response in
                    if let error = response.error {
                        debugPrint(response)
                        finished(false, error.localizedDescription, remoteSound, pathComponent)
                    } else {
                        finished(true, nil, remoteSound, pathComponent)
                    }
                }
        }
        
        
        
    
    }
}
