//
//  UserSearchCell.swift
//  Instagram
//
//  Created by zaki kasem on 2/7/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
class UserSearchCell:UICollectionViewCell {
    var user:User? {
        didSet {
            usernameLabel.text = user?.username
            guard let profileImageURL = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageURL)
        }
    }
    let profileImageView :CustomImageView = {
       let iv = CustomImageView()
        iv.backgroundColor = .white 
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let usernameLabel :UILabel = {
       let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = .white
        addSubview(profileImageView)
        addSubview(usernameLabel)
        profileImageView.setAnchor(top: nil, left: leftAnchor, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 0, height: 50, width: 50)
        usernameLabel.setAnchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 0, height: 0, width: 0)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 50 / 2
        let separatorView = UIView ()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(separatorView)
        separatorView.setAnchor(top: nil, left: usernameLabel.leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 0.5, width: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
