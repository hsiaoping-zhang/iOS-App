//
//  ContentView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/5.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        TabView(){
            PersonalView()
                .tabItem {
                    TabIcon(img: "person.circle.fill", text: "Person")
                }
            MapView()
                .tabItem{
                    TabIcon(img: "map.fill", text: "Map")
            }
            PostListView()
                .tabItem {
                    TabIcon(img: "list.bullet.rectangle", text: "Post")
                }
            WritePostView()
                .tabItem {
                    TabIcon(img: "pencil.circle.fill", text: "Write")
                }
//            AudioView()
//                .tabItem {
//                    TabIcon(img: "waveform.circle.fill", text: "audio")
//                }
            
        }
        .edgesIgnoringSafeArea(.all)

    }
}


struct TabIcon: View{
    let img, text: String
    var body: some View{
        VStack{
            Image(systemName: img)
            Text(text)
                .font(.footnote)
                .frame(minWidth: 20, maxWidth: .infinity, minHeight: 10, maxHeight: 20)
            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
