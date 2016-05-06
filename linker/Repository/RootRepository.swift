//
//  RootRepository.swift
//  linker
//
//  Created by happy_ryo on 2016/05/03.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import Firebase

class RootRepository: NSObject {
    let myRootRef: Firebase!
    init(childPath:String) {
        self.myRootRef = Firebase(url: "\(DeviceConst().firebaseRoot)/\(childPath)")
    }
}