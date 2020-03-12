//
//  HomePostCell.swift
//  Instagram
//
//  Created by zaki kasem  on 2/4/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
protocol HomePostCellDelegate : class {
    func didTapComment(post:Post)
    func didLike(for cell: HomePostCell)
}
class HomePostCell:UICollectionViewCell {
   weak var delegate : HomePostCellDelegate?
    var post :Post? {
        didSet {
            guard let postImageURL = post?.imageURL else {return}
            likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
            photoImageView.loadImage(urlString: postImageURL)
            userNameLabel.text = post?.user.username
            guard let profileImageURL = post?.user.profileImageUrl else {return}
            userProfileImageView.loadImage(urlString: profileImageURL)
            setupAttributedCaption()
        }
    }
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else {return}
        
        let attributedText = NSMutableAttributedString(string:"\( post.user.username) ", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14)])
        guard let postCaption = post.caption else {return}
        attributedText.append(NSAttributedString(string:"\(postCaption)", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 4)]))
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay , attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        captionLabel.attributedText = attributedText
        
    }
    let userProfileImageView:CustomImageView = {
       let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        iv.contentMode = .scaleToFill
        return iv
    }()
    let photoImageView : CustomImageView = {
       let iv = CustomImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let userNameLabel:UILabel = {
       let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let optionsButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
        
    }()
    lazy var likeButton : UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    @objc func handleLike () {
        print("Handling likes")
        delegate?.didLike(for: self)
    }
    lazy var commentButton : UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    @objc func handleComment() {
        print("trying to show comments")
        guard let post = self.post else {return}
        delegate?.didTapComment(post:post)
    }
    let sendMessageButton : UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    let bookmarkButton : UIButton = {
        let button = UIButton(type:.system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    let captionLabel:UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,sendMessageButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addSubview(stackView)
        stackView.setAnchor(top: photoImageView.bottomAnchor, left: leftAnchor, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 0, height: 50, width: 120)
    }
    override init(frame:CGRect) {
        super.init(frame:frame)
        addSubview(photoImageView)
        addSubview(userProfileImageView)
        addSubview(userNameLabel)
        addSubview(optionsButton)
        addSubview(bookmarkButton)
        addSubview(captionLabel)
        userProfileImageView.setAnchor(top: topAnchor, left: leftAnchor, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 8, height: 40, width: 40)
        photoImageView.setAnchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil , paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 8, height: 0, width: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        userNameLabel.setAnchor(top: topAnchor, left: userProfileImageView.rightAnchor, right: optionsButton.leftAnchor, bottom: photoImageView.topAnchor, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 0, height: 0, width: 0)
        optionsButton.setAnchor(top: topAnchor, left: nil, right: rightAnchor, bottom: photoImageView.topAnchor, paddingBottom: 0, paddingLeft: 0, paddingRight: 8, paddingTop: 0, height: 0, width: 44)
        bookmarkButton.setAnchor(top: photoImageView.bottomAnchor, left: nil, right: rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 50, width: 40 )
        captionLabel.setAnchor(top: bookmarkButton.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 8, paddingRight: 8 , paddingTop: 0, height: 0, width: 0)
        userProfileImageView.layer.cornerRadius = 40 / 2
        setupActionButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
