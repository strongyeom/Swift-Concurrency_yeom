//
//  Network.swift
//  Swift Concurrency_yeom
//
//  Created by 염성필 on 2023/12/19.
//
import UIKit

enum NetworkError: Error {
    case invalidResponse
    case unknown
    case invalidImage
}




// 무한정 늘어나는 쓰레드가 발생할 수 있기 때문에 그러한 문제를 해결 하기 위해 Concurrency 등장

class Network {
    static let shared = Network()
    
    private init() { }
    
    // 1. GCD를 활용하여 네트워크 통신하기
    // 단점 : 모든 것이 성공일 경우에만 completionHandler 실행 가능
    func fetchThumbnail(completionHandler: @escaping (UIImage) -> Void) {
        let url = "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/A5MIbqxuQfQRtzGxg5UUTAxHfsM.jpg"
        
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
    
    // 2. URLSession을 이용한 네트워크
    // UIImage?, NetworkError? 옵셔널인 이유 :  image가 성공이면 error는 nil이기 때문
    // Result : 성공과 실패만 보내줌 즉, completion(nil, nil) 이런경우를 사용할 수 없게 강제화 시켜줌
    func fetchThumbnailURLSession(completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        
        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/A5MIbqxuQfQRtzGxg5UUTAxHfsM.jpg")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        // URLRequest vs URL : 타임 아웃 ( defaults 60초 네트워크 보내고 기다리는 시간 ), 캐시 설정 유무 ( 네트워크 통신이 끊겼을때도 이미지 나타남 - 한번 네트워크 통신으로 로드가 되면 데이터가 캐시에 저장이 됨 )
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // 데이터가 있을때
            guard let data else {
                completion(.failure(.unknown))
                return
            }
            
            // error가 nil이면 data가 있다는 소리 -> error가 옵셔널인 이유
            guard error == nil else {
                completion(.failure(.unknown))
                return
            }
            
            // 상태코드
            guard let response = response as? HTTPURLResponse,
            response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            //
            guard let image = UIImage(data: data) else {
                completion(.failure(.invalidImage))
                return
            }
            
            
            // 모든 조건을 만족했을때 image 전달
            // 네트워크 구현부에서 GCD를 completion을 넘겨주면 호출부에서 성공, 실패일때 따로 GCD를 사용하지 않아도된다.
            DispatchQueue.main.async {
                completion(.success(image))
            }
           
            
            // Error 핸들링을 하나 빠드려도 , completion(nil, nil) 이렇게 적어도 오류가 발생하지 않아서 즉, 휴면 에러 발생시 문제가 되지 않음
            
            // ==> Results 타입 도입
            
            
            
        }
        .resume()
        
    }
    
}
