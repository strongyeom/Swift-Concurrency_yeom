//
//  ViewController.swift
//  Swift Concurrency_yeom
//
//  Created by 염성필 on 2023/12/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    
    
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
        Task { // == DispatchQueue.global().async과 비슷함
            let image = try await Network.shared.fetchThumbnailAsyncAwait() // 비동기 함수가 다 실행될때까지 기다려
            
        }
        
        
        
    }


}

