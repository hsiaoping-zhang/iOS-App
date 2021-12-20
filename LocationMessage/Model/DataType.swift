//
//  DataType.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/5.
//

import Foundation
import MapKit
import FirebaseFirestore
import Firebase

struct Article: Hashable, Codable, Identifiable {
//    var id = UUID()
    var id: String
    var title: String
    var location: [Double:Double]
    var type: String
    var activity: String
    var writerID: Int
    var writerName: String
    var content: String
    var time: Double
    var timeRange: Int
    var emoji: String
}

struct ArticleComment: Hashable, Codable{
    var content: String
    var time: Double
    var wrtierID: Int
    var writerName: String
}

struct Person: Hashable, Codable, Identifiable{
    var id = UUID()
    var name: String
    var gender: String
    var age: Int
}

enum CommentElement: String, CodingKey {
    case content
    case time
    case writerID
    case writerName
}

// Map

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Pin: Identifiable{
    var id = UUID().uuidString
    var location: CLLocationCoordinate2D
    var article: Article
}
