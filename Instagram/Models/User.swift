

//
//  user.swift
//  Instagram
//
//  Created by zaki kasem  on 2/6/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import Foundation
struct User {
    let uid:String
    let username:String
    let profileImageUrl:String
    init(uid:String,dictionary:[String:Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageURL"] as? String ?? ""
        self.uid = uid
        
    }
}
