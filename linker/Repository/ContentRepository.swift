//
//  ContentRepository.swift
//  linker
//
//  Created by happy_ryo on 2016/05/03.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation

struct ContentRepository {
    let userId: String
    let text: String
    let date: String
    
    init(userId:String,text:String,date:String){
        self.userId = userId
        self.text = text
        self.date = date
    }
    
    init(userRepository:UserRepository ,text:String){
        self.userId = userRepository.uid
        self.text = text.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(date)
        self.date = dateString
    }
}