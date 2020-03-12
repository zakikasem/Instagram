//
//  UserProfilePhotoCell.swift
//  Instagram
//
//  Created by zaki kasem  on 2/4/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
class UserProfilePhotoCell: UICollectionViewCell {
    var post : Post? {
        didSet{
            guard let imageURL = post?.imageURL else {return}
            photoImageView.loadImage(urlString:imageURL)
      
        }
    }
    let photoImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    override init (frame:CGRect) {
        super.init(frame:frame)
        addSubview(photoImageView)
        photoImageView.setAnchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 0, width: 0)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
