//
//  AddPostModel.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/6.
//

import Foundation
import FirebaseFirestore
//import Firebase
import SwiftUI

class PostModel: ObservableObject {
    @Published var post: Article = Article(id: "000",
                                           title: "",
                                           location: [0.0:0.0],
                                           type: "text",
                                           activity: "揪團",
                                           writerID: currentUserID,
                                           writerName: currentUserName,
                                           content: "",
                                           time: 0,
                                           timeRange: 10,
                                           emoji: "")
    @Published var comments: [ArticleComment] = []
    
    init(){
        
    }
    
    private var db = Firestore.firestore()
    
    func addPost(_ post: Article, loc: GeoPoint){
        let randomDocument = getRandomString(length: 20)
        do{
            print("send data")
//            let loc = GeoPoint(latitude: post.location[0] ? Double , longitude:  post.location[0]?)
            let time = Date().timeIntervalSince1970
//            let serverTIme = Firestore.time
            print("time: \(time) (writer id: \(post.writerID)")

            
            var newData: [String: Any] = [
//                "id": Int.random(in: 1..<100),
                "title": post.title,
                "location": loc,
                "writerName": post.writerName,
                "writerID": post.writerID,
                "content": post.content,
                "type": post.type,
                "activity": post.activity,
                "time": time,
                "timeRange": post.timeRange,
                "emoji": post.emoji,
//                "comme"
            ]
            
           
            // area
            db.collection("articles").document(currentCity).collection(currentArea).document(randomDocument).setData(newData){ error in
                if let err = error{
                    print("(area) error with writing document: \(err)")
                }
                else{
                    print("(area) document successfully written!")
                }
            }
            
            // user articles list
            let simpleData: [String: Any] = [
                "title": post.title,
                "commentNum": 0
            ]
            db.collection("users").document(currentUserName).collection("articles").document(randomDocument).setData(simpleData){ error in
                if let err = error{
                    print("(user) error with writing document: \(err)")
                }
                else{
                    print("(user) document successfully written!")
                }
            }

            
            // global database
            newData["likes"] = 0
            newData["comments"] = []
            db.collection("dataBase").document(randomDocument).setData(newData){ error in

                if let err = error{
                    print("(global) error with writing document: \(err)")
                }
                else{
                    print("(global) document successfully written!")
                }
            }
            
        }
    }
    
    func save(lat: Double, lon: Double){
        let loc = GeoPoint(latitude: lat, longitude: lon)
//        post.location = [loc.latitude: loc.longitude]
//        post.location = loc
        print("location: [\(lat), \(lon)]")
        addPost(post, loc: loc)
    }
    
    func delPost(docID: String){
        db.collection("articles").document(currentCity).collection(currentArea).document(docID).delete()
        db.collection("dataBase").document(docID).delete()
        db.collection("users").document(currentUserName).collection("articles").document(docID).delete()

    }
    
    func delAudio(docID: String){
        
    }
    
    func getComment(articleID: String){
        print("getComment function")
        self.comments.removeAll()
        
//        var comments: [String] = []
        db.collection("dataBase").document(articleID).getDocument{ (document, data) in
            if let document = document, document.exists {
                let comment_array:[[String:Any]] = document["comments"] as! [[String : Any]]
                for item in comment_array{
                    let content = item["content"] as! String
                    let time = item["time"] as! Double
                    let ID = item["writerID"] as! Int
                    let name = item["writerName"] as! String
                    print(content, time, ID, name)

                    self.comments.append(ArticleComment(content: content, time: time, wrtierID: ID, writerName: name))
                }
            }
        }


    }
    
    func sendComment(articleID: String, content: String) -> String{
        print("send Comment function")
        var resultMessage = ""
//        let time = Timestamp.init()
        let time = Date().timeIntervalSince1970
        let singleComment: [String: Any] = ["content": content, "time": time, "writerID": currentUserID, "writerName":currentUserName]
        
        print("comment sending")
        db.collection("dataBase").document(articleID).updateData(["comments": FieldValue.arrayUnion([singleComment])])
        resultMessage = "success"

        return resultMessage
    }
}

func getRandomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let string = String((0..<length).map{ _ in letters.randomElement()! })
    print(string)
  return string
}

func myColor(R: Int, G: Int, B: Int) -> Color{
    return Color(red: Double(R)/255.0, green: Double(G)/255.0, blue: Double(B)/255.0, opacity: 0.0)
//    return Color(red: Float(R)/255, green: Float(G), blue: Float(B)/255)
}
