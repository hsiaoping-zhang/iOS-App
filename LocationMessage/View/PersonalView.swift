//
//  PersonalView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/24.
//

import SwiftUI
import MapKit

// 一開始的進入畫面
struct PersonalView: View {
    @State private var selectedIndex = 2
    @State var manager = CLLocationManager()
    @ObservedObject var managerDelegate = locationDelegate()
    @StateObject var Model = ArticleDataModel()
    @State var areaSelection = [ "50 M", "500 M", currentArea, currentCity, "全域"]
    @State var selectFlag = false
    @State var activityBool = [true, true, true]
    
    var body: some View {
        
            VStack{
                HStack{
                    Image("user-\(currentUserID % 3 + 1)")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .cornerRadius(20)
                        
                    Text(currentUserName + " (ID : \(currentUserID))")
                        .font(.system(size: 20))
                        .padding(.leading)

                }
                .frame(width: UIScreen.screenWidth * 0.9, height: 80, alignment: .leading)
                .padding(.all)
                .padding(.top, 30)
                
                Text("個人資訊")
                    .font(.system(size: 20, weight: .bold , design: .default))
                    .foregroundColor(.gray)
                    .frame(width: UIScreen.screenWidth * 0.8, height: 15, alignment: .leading)
                    .padding()
                
                VStack{
                    HStack {
                        Text("目前位置 ")
                            .font(.system(size: 20, weight: .bold, design: .default))
                        Text("( \(managerDelegate.currentUserLatitude) , \(managerDelegate.currentUserLogitude) )")
                    }
                    HStack{
                        Image(systemName: "location.north.line.fill")
                            .foregroundColor(.red)
                            .padding(.leading, 3)
                        Text("\(managerDelegate.currentUserCity) \(managerDelegate.currentUserArea)")
                            .frame(width: 100, height: 20, alignment: .leading)
                    }
                    
                }
                .frame(width: UIScreen.screenWidth * 0.8, height: 40, alignment: .leading)
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.bottom, 10)
                
                
                Text("設置")
                    .font(.system(size: 20, weight: .bold , design: .default))
                    .foregroundColor(.gray)
                    .frame(width: UIScreen.screenWidth * 0.8, height: 10, alignment: .leading)
                    .padding()
                
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    HStack {
                        Text("接收範圍 ")
                            .font(.system(size: 20, weight: .bold, design: .default))
                        
                        Menu(selectFlag ? areaSelection[selectedIndex] : "請選擇") {
                            ForEach(areaSelection.indices) { (index) in
                                Button(action: {
                                    print("select index : \(index)")
                                    selectedIndex = index
                                    selectFlag = true
                                    
                                    managerDelegate.rangeArea = areaSelection[selectedIndex]
            
                                    currentUserRangeArea = areaSelection[selectedIndex]
                                    print("(change) Area range: \(currentUserRangeArea)")
                                    
                                    currentLatitude = managerDelegate.currentUserLatitude
                                    currentLongitude = managerDelegate.currentUserLogitude
                                    
                                }, label: {
                                    Text(areaSelection[index])
                                })
                                
                            }
                        }
                        .foregroundColor(.black)
                    }
                    .frame(width: UIScreen.screenWidth * 0.8, height: 30, alignment: .leading)
                    .padding(.all)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.bottom, 10)
                    .padding(.top, 15)

                    
                    VStack {
                        HStack{
                            Text("訂閱主題 ")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .padding(.bottom, 5)
                            Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                
                                Labels(labelName: "揪團", selected: "揪團", show: $activityBool[0])
                                Labels(labelName: "好物", selected: "好物", show: $activityBool[1])
                                Labels(labelName: "美食", selected: "美食", show: $activityBool[2])
                            }
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.8, height: 80, alignment: .leading)
                    .padding(.all)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.bottom, 10)
                    
                    VStack {
                        Text("我的發文 ")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .padding(.bottom, 10)
                        VStack{
                            ForEach(Model.selfArticles.indices, id:\.self){ index in
                                HStack{
                                    Text(Model.selfArticles[index])
                                        .font(.system(size: 20))
                                    Spacer()
                                }
                                
                            }

                        }
                        .onAppear{
                            Model.getUserArticle(userName: "tester")
                        }
                        
                    }
                    .frame(width: UIScreen.screenWidth * 0.8, alignment: .leading)
                    .padding(.all)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                }
                .frame(width: UIScreen.screenWidth, height: 500, alignment: .center)
                .padding(.top, 5)
//                .offset()
                
            }
            .onAppear{
                manager.delegate = managerDelegate
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    print("change")
                    areaSelection = [ "50 M", "500 M", managerDelegate.currentUserArea, managerDelegate.currentUserCity, "全域"]
                }
                
            }

        }

}

struct Labels: View{
    var labelName: String
    @State var selected: String
    @State var color = Color.yellow.opacity(0.8)
    @Binding var show: Bool

    var body: some View{
        HStack{
            if(show == true){
                Button(action: {
                    show.toggle()
                    activitySelected[selected] = false
                    print("toggle to false: \(activitySelected[selected])")
                }, label: {
                        Text(labelName)
                            .foregroundColor(.black)
                        Image(systemName: "pin.fill")
                            .foregroundColor(.red.opacity(0.6))
                            .font(.system(size: 15))
                    })
            }
            else{
                Button(action: {
                    show.toggle()
                    activitySelected[selected] = true
                    print("toggle")
                }, label: {
                    Text(labelName)
                        .foregroundColor(.white)
                    Image(systemName: "pin.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 15))
                })
            }
        }
        
        
//        HStack{
//
//            Button(action: {
//                if(activitySelected[selected] == true){
//                    activitySelected[selected] = false
//                }
//                else{
//                    activitySelected[selected] = true
//                }
////                activitySelected[selected]?.toggle()
//                print("toggle: \(activitySelected[selected]!)")
//
//            }, label: {
//                Text(labelName)
//                    .foregroundColor(.black)
//                if(activitySelected[selected]! == true){
//                    Image(systemName: "pin.fill")
//                        .foregroundColor(.red.opacity(0.6))
//                        .font(.system(size: 15))
//                }
//                else{
//                    Image(systemName: "pin.fill")
//                        .foregroundColor(.white.opacity(0.6))
//                        .font(.system(size: 15))
//                }
//            })
//        }
        .frame(width: CGFloat(labelName.count+2) * 20, height: 30, alignment: .center)
        .background(color)
        .cornerRadius(15)
        
        
        
    }
}

struct PersonalView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalView()
    }
}
