//
//  HomeController.swift
//  Instagram
//
//  Created by zaki kasem  on 2/4/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
import Firebase

class HomeController:UICollectionViewController,UICollectionViewDelegateFlowLayout,HomePostCellDelegate {
    
    var posts = [Post]()
    let cellID = "cellID"
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUsernameUpdate), name: EditProfileController.updateUserData, object: nil)
        
        collectionView.backgroundColor = .white
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellID)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        setupNavigationItems()
        fetchAllPosts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
    }
    func didTapComment(post:Post) {
        print("Message coming from homeController")
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
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
    @objc func handleUpdateFeed () {
        handleRefresh()
    }
    @objc func handleUsernameUpdate() {
        handleRefresh()
    }
    @objc func handleRefresh() {
        print("Handling refresh...")
        posts.removeAll()
        fetchAllPosts()
        collectionView.reloadData()
    }
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserIds()
    }
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String:Any] else {return}
            userIdsDictionary.forEach { (key,value) in
                Database.fetchUserWithUID(uid: key) { [weak self] (user) in
                    self?.fetchPostsWithUser(user: user)
                }
            }
            
        }) { (err) in
            print("Failed to fetch following users",err)
        }
    }
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
     func fetchPostsWithUser(user:User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            dictionaries.forEach { (key,value) in
                guard let dictionary = value as? [String:Any] else {return}
                var post = Post(user:user,dictionary: dictionary)
                post.id = key
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                    if let value = snapshot.value as? Int , value == 1 {
                        post.hasLiked = true
                    }else {
                        post.hasLiked = false
                    }
                    self?.posts.append(post)
                    self?.posts.sort { (postOne, postTwo) -> Bool in
                        return postOne.creationDate.compare(postTwo.creationDate) == .orderedDescending
                    }
                    self?.collectionView.reloadData()
                    
                }) { (err) in
                    print("Failed to fetch like for post",err)
                }
            }
            
        }) { (err) in
            print("Failed to fetch posts",err.localizedDescription)
        }
    }
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
    }
    @objc func handleCamera() {
        print("Showing Camera")
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 90 + 8 + 8
        height += 60
        height += view.frame.width
        return CGSize(width: view.frame.width, height: height)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
}
