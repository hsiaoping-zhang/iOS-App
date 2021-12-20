//
//  ArticleListData.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/5.
//

import Foundation
import FirebaseFirestore
import MapKit
import CoreLocation

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var articleID: String?
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }
}

class ArticleDataModel: ObservableObject{
    
    @Published var articles = [Article]()
    @Published var selfArticles: [String] = []
    @Published var rangeArea = "500 M"
    @Published var selectIndex = 0
    
    private var db = Firestore.firestore()
    
    //get total articles
    func fetchData() {
        print("fetchData function: \(currentUserRangeArea)[\(self.selectIndex)]")
        
        if(currentUserRangeArea == "50 M"){
            self.getRangeArticles(range: 50)
        }
        else if(currentUserRangeArea == "500 M"){
            self.getRangeArticles(range: 500)
        }
        else if(currentUserRangeArea == currentCity){
            self.getCityArticles()
        }
        else if(currentUserRangeArea == "全域"){
            getAllArticles()
        }
        else{
            self.getAreaArticles()
        }
        
    }
    
    func getArticle(data: [String: Any], id: String) -> Article{
        let title = data["title"] as? String ?? ""
        let loc = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
        let location = [loc.latitude: loc.longitude]
        let type = data["type"] as? String ?? "text"
        let activity =  data["activity"] as? String ?? "揪團"
        let writerID = data["writerID"] as? Int ?? 0
        let name = data["writerName"] as? String ?? ""
        let content = data["content"] as? String ?? ""
        
        let time = data["time"] as? Double ?? 0
//        let timeInterval = TimeInterval(time)
//        let date = Date(timeIntervalSince1970: timeInterval)
//        // 實例化一個 DateFormatter
//        let dateFormatter = DateFormatter()
//        // 設定日期格式
//        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
//        // 將日期轉換成 string 輸出給 today
//        let today = dateFormatter.string(from: date)
//        print("Time Stamp's Current Time:\(today)")
        
//        print("\(Timestamp(time))")
        let timeRange = data["timeRange"] as? Int ?? 10
        let emoji = data["emoji"] as? String ?? ""
        
        return Article(id: id, title: title, location: location, type: type, activity: activity, writerID: writerID, writerName: name, content: content, time: time, timeRange: timeRange, emoji: emoji)
    }
    
    func getCityArticles(){
        // scan all area in the city
        print("get city articles function:")
        self.selfArticles.removeAll()
        var docList: [String] = []
        self.articles.removeAll()
        db.collection("articles").document(currentCity).getDocument{ (document, error) in
            
            if let document = document, document.exists {
//                print(document.documentID, document.data()?["areaList"])
                let list = document.data()!["areaList"]! as! [String]
                for index in 0..<list.count{
                    print("city index: \(list[index])")
                    // each area
                    self.db.collection("articles").document(currentCity).collection(list[index]).getDocuments{ (querySnapShot, error) in
                        if let querySnapShot = querySnapShot{
                            for document in querySnapShot.documents{
                                let data = document.data()
                                if(docList.contains(document.documentID)){
                                    continue
                                }
                                
                                // category
                                if(activitySelected[data["activity"] as! String] != true){
                                    print("\(data["title"]) not subscribed.")
                                    continue
                                }
                                else{
                                    let actName = data["activity"] as? String ?? ""
                                    let tmp = activitySelected[actName]
                                    print("\(String(describing: data["title"])) : activitySelected[data[\'activity\'] = \(tmp)")
                                }
                                
                                // time range
                                let time_start = data["time"] as? Double ?? 0
                                let time_range = data["timeRange"] as? Int ?? 0
                                let time = Date().timeIntervalSince1970
                                if(time > time_start + Double(time_range)){
                                    print("expire")
                                    self.db.collection("articles").document(currentCity).collection(currentArea).document(document.documentID).delete()
                                    self.db.collection("dataBase").document(document.documentID).delete()
                                    continue

                                }
                                else{
                                    print("In time: \(time) < \(time_start + Double(time_range))")
                                }
                                
 
                                self.articles.append(self.getArticle(data: data, id: document.documentID))
                                
                                docList.append(document.documentID)
                            }
                            
                        }
                        
                    }
                }
            }
            else{
                print("Document does not exist")
            }
        }
        
    }
    
