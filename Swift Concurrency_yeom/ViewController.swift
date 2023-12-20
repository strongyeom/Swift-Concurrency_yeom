//
//  ViewController.swift
//  Swift Concurrency_yeom
//
//  Created by 염성필 on 2023/12/19.
//

import UIKit

/*
 @MainActor: Swift Concurrency를 작성한 코드에서 다시 메인쓰레드로 돌려주는 역할을 수행
 */

class ViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var secondImageView: UIImageView!
    
    @IBOutlet var thirdImageView: UIImageView!
 
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
        
        Task {
            // 현재 쓰레드 체크 할 수 있는 print문
            print(#function, "1", Thread.isMainThread)
            let result = try await Network.shared.fetchThumbnailAsynclet()
            print(#function, "2", Thread.isMainThread)
            posterImageView.image = result[0]
            secondImageView.image = result[1]
            thirdImageView.image = result[2]
            print(#function, "3", Thread.isMainThread)
            
        }
        
//
//        Task {
//            let result = try await Network.shared.fetchThumbnailTaskGroup()
//            posterImageView.image = result[0]
//            secondImageView.image = result[1]
//            thirdImageView.image = result[2]
//        }
//
        
        
    }


}

