//
//  CutomImageView.swift
//  Instagram
//
//  Created by zaki kasem  on 2/4/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
class CustomImageView:UIImageView {
    var imageCashe = [String:UIImage]()
    var lastURLUsedToLoadImage:String?
    func loadImage(urlString:String) {
        
        if let cachedImage = imageCashe[urlString] {
            self.image = cachedImage
        }
        lastURLUsedToLoadImage = urlString
        self.image = nil
        guard let url = URL(string: urlString) else {return}
              URLSession.shared.dataTask(with: url) { (data, response, err) in
                  if let err = err {
                      print("Failed to fetch post image",err.localizedDescription)
                      return
                  }
                  if url.absoluteString != self.lastURLUsedToLoadImage {
                      return
                  }
                  guard let imageData = data else {return}
                  let photoImage = UIImage(data: imageData)
                self.imageCashe[url.absoluteString] = photoImage
                  DispatchQueue.main.async {
                      self.image = photoImage
                  }
                  }.resume()
    }
}
