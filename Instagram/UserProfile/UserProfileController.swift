//
//  UserProfileController.swift
//  Instagram
//
//  Created by zaki kasem  on 1/13/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
import Firebase
class UserProfileController:UICollectionViewController,UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate,HomePostCellDelegate{
    
    
    
    var posts = [Post]()
    var user:User?
    let cellID = "collectionViewCell"
    let homePostCellID = "homePostCellId"
    var userID:String?
    var isGridView = true
    var isFinishedPaging = false
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
               refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
               collectionView.refreshControl = refreshControl
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellID)
        setupLogOutButton()
        fetchUser()
    }
    @objc func handleRefresh() {
     fetchUserUsername()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
        tabBarController?.tabBar.isHidden = false
    }
   
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    func didTappedEditProfile(userProfileURL: String) {
        let editProfileController = EditProfileController()
        editProfileController.profileImageString = userProfileURL
        navigationController?.pushViewController(editProfileController, animated: true)
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            guard let user = self.user else {return}
            var post = Post(user:user,dictionary: dictionary)
            post.id = snapshot.key
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }) { (err) in
            print("Failed to Fetch Ordered Posts",err.localizedDescription)
        }
    }
                fileprivate func setupLogOutButton () {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    @objc func handleLogOut () {
        let Alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            do {
                try Auth.auth().signOut()
                let loginViewController = LoginController()
                self.navigationController?.pushViewController(loginViewController, animated: true)
                
            } catch let signOutError {
                print("Failed to sign out",signOutError)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        Alert.addAction(logOutAction)
        Alert.addAction(cancelAction)
        present(Alert,animated: true,completion: nil)
    }
    func didLike(for cell: HomePostCell) {
        print("Handling like inside the controller")
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
         var post = self.posts[indexPath.row]
        guard let postId = post.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = [uid:post.hasLiked == true ? 0 : 1 ]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) {  (err, _ ref) in
            if let err = err {
                print("Failed to like post",err)
                return
            }
            print("Successfully liked post")
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.row] = post
            self.collectionView?.reloadData()
        }
    }
    func didTapComment(post:Post) {
           print("Message coming from homeController")
           let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
           commentsController.post = post
           navigationController?.pushViewController(commentsController, animated: true)
          }
    func setupUserProfileStatus(header:UserProfileHeader) {
        header.setupPostsCount()
        header.setupFollowersCount()
        header.setupFollowingCount()
    }
    @objc func updateUserData() {
        fetchUserUsername()
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 3) / 3
            return CGSize(width: width, height: width)
        }else {
            var height:CGFloat = 90 + 8 + 8
            height += 60
            height += view.frame.width
            return CGSize(width: view.frame.width, height: height)
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            NotificationCenter.default.addObserver(self, selector: #selector(updateUserData), name: EditProfileController.updateUserData, object: nil)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.row]
            return cell
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(updateUserData), name: EditProfileController.updateUserData, object: nil)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellID, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.backgroundColor = .white
        header.user = self.user
        setupUserProfileStatus(header: header)
        header.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200 )
    }
    
    fileprivate func fetchUser () {
        let uid = userID ?? Auth.auth().currentUser?.uid ?? ""
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView.reloadData()
            self.fetchOrderedPosts()
            
        }
    }
    fileprivate func fetchUserUsername() {
        let uid = userID ?? Auth.auth().currentUser?.uid ?? ""
                    Database.fetchUserWithUID(uid: uid) { (user) in
                        self.user = user
                        self.navigationItem.title = self.user?.username
                        self.collectionView.reloadData()
                     self.refreshControl.endRefreshing()
         }
    }
}

