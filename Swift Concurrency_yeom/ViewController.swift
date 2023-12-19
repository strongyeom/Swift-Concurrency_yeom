//
//  ViewController.swift
//  Swift Concurrency_yeom
//
//  Created by 염성필 on 2023/12/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var secondImageView: UIImageView!
    
    @IBOutlet var thirdImageView: UIImageView!
    
    /*
     
     범죄도시
     A5MIbqxuQfQRtzGxg5UUTAxHfsM
     
     아쿠아맨
     eDps1ZhI8IOlbEC7nFg6eTk4jnb
     
     반지의 제왕
     mYLOqiStMxDK3fYZFirgrMt8z5d
     */
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        Network.shared.fetchThumbnail { image in
//            self.posterImageView.image = image
//        }
        
//        Network.shared.fetchThumbnailURLSession { response in
//            switch response {
//            case .success(let data):
//                self.posterImageView.image = data
//            case .failure(let failure):
//                self.posterImageView.backgroundColor = .lightGray
//                print(failure)
//            }
//        }
        
        // 비동기 동작하는데 동기 함수안에 쓰고 있냐? -> 비동기 함수에서 동작하게 만들어줘야지
//        Network.shared.fetchThumbnailAsyncAwait()
//        Task { // == DispatchQueue.global().async과 비슷함
//
//
//            posterImageView.image = image
//            secondImageView.image = image2
//            thirdImageView.image = image3
//
//        }
        
//        Task {
//            let result = try await Network.shared.fetchThumbnailAsynclet()
//
//            posterImageView.image = result[0]
//            secondImageView.image = result[1]
//            thirdImageView.image = result[2]
//        }
        
        
        Task {
            let result = try await Network.shared.fetchThumbnailTaskGroup()
            posterImageView.image = result[0]
            secondImageView.image = result[1]
            thirdImageView.image = result[2]
        }
        
        
        
    }


}

