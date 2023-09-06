//
//  Roomdata.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import Foundation
import FirebaseFirestore

// 実際に使うroomのデータ
struct RoomData: Codable {
    var id: String = ""
    var title: String
    var expirationDate: Date
    var time: Date
    var memo: String
    var imageData: Data = Data()
    var imageURL: String = ""
    var markers: [Marker]
    
    // RoomDataを新しく作る時に呼び出されるやつ。uploadRoomDataを用いて生成する
    init(uploadRoomData: UploadRoomData, id: String, imageData: Data) {
        self.id = id
        title = uploadRoomData.title
        expirationDate = uploadRoomData.expirationDate
        time = uploadRoomData.time
        memo = uploadRoomData.memo
        imageURL = uploadRoomData.imageURL
        markers = uploadRoomData.markers
        
        self.imageData = imageData
    }
    
    // 要素（titleなど）を全部直に打ち込んでいく。
    init(title: String, expirationDate: Date, time: Date, memo: String, imageData: Data, imageURL: String, markers: [Marker]) {
        self.title = title
        self.expirationDate = expirationDate
        self.time = time
        self.memo = memo
        self.imageData = imageData
        self.imageURL = imageURL
        self.markers = markers
    }
}

// Firebaseとやりとりするデータだけをまとめたものです。
struct UploadRoomData: Codable {
    var uid: String
    var title: String
    var expirationDate: Date
    var time: Date
    var memo: String
    var imageURL: String = ""
    var markers: [Marker]
}

// マーカー（ピン）のデータ
struct Marker: Codable {
    var title: String
    var latitude: Double
    var longitude: Double
}
