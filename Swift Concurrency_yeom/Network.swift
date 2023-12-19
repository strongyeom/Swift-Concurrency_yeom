//
//  Network.swift
//  Swift Concurrency_yeom
//
//  Created by 염성필 on 2023/12/19.
//
import UIKit

// 무한정 늘어나는 쓰레드가 발생할 수 있기 때문에 그러한 문제를 해결 하기 위해 Concurrency 등장

class Network {
    static let shared = Network()
    
    private init() { }
    
    func fetchThumbnail(completionHandler: @escaping (UIImage) -> Void) {
        let url = "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/A5MIbqxuQfQRtzGxg5UUTAxHfsM.jpg"
        
        // 1. GCD를 활용하여 네트워크 통신하기
        // 단점 : 모든 것이 성공일 경우에만 completionHandler 실행 가능
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: url)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completionHandler(image)
                    }
                }
            }
        }
    }
    
}
