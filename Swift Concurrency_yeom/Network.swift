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
    
    
    
    // 3. Swift Concurrency
    // function을 비동기로 작업할거야 : async
    // return UIImage를 얻겠어
    func fetchThumbnailAsyncAwait(value: String) async throws -> UIImage {
        
        let url = URL(string: "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/\(value).jpg")!
        

        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        // await: 비동기를 동기처럼 작업할거니까, 응답 올때까지 기다려
        // 코드의 순서대로 진행 할 수있게 await가 만들어줌  <<- 코드 실행하다가 비동기 있으면 패스하고 마지막 실행되고 다시 비동기 구문 실행되고...
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
                  throw NetworkError.invalidResponse
              }
        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidImage
        }
        
        print("url - \(url.description)")
        
        return image
    }
    
    // return image들을 한번에 받기 위해 배열형식
    func fetchThumbnailAsynclet() async throws -> [UIImage] {
        
        async let image = try await Network.shared.fetchThumbnailAsyncAwait(value: "A5MIbqxuQfQRtzGxg5UUTAxHfsM") // 비동기 함수가 다 실행될때까지 기다려
        async let image2 = try await Network.shared.fetchThumbnailAsyncAwait(value: "eDps1ZhI8IOlbEC7nFg6eTk4jnb")
        async let image3 = try await Network.shared.fetchThumbnailAsyncAwait(value: "mYLOqiStMxDK3fYZFirgrMt8z5d")
        
        // 비동기로 나오는 image, image2, image3를 비동기로 배열에 담아야 하기 때문에 try await 사용
        return try await [image, image2, image3]
    }
    
    // taskGroup
    func fetchThumbnailTaskGroup() async throws -> [UIImage] {
        let poster = [
            "A5MIbqxuQfQRtzGxg5UUTAxHfsM",
            "eDps1ZhI8IOlbEC7nFg6eTk4jnb",
            "mYLOqiStMxDK3fYZFirgrMt8z5d"
        ]
        
        // Sendable.protocol : 네트워크 통신으로 나오는 return 값의 타입을 적어준다.
        return try await withThrowingTaskGroup(of: UIImage.self, body: { group in
            
            for item in poster {
                
                group.addTask { // <- 네트워크 통신 해야 되는 갯수를 group에 추가해준다.
                    try await self.fetchThumbnailAsyncAwait(value: item)
                }
            }
            
            var resultImages: [UIImage] = []
            
            for try await item in group {
                resultImages.append(item)
            }
            
            return resultImages
            
            
        })
        
        
        
    }
}
