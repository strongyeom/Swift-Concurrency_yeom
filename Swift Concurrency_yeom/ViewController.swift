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
        
        Network.shared.fetchThumbnailURLSession { response in
            switch response {
            case .success(let data):
                self.posterImageView.image = data
            case .failure(let failure):
                self.posterImageView.backgroundColor = .lightGray
                print(failure)
            }
        }
        
        
        
        
    }


}

