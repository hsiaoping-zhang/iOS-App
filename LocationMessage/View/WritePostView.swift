//
//  WritePostView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/6.
//

import SwiftUI
import MapKit


struct WritePostView: View {
    let yellowColor = Color(red: 1, green: 187.0/255, blue: 105.0/255)
    @State var typeIndex = 0
    @State var colors = [Color(red: 1, green: 187.0/255, blue: 105.0/255),
                         Color(red: 201.0/255, green: 221.0/255, blue: 216.0/255),
                         Color(red: 223.0/255, green: 201.0/255, blue: 181.0/255)]
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                
                Button(action: {
                    typeIndex = 0
                }, label: {
                    Text("文字")
                        .font(.headline)
                        .foregroundColor(.white)
                })
                
                Spacer()
                
//                Button(action: {
//                    typeIndex = 1
//                }, label: {
//                    Text("語音轉文字")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                })
                
//                Spacer()
                
                Button(action: {
                    typeIndex = 2
                }, label: {
                    Text("語音")
                        .font(.headline)
                        .foregroundColor(.white)
                })
                
                Spacer()
            }
            .padding()
            .padding(.top, 30)
//            .padding(.top, (UIScreen.screenHeight)!+10)
            .background(colors[typeIndex])
            
            if(typeIndex == 0){
//                TextFormView()
                TextFormTest()
            }
//            else if(typeIndex == 1){
//                Spacer()
//                AudioView()
//                Spacer()
//            }
            else{
                Spacer()
                RecorderView()
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct TextFormTest: View{
    @StateObject var viewModel = PostModel()
    @State private var showAlert = false
    @State var remainingTextNum = 150
    @State private var selectedIndex = 0
    @State private var timeSelected = 0
    let yellowColor = Color(red: 1, green: 187.0/255, blue: 105.0/255)
    let categories = ["揪團", "好物", "美食"]
    let timeRange = ["10 min", "30 min", "1 hr"]
    @State private var time_hr = "0"
    @State private var time_min = "5"
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    
    @State var showIconList = false
//    @State var emoji = ""

    var body: some View{
        ScrollView{
            ZStack{
                VStack{
                    Spacer()
                    HStack{
                        Text("標題")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 10)

                    TextField("", text: $viewModel.post.title, onCommit: {
                        UIApplication.shared.endEditing()
                    })
                        .font(.system(size: 30))
                        .padding(.leading, 10)
                        .padding([.top, .bottom], 5)
                        .background(yellowColor.opacity(0.5))
                        .cornerRadius(10)
                        .frame(width: UIScreen.screenWidth * 0.85)

                    HStack{
                        Text("選擇分類")
                            .font(.title2)
                            .bold()
                        Spacer()

                        Button(action: {
                            showIconList.toggle()
                        }, label: {
                            Image(systemName: "plus.circle")
                        })
                        
                        Text(viewModel.post.emoji)
                        
                    }
                    .padding(.top, 10)
 
                    Picker(selection: $selectedIndex, label: Text("選擇分類")) {
                        ForEach(categories.indices) { (index) in
                            Text(categories[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: UIScreen.screenWidth*0.85, height: 60)
                    .clipped()
                    .padding(5)
                    
                    HStack{
                        Text("時效")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    HStack{
                        
                        TextField("", text: $time_hr)
                            .font(.system(size: 20))
                            .padding(10)
                            .frame(width: 80, alignment: .center)
                            .background(yellowColor.opacity(0.3))
                            .cornerRadius(10)
                        
                        Text("小時")
                        
                        TextField("", text: $time_min)
                            .font(.system(size: 20))
                            .padding(10)
                            .frame(width: 80, alignment: .center)
                            .background(yellowColor.opacity(0.3))
                            .cornerRadius(10)
                        
                        Text("分鐘")
                        
                        Spacer()
                    }
                    .padding(.top, 5)
                    

//                    Picker(selection: $timeSelected, label: Text("選擇時間")) {
//                        ForEach(timeRange.indices) { (index) in
//                            Text(timeRange[index])
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .frame(width: UIScreen.screenWidth*0.85, height: 60)
//                    .clipped()
//                    .padding(5)

                    HStack{
                        Text("內容")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Text("剩餘字數：\(remainingTextNum - viewModel.post.content.count)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .padding(.top, 10)
                    
                    TextEditor(text: $viewModel.post.content)
                        .font(.system(size: 20))
                        .frame(width: UIScreen.screenWidth * 0.85, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        
                    Button(action: {
                        handleDoneTapped()
                        
                    }, label: {
                        Text("發布")
                            .font(.system(size: 25))
                            .padding(5)
                            .frame(width: UIScreen.screenWidth * 0.85, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                            .background(yellowColor)
                            .cornerRadius(10)
                            
                    })
                    .padding(.top, 10)
                    .alert(isPresented: $showAlert){ () -> Alert in
                        print("alert")
                        let check = checkPost()
                        let resultString = check ? "發布成功" : "請填入內容"
                        if(check){
                            return Alert(
                                title: Text(resultString),
                                dismissButton:
                                    .default(Text("OK"),
                                        action:{
                                            clearText()
                                        }
                                    )
                            )
                        }
                        return Alert(title: Text(resultString))

                    }
                    
//                    Spacer()
        //            Spacer()

                }
                .padding([.leading, .trailing], 30)
                .onAppear{
                    print("GOGO")
                    manager.delegate = managerDelegate
                }
                if(showIconList){
                    PopList(emoji: $viewModel.post.emoji, show: $showIconList)
                }
            }
        }
    }
    func clearText(){
        // clear
        viewModel.post.title = ""
        viewModel.post.content = ""
    }
    
    func checkPost()-> Bool {
        print("checkPost function")
//        print("+ " + String(currentID))
        if(viewModel.post.title == "" || viewModel.post.content == ""){
            return false
        }
        return true
    }

    // send data to firebase
    func handleDoneTapped(){
        print("click")
        self.showAlert = true
//        print(managerDelegate.currentUserLogitude)
        if(viewModel.post.title == "" || viewModel.post.content == ""){
            return
        }
        switch(selectedIndex){
        case 0:
            viewModel.post.activity = "揪團"
        case 1:
            viewModel.post.activity = "好物"
        default:
            viewModel.post.activity = "美食"
        }
        let time_h = Int(time_hr) ?? 0
        let time_m = Int(time_min) ?? 0
        print("time: \(time_h), \(time_m)")
        viewModel.post.timeRange = time_h  * 3600 + time_m * 60
        
        viewModel.post.type = "text"
        viewModel.save(lat: managerDelegate.currentUserLatitude, lon: managerDelegate.currentUserLogitude)
    }

}
let iconList = ["🍧", "🍪", "🎂", "🍹", "⚠️", "🎫"]
struct PopList: View{
    
    @Binding var emoji: String
    @Binding var show: Bool
    var body: some View{
        VStack(spacing: 20){
            VStack(spacing: 20){
                ForEach(0..<2, id:\.self){ i in
                    HStack{
                        ForEach(0..<(iconList.count/2), id:\.self){ item in
                            Button(action: {
                                emoji = iconList[i*3+item]
                                show.toggle()
                            }, label: {
                                Text(iconList[i*3+item])
                            })
                            
                        }
                    }
                    
                }
                
            }
            
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .border(Color.black, width: 1)
    }
}


struct WritePostView_Previews: PreviewProvider {
    static var previews: some View {
        WritePostView()
//        PopList(emoji: <#T##Binding<String>#>)
    }
}
