//
//  HomeViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/09/04.
//

import UIKit

class HomeViewController: UIViewController {
    
   
    @IBOutlet weak var collectionView: UICollectionView!

    var posts = [Post]()
    var users = [User]()
    @objc dynamic var currentIndex = 0
    var oldAndNewIndices = (0,0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.automaticallyAdjustsScrollIndicatorInsets = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        loadPosts()
     
    }
    // Tabbarを消す処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let cell = collectionView.visibleCells.first as? HomeCollectionViewCell {
            cell.play()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let cell = collectionView.visibleCells.first as? HomeCollectionViewCell {
            cell.pause()
        }
    }
    func loadPosts() {
        Api.Post.observeFeedPosts{ post in
            guard let postId = post.uid else {return}
            self.fetchUser(uid: postId){
                self.posts.append(post)
                self.posts.sort { post1, post2 -> Bool in
                    return post1.creationDate! > post2.creationDate!
                }
                self.collectionView.reloadData()
            }
        }
        
    }
    
    
    func fetchUser(uid: String, completed: @escaping () -> Void){
        Api.User.observeUser(withId: uid){ user in
            self.users.append(user)
            completed()
        }
    }
    
    
    
    
    
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath)
        as! HomeCollectionViewCell
        let post = posts[indexPath.item]
        let user = users[indexPath.item]
        cell.post = post
        cell.user = user
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,willDisplay cell: UICollectionViewCell ,forItemAt indexPath: IndexPath){
        if let cell = cell as? HomeCollectionViewCell {
            oldAndNewIndices.1 = indexPath.item
            currentIndex = indexPath.item
            cell.pause()
        }
    }
    func collectionView(_ collectionView: UICollectionView,didEndDisplaying cell: UICollectionViewCell ,forItemAt indexPath: IndexPath){
        if let cell = cell as? HomeCollectionViewCell {
            cell.stop()
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        let cell = self.collectionView.cellForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? HomeCollectionViewCell
        cell?.replay()
        
    }
}
