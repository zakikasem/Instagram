//
//  MainTabBarController.swift
//  Instagram
//
//  Created by zaki kasem  on 1/13/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViewControllers()
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
        func setupViewControllers() {
            //home
            let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
            // search
            let searchNavController = templateNavController(unselectedImage:#imageLiteral(resourceName: "search_unselected")  , selectedImage: #imageLiteral(resourceName: "search_selected"),rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
            let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
            
            //userProfile
            let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
            tabBar.tintColor = .black
            viewControllers = [homeNavController, searchNavController,plusNavController,userProfileNavController]
            guard let items = tabBar.items else { return }
            for item in items {
                item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4 , right: 0)
            }

            if Auth.auth().currentUser == nil {
                print("No User")
                DispatchQueue.main.async {
                    
                let loginController = LoginController()
                loginController.modalPresentationStyle = .fullScreen
                let navController = UINavigationController(rootViewController: loginController)
                    navController.modalPresentationStyle = .fullScreen
                    self.present(navController, animated: true, completion: nil)
            }
            }
        }
        fileprivate func templateNavController(unselectedImage:UIImage,selectedImage:UIImage , rootViewController : UIViewController = UIViewController() ) -> UINavigationController {
            
            let viewController = rootViewController
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.pushViewController(viewController, animated: true)
            let navController = UINavigationController(rootViewController: viewController)
            navController.tabBarItem.image = unselectedImage
            navController.tabBarItem.selectedImage = selectedImage
            return navController
        }
}

