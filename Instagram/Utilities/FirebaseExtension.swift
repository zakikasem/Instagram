//
//  Firebase Utils.swift
//  Instagram
//
//  Created by zaki kasem  on 2/7/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import Foundation
import Firebase
extension Database {
    static func fetchUserWithUID(uid:String,completion: @escaping (User) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDictionary = snapshot.value as? [String:Any] else {return}
            print(userDictionary)
            let user = User(uid:uid,dictionary: userDictionary)
            completion(user)
        }) { (err) in
            print("Failed to fetch user for posts ",err)
        }
    }
}
