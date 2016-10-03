//
//  RemoteSound.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import Foundation
import SwiftyJSON

class RemoteSound{
    var id:Int
    var name:String?
    var description:String?
    var url:String?
    var createdAt:Date
    var updatedAt:Date

    init?(data : JSON?) {
        if let data = data {
            if let id = data["id"].int {
                let dateFormatter = DateFormatter()
                self.id = id
                self.name = data["name"].string
                self.url = data["url"].string
                self.description = data["description"].string
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                self.createdAt = dateFormatter.date(from: data["createdAt"].string!)!
                self.updatedAt = dateFormatter.date(from: data["updatedAt"].string!)!
                return
            }
        }
        return nil
    }

}
