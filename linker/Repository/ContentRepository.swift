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
    let imagePath: String

    init(userId: String, text: String, date: String, imagePath: String) {
        self.userId = userId
        self.text = text
        self.date = date
        self.imagePath = imagePath
    }

    init(userRepository: UserRepository, text: String) {
        self.userId = userRepository.uid
        self.text = text.replacingOccurrences(of: "\n", with: "")

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        self.date = dateString
        self.imagePath = ""
    }

    init(userRepository: UserRepository, text: String, imagePath: String) {
        self.userId = userRepository.uid
        self.text = text.replacingOccurrences(of: "\n", with: "")

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        self.date = dateString
        self.imagePath = imagePath
    }

    func isExistImage() -> Bool {
        return imagePath != ""
    }
}
