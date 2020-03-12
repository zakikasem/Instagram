//
//  CommentInputAccessoryView.swift
//  Instagram
//
//  Created by zaki kasem  on 2/15/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
protocol CommentInputAccessoryViewDelegate: class {
    func didSubmit(for comment:String)
}
class CommentInputAccessoryView : UIView {
    weak var delegate:CommentInputAccessoryViewDelegate?
    fileprivate let commentTextField :UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment"
        return tf
    }()
    fileprivate let submitButton: UIButton = {
        let sb = UIButton(type: .system)
        sb.setTitle("Submit", for: .normal)
        sb.setTitleColor(.black, for: .normal)
        sb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sb.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return sb 
        }()
    func clearCommentTextField() {
        commentTextField.text = nil
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        addSubview(submitButton)
        addSubview(commentTextField)
        submitButton.setAnchor(top: topAnchor, left: nil, right: rightAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 0, paddingRight: 12, paddingTop: 0, height: 0, width: 50)
        commentTextField.setAnchor(top: topAnchor, left: leftAnchor, right: submitButton.leftAnchor, bottom: bottomAnchor, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 0, height: 0, width: 0)
        setupLineSeparatorView() 
    }
    fileprivate func setupLineSeparatorView () {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.setAnchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 0.5, width: 0)

    }
    @objc func handleSubmit () {
        print("123")
        guard let commentText = commentTextField.text else {return}
        delegate?.didSubmit(for: commentText)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
