//
//  CommentCell.swift
//  Instagram
//
//  Created by zaki kasem  on 2/11/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
class CommentCell:UICollectionViewCell {
    var comment:Comment? {
        didSet {
            guard let comment = comment else {return}
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSMutableAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSMutableAttributedString(string:"   \(comment.text)", attributes: [NSMutableAttributedString.Key.font:UIFont.systemFont(ofSize: 14)]))
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString:comment.user.profileImageUrl )
        }
    }
    let textView:UITextView = {
    let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.backgroundColor = .white
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    let profileImageView :CustomImageView = {
       let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .blue
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = .white
        addSubview(textView)
        addSubview(profileImageView)
        textView.setAnchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 4, paddingLeft: 4, paddingRight: 4, paddingTop: 4, height: 0, width: 0)
        profileImageView.setAnchor(top: topAnchor, left: leftAnchor, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 8, height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
