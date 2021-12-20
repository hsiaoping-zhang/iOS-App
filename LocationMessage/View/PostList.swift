//
//  PostList.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/5.
//

import SwiftUI

var test = Article(id: "0000", title: "test title", location: [0.0:0.0], type: "text", activity: "groupBuying", writerID: 1, writerName: "HELLO", content: "", time: 1531712680.87298, timeRange: 10, emoji: "")

var currentUser = Person(name: "tester", gender: "F", age: 22)
//var currentID: Int = 2

struct PostListView: View {
    @ObservedObject private var dataModel = ArticleDataModel()
    
    var body: some View {

        NavigationView{
            List(dataModel.articles){ article in
                // writer hiself
                if(article.writerID == currentUserID){
                    NavigationLink(
                        destination: PostDetail(article: article),
                        label: {
                            Text(article.title)
                                .foregroundColor(Color.red)
                    })
                }
                // others
                else{
//                    print(String(article.writer) + " / " + String(currentID))
                    NavigationLink(
                        destination: PostDetail(article: article),
                        label: {
                            Text(article.title)
                                .foregroundColor(Color.blue)
                    })
                }

            }
            .navigationTitle("文章列表")
            .onAppear(){
                self.dataModel.fetchData()
            }
        }
    }
}

struct PostList_Previews: PreviewProvider {
    static var previews: some View {
        PostListView()
    }
}
