//
//  UserProfileHeader.swift
//  Instagram
//
//  Created by zaki kasem  on 1/13/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
import Firebase
protocol UserProfileHeaderDelegate : class {
    func didChangeToListView()
    func didChangeToGridView()
    func didTappedEditProfile(userProfileURL:String)
}
class UserProfileHeader:UICollectionViewCell {
    var noOfPosts:Int?
    var noOfFollowing:Int?
    var noOfFollowers:Int?
    let uid = Auth.auth().currentUser?.uid
    weak var delegate : UserProfileHeaderDelegate?
    var user:User? {
        didSet {
            guard let profileImageURL = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageURL)
            usernameLabel.text = user?.username
            setupEditFollowButton()
        }
    }
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()
    lazy var gridButton :UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    lazy var listButton :UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    @objc func handleChangeToGridView () {
        print("Handle Change To Grid view")
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    @objc func handleChangeToListView() {
        print("Handle Change To List View")
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    let bookMarkButton :UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    let usernameLabel : UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    lazy var postsLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
  
    let followersLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let followingLabel :UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        addSubview(profileImageView)
        profileImageView.setAnchor(top: self.topAnchor, left: self.leftAnchor, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, paddingTop: 12, height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        setupBottomToolBar()
        
        addSubview(usernameLabel)
        usernameLabel.setAnchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: gridButton.topAnchor, paddingBottom: 0, paddingLeft: 12, paddingRight: 12, paddingTop: 4, height: 0, width: 0)
        
        setupUsereStatsView()
        addSubview(editProfileFollowButton)
        editProfileFollowButton.setAnchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, right: followingLabel.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 2, height: 34, width: 0)
        setupFollowersCount()
        
    }
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        if currentLoggedInUserId == userId {
            
        } else {
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { [weak self](snapshot) in
                if let isFollowing = snapshot.value as? Int , isFollowing == 1 {
                    self?.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                }
                else {
                    self?.setupFollowStyle()
                }
            }) { (err) in
                print("Failed to check if follow",err)
            }
        }
    }
    func  setupPostsCount() {
          let font = UIFont.boldSystemFont(ofSize: 14)
        guard let userId = user?.uid else {return}
          Database.database().reference().child("posts").child( userId ).observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.children.allObjects
          self.noOfPosts = dictionary.count
          let attributedText = NSMutableAttributedString(string:"\(self.noOfPosts ?? 0)\n",attributes:[NSAttributedString.Key.font:font])
              attributedText .append(NSAttributedString(string:"posts",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font:font]))
              
              self.postsLabel.attributedText = attributedText
      })
      }
    func setupFollowingCount() {
        let font = UIFont.boldSystemFont(ofSize: 14)
        guard let userId = user?.uid else {return}
        Database.database().reference().child("following").child(userId ).observeSingleEvent(of: .value, with: { (snapshot) in
        let dictionary = snapshot.children.allObjects
        self.noOfFollowing = dictionary.count
        
            let attributedText = NSMutableAttributedString(string: "\(self.noOfFollowing ?? 0)\n",attributes:[NSAttributedString.Key.font:font])
        attributedText .append(NSAttributedString(string:"following",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font:font]))
            self.followingLabel.attributedText = attributedText
    })
    }
    func setupFollowersCount() {
        let font = UIFont.boldSystemFont(ofSize: 14)
        guard let userId = user?.uid else {return}
        Database.database().reference().child("followers").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.children.allObjects
            self.noOfFollowers = dictionary.count
            let attributedText = NSMutableAttributedString(string: "\(self.noOfFollowers ?? 100)\n",attributes:[NSAttributedString.Key.font:font])
                   attributedText .append(NSAttributedString(string:"followers",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font:font]))
            self.followersLabel.attributedText = attributedText
        }) { (err) in
            print("Failed to fetch followers")
        }
    }
    @objc func handleEditProfileOrFollow () {
        print("Execute edit profile or follow ")
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue { [weak self] (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:",err)
                    return
                }
                print("Successfully unfollwed user:",self?.user?.username ?? "" )
                self?.setupFollowStyle()
                
            }
            Database.database().reference().child("followers").child(userId).child(currentLoggedInUserId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to delete a follower",err)
                    return
                }
                print("Successfully deleted a follower")
                self.setupFollowersCount()
            }
            
        }else if editProfileFollowButton.titleLabel?.text == "Follow" {
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            let values = [userId:1]
            ref.updateChildValues(values) { [weak self] (err, ref) in
                if let err = err {
                    print("Failed to follow user",err)
                    return
                }
                print("Successfully followed user",self?.user?.username ?? "")
                self?.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self?.editProfileFollowButton.backgroundColor = .white
                self?.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
            let followerValue = [currentLoggedInUserId:1]
            Database.database().reference().child("followers").child(userId).updateChildValues(followerValue) { (err, ref) in
                if let err = err {
                    print("Failed to save follower",err)
                    return
                }
                print("Successfully saved a follower to the userId",userId)
                self.setupFollowersCount()
            }
        }
        else {
            editProfileFollowButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        }
    }
    @objc func handleEditProfile() {
        print("This is edit profile button")
        guard let userImageURL = user?.profileImageUrl else {return}
        delegate?.didTappedEditProfile(userProfileURL: userImageURL)
    }
    fileprivate func setupFollowStyle() {
        editProfileFollowButton.setTitle("Follow", for: .normal)
        editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        editProfileFollowButton.setTitleColor(.white, for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    fileprivate func setupUsereStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addSubview(stackView)
        stackView.setAnchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 12, paddingRight: 12, paddingTop: 12, height: 50, width: 0)
    }
    fileprivate func setupBottomToolBar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView.init(arrangedSubviews: [gridButton,listButton,bookMarkButton])
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        stackView.setAnchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 50, width: 0)
        topDividerView.setAnchor(top: stackView.topAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 0.5, width: 0)
        bottomDividerView.setAnchor(top: stackView.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 0.5, width: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

