//
//  UserSearchController.swift
//  Instagram
//
//  Created by zaki kasem on 2/7/20.
//  Copyright © 2020 zaki kasem. All rights reserved.
//

import UIKit
import Firebase
class UserSearchController:UICollectionViewController, UICollectionViewDelegateFlowLayout,UISearchBarDelegate{
    var users = [User]()
    var filteredUsers = [User]()
    let cellID = "cellID"
    lazy var searchBar:UISearchBar = {
       let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230,blue: 230)
        sb.delegate = self
        return sb
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        let navBar = navigationController?.navigationBar
        navigationController?.navigationBar.addSubview(searchBar)
        searchBar.setAnchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, right: navBar?.rightAnchor, bottom: navBar?.bottomAnchor, paddingBottom: 0, paddingLeft: 8, paddingRight: 8, paddingTop: 0, height: 0, width: 0 )
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        fetchUsers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            dictionaries.forEach { (key,value) in
                    guard let userDictionary = value as? [String:Any] else {return}
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself,omit from list ")
                    return
                }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            }
            self.users.sort { (userOne, userTwo) -> Bool in
                return userOne.username.compare(userTwo.username) == .orderedAscending
            }
            self.filteredUsers = self.users
            self.collectionView.reloadData()
        }) { (err) in
            print("Failed to fetch users for search",err)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserSearchCell
        cell.user = self.filteredUsers[indexPath.row]
        return cell
        
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        let user = filteredUsers[indexPath.row]
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userID = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        }
        else {
            self.filteredUsers = self.users.filter({ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
        })
        }
        self.collectionView.reloadData()
    }
    
}
