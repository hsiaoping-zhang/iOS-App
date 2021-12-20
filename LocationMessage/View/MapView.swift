//
//  SwiftUIView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/5.
//

import SwiftUI
//import Combine
import MapKit


struct MapView: View {
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLatitude, longitude:currentLongitude), latitudinalMeters: 1000, longitudinalMeters: 1000)
    @State var tracking: MapUserTrackingMode = .follow
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    @ObservedObject private var dataModel = ArticleDataModel()
    
    @State var pins: [Pin] = []
    @State var testString: String = "你選擇的標記"
    @State var currentArticle: Article = test
    
    @State private var showingSheet = false
    let colors = [Color.yellow, .blue, .gray]
    @State var currentFlag = true

    var body: some View {
        NavigationView{
            VStack{
                Map(coordinateRegion: $region,
                    annotationItems: pins){ marker in


                    MapAnnotation(coordinate: marker.location) {
                        
                        MapIcon(marker: marker, currentArticle: $currentArticle, testString: $testString)
                   }
                    
                }
                .edgesIgnoringSafeArea(.top)
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.8, alignment: .center)
                
                


                Spacer()
                // 下面預覽說明
                NavigationLink(
                    destination: PostDetail(article: currentArticle)
                        .navigationBarTitle(currentArticle.title, displayMode: .inline)
                ) {


                    Text(testString)
                        .foregroundColor(Color.black)
                        .font(.system(size: 25))
                        .padding()
                        .background(Color.yellow.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.top, 20)
                }
                .onTapGesture {
                    print("tap!!")
    //                showingSheet.toggle()
                }

                .frame(width: UIScreen.screenWidth-20, height: 200)
                .cornerRadius(50)
                .offset(y:-80)

            }
            .onAppear{
                manager.delegate = managerDelegate
                print("fetch")
                self.dataModel.fetchData()
                
                pins.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                   // Excecute after 3 seconds
                    for article in dataModel.articles{
                        let x = Array(article.location.keys)[0]
                        let y = article.location[x] ?? 0.0
                        let marker = Pin(location: CLLocationCoordinate2D(latitude: x, longitude: y), article: article)
                        pins.append(marker)
                    }
                    
                }
            }
        }
        
    }
}

struct SheetView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            Spacer()
            Button("Press to dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.title)
            .padding()
            .background(Color.black)
        }
    }
    
}

struct MapIcon: View{
    var marker: Pin
    @Binding var currentArticle: Article
    @Binding var testString: String
    var body: some View{
        ZStack{
            Circle()
                .frame(width: 50, height: 50, alignment: .center)
                .foregroundColor(Color.white.opacity(0.95))
            
            VStack{
                Text(marker.article.type == "text" ?  marker.article.emoji != "" ? marker.article.emoji : "🍰" : "🔈")
                    .foregroundColor(marker.article.type == "text" ? .red : .blue)
                    .font(.system(size: 20))
                    .onTapGesture {
                        
                        testString = marker.article.title
                        currentArticle = marker.article
                        print(marker.location.latitude, marker.location.longitude, ":", marker.article.title)
                   }
                    
                Text(marker.article.title)
                    .font(.system(size: 15)).bold()
            }
//            .padding(.top, 5)
            
        }
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
