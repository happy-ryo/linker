//
//  UserRepository.swift
//  linker
//
//  Created by happy_ryo on 2016/05/03.
//  Copyright © 2016年 Citron Syrup. All rights reserved.
//

import Foundation
import KeychainAccess
import Firebase
import CryptoSwift

class UserRepository: NSObject {
    var uid: String!
    var token: String!
    
    fileprivate let linkerUserIdKey = "LinkerUserId"
    fileprivate let linkerUserTokenKey = "LinkerUserToken"
    
    override init() {
        let keyChain = Keychain()
        let userId = keyChain[linkerUserIdKey]
        let token = keyChain[linkerUserTokenKey]
        if let userId = userId, let token = token {
            self.uid = userId
            self.token = token
        }
    }
    
    func registration(_ success:@escaping ()->Void, failer:@escaping (NSError)->Void) {
        let myRootRef = Firebase(url: DeviceConst().firebaseRoot)
        if let token = token {
            myRootRef.auth(withCustomToken: token, withCompletionBlock: {[unowned self] (error:NSError!, authData:FAuthData!) in
                if let _ = error {
                    self.registration(success ,failer: failer)
                } else {
                    self.saveToken(authData)
                    success()
                }
            })
        } else {
            myRootRef?.authAnonymously {[unowned self] (error:NSError!, authDAta:FAuthData!) in
                if let error = error {
                    failer(error)
                } else {
                    self.saveToken(authDAta)
                    success()
                }
            }
        }
    }
    
    func removeToken() {
        self.token = nil
        self.uid = nil
        let keyChain = Keychain()
        keyChain[linkerUserTokenKey] = nil
        keyChain[linkerUserIdKey] = nil
    }
    
    func saveToken(_ authData: FAuthData!) {
        self.token = authData.token
        self.uid = authData.uid
        let keyChain = Keychain()
        keyChain[linkerUserTokenKey] = self.token
        keyChain[linkerUserIdKey] = self.uid
    }
}