    func getAreaArticles(){
        print("getAreaArticles function")
        
        db.collection("articles").document(currentCity).collection(currentArea).addSnapshotListener{(QuerySnapshot, error) in
             
            guard let documents = QuerySnapshot?.documents else{
                print("No documents")
                return
            }

            self.articles = documents.flatMap{(QuerySnapshot) -> Article? in
                let docID = QuerySnapshot.documentID
                let data  = QuerySnapshot.data()
                
                if(activitySelected[data["activity"] as! String] != true){
                    print("\(data["title"]) not subscribed.")
                    return nil
                }
                else{
                    let actName = data["activity"] as? String ?? ""
                    let tmp = activitySelected[actName]
                    print("\(String(describing: data["title"])) : activitySelected[data[\'activity\'] = \(tmp)")
                }
                
                // time range
                let time_start = data["time"] as? Double ?? 0
                let time_range = data["timeRange"] as? Int ?? 0
                let time = Date().timeIntervalSince1970
                if(time > time_start + Double(time_range)){
                    print("expire")
                    self.db.collection("articles").document(currentCity).collection(currentArea).document(docID).delete()
                    self.db.collection("dataBase").document(docID).delete()
                    return nil

                }
                else{
                    print("In time: \(time) < \(time_start + Double(time_range))")
                }
                
                let result = self.getArticle(data: data, id: docID)
                return result
            
            }
        }
    }
    
    func getAllArticles(){
        print("get All articles function")
        db.collection("dataBase").addSnapshotListener{(QuerySnapshot, error) in
             
            guard let documents = QuerySnapshot?.documents else{
                print("No documents")
                return
            }
            
            self.articles = documents.flatMap{(QuerySnapshot) -> Article? in
                let docID = QuerySnapshot.documentID
                let data  = QuerySnapshot.data()
                
                if(activitySelected[data["activity"] as! String] != true){
                    print("\(data["title"]) not subscribed.")
                    return nil
                }
                else{
                    let actName = data["activity"] as? String ?? ""
                    let tmp = activitySelected[actName]
                    print("\(String(describing: data["title"])) : activitySelected[data[\'activity\'] = \(tmp)")
                }
                
                // time range
                let time_start = data["time"] as? Double ?? 0
                let time_range = data["timeRange"] as? Int ?? 0
                let time = Date().timeIntervalSince1970
                if(time > time_start + Double(time_range)){
                    print("expire")
                    self.db.collection("dataBase").document(docID).delete()
                    return nil

                }
                else{
                    print("In time: \(time) < \(time_start + Double(time_range))")
                }
                
                let result = self.getArticle(data: data, id: docID)
                return result
            
            }
        }
    }
    
    func getRangeArticles(range: Int){
        print("getRangeArticles funstion")
        db.collection("articles").document(currentCity).collection(currentArea).addSnapshotListener{(QuerySnapshot, error) in
             
            guard let documents = QuerySnapshot?.documents else{
                print("No documents")
                return
            }
            print("current: \(currentLongitude), \(currentLatitude)")

            self.articles = documents.flatMap{(QuerySnapshot) -> Article? in
                let docID = QuerySnapshot.documentID
                let data  = QuerySnapshot.data()

                let loc = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let location = [loc.latitude: loc.longitude]

                
                let loc1 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                let loc2 = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
                
                let meter = loc1.distance(from: loc2)
                print("\(data["title"]) : \(meter) [\(loc.latitude), \(loc.longitude)]")
                
                if(meter > Double(range)){
                    return nil
                }

                let result = self.getArticle(data: data, id: docID)
                
                return result
            
            }
        }
    }
    
    func getUserArticle(userName: String){
        db.collection("users").document(currentUserName).collection("articles").addSnapshotListener{(QuerySnapshot, error) in
            guard let documents = QuerySnapshot?.documents else{
                print("No documents")
                return
            }
            print("get user article: user name: \(userName)")
            self.selfArticles = documents.flatMap{(QuerySnapshot) -> String? in
                let docID = QuerySnapshot.documentID
                let data  = QuerySnapshot.data()
                
                // time range
                let time_start = data["time"] as? Double ?? 0
                let time_range = data["timeRange"] as? Int ?? 0
                let time = Date().timeIntervalSince1970
                if(time > time_start + Double(time_range)){
                    print("expire")
                    self.db.collection("users").document(currentUserName).collection("articles").document(docID).delete()
                    return nil

                }
                else{
                    print("In time: \(time) < \(time_start + Double(time_range))")
                }
                
                return data["title"] as? String ?? "NULL"
            }
        }
    }
}

func convertTimeToDate(time: Double) -> String{
    
    let timeInterval = TimeInterval(time)
    let date = Date(timeIntervalSince1970: timeInterval)
    // 實例化一個 DateFormatter
    let dateFormatter = DateFormatter()
    // 設定日期格式
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
    // 將日期轉換成 string 輸出給 today
    let today = dateFormatter.string(from: date)
    return today
//    print("Time Stamp's Current Time:\(today)")
}
