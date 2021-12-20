//
//  PostDetail.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/6.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import AVFoundation
var audioPlayer : AVAudioPlayer!

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct PostDetail: View {
    var article: Article
    @State var audioPlayer : AVAudioPlayer!
    
    // sheet toggle variable
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = PostModel()
    @State var screenSpace = 10
    @State var commentSheetShow = false
    @State var commentText = ""
    
    @State private var showAlert = false
    @State private var commentAlertText = ""
    @State private var commentAlert = false
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @State private var comments: [String] = []
    
    let gradient = [Color(red: 221.0/255, green: 214.0/255, blue: 243.0/255), Color(red: 250.0/255, green: 172.0/255, blue: 168.0/255)]
//    let divider = decideDivider(article)
    
    var body: some View {
        
        ZStack{
            // background color
//            LinearGradient(gradient: .init(colors:gradient), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
//
            Color(red: 130.0/256, green: 172.0/256, blue: 159.0/256).opacity(0.5)
            
            VStack(alignment: .leading){
                HStack(alignment: .top, spacing: 10){
                    Image("user-\(article.writerID%3+1)")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                        .padding(.all, 6)
                        .background(Color.white)
                        .cornerRadius(26)
                        .padding(.all, 4)
                        .background(Color(red: 238.0/255, green: 238.0/255, blue: 238.0/255))
                        .cornerRadius(30)
                        
                    Text(String(article.writerName))
                        .font(.title3)
                        .frame(width: 200, height: 60, alignment: .leading)
                    
                }
                .padding(.leading, 20)
                .padding(.top, 10)
                .frame(width: UIScreen.screenWidth, alignment: .leading)
                
                Text(article.title)
                    .font(.largeTitle).bold()
                    .padding(.leading, 30)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                HStack{
                    Spacer()
                    Text("\(convertTimeToDate(time: article.time))")
                        .font(.subheadline)
                        .padding(.trailing, 50)
                }
                
                HStack{
                    Spacer()
                    Text("expire: \(convertTimeToDate(time: article.time+Double(article.timeRange)))")
                        .font(.subheadline)
                        .padding(.trailing, 50)
                }
                
                
                if(article.type == "text"){
                    Text(article.content)
                        .padding([.top, .leading], 20)
                        .frame(width: UIScreen.screenWidth - CGFloat(screenSpace) * 4, height: 200, alignment: .topLeading)
                        .background(Color.white)
                        .cornerRadius(20)
                        .offset(x: 20)
                }
                else{
                    Button(action: {
                        print("click audio button")
                        getAudio(audioName: article.content)
//                        getAudio(audioName: article.content)
                    }, label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                    })
//                    .offset(x: 20)
                    .padding(.leading, 40)
                }
                
                // buttons
                HStack{
                    Spacer()
                    
                    Button(action: {
                            commentSheetShow.toggle()
                            print("show comment sheet")
                    }){
                        VStack{
//                                Image(systemName: "message.circle")
//                                    .padding(.bottom, 0.2)
                            Text("+ 留言")
                        }
                        .frame(width:UIScreen.screenWidth/3)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    if(currentUserID == article.writerID){
                        Button(action: { handleDelete(docID: article.id) }){
                            VStack{
                                Text("- 刪除")
                            }
                            .frame(width:UIScreen.screenWidth/3)
                            .foregroundColor(.red)
                        }
                        .alert(isPresented: $showAlert){ () -> Alert in
                            print("alert")
                                return Alert(
                                    title: Text("成功刪除，請回上一頁")
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                        
                    
                }
                .frame(width:UIScreen.screenWidth, alignment: .center)
                .padding(.leading)
                .padding(.top, 10)
                
                
                Text("留言")
                    .font(.title2).bold()
                    .offset(x: 20)
                    .padding([.top, .leading], 10)
                // 需要每行用額外的 struct 處理，不然會 frame 跑版
                VStack{
                    // comments
                    ForEach(viewModel.comments.indices, id:\.self){ index in
                        let string = viewModel.comments[index].time
//                        let ind = string.index(string.startIndex, offsetBy: 19)
                        CommentRow(imgName: "user-"+String(viewModel.comments[index].wrtierID%3+1), name: viewModel.comments[index].writerName, content: viewModel.comments[index].content, time: convertTimeToDate(time: viewModel.comments[index].time), writer: (viewModel.comments[index].wrtierID == currentUserID) ? true : false)
//                        HStack{
//                            Text(viewModel.comments[index].content)
//                                .font(.system(size: 15))
//                                .padding(.bottom, 10)
//                            Spacer()
//                            Text(viewModel.comments[index].time[..<ind])
//                                .font(.system(size: 10))
//                        }
                    }
                    
                }
                .offset(x: 20)
                .padding(.top, 10)
                .padding(.leading, 10)
                .padding(.trailing, 40)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        viewModel.getComment(articleID: article.id)
                    }
                }
                Spacer()
                
                VStack{
                    Spacer()
                    HStack{
                        TextField("", text: $commentText)
                            .font(.system(size: 20))
                            .padding(.leading, 20)
                            .frame(height:50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .offset(y: commentSheetShow ? 0 : UIScreen.screenHeight)
                            .alert(isPresented: $showAlert){ () -> Alert in
                                print("comment alert")
                                    return Alert(
                                        title: Text("已送出")
                                    )
                            }
                        Spacer()
                        if(commentText != ""){
                            Button(action: {
                                commentAlertText = sendComment(docID: article.id)
                                commentAlert.toggle()
                                viewModel.getComment(articleID: article.id)
                                
                            }, label: {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 45, height: 45)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            })
                            .alert(isPresented: $commentAlert){ () -> Alert in
                                print("comment alert")
                                
                                    return Alert(
                                        title: Text(commentAlertText)
                                    )
                            }
                            
                        }
                            
                    }
                    .padding()
                    
                }
            }
        }

    }
    func handleDelete(docID: String){
        print("delete post: " + docID)
        self.showAlert = true
        viewModel.delPost(docID: docID)
    }
    
    func decideDivider(writerID: Int)-> Int{
        if(writerID == currentUserID){
            return 3
        }
        return 1
    }
    
    func sendComment(docID: String) -> String{
        print("send comment")
        let result = viewModel.sendComment(articleID: docID, content: commentText)
        
        print("send comment: \(result)")
        
        return "Comment Success"
    }
    
    func testPlay(audioName: String){
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("test.m4a")
        do{
            print("local url: \(localURL)")
            audioPlayer = try AVAudioPlayer(contentsOf: localURL)
            audioPlayer.play()
        }
        catch{
            print("error")
        }
    }
    
    func getAudio(audioName: String){
        
        let storage = Storage.storage()
        
        // Create a root reference
        let storageRef = storage.reference()
        let fileRef = storageRef.child("audio/\(audioName)")
        
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(audioName)

        // Download to the local filesystem
        let _ = fileRef.write(toFile: localURL) { url, error in
          if let error = error {
            print(error)
          } else {
            // device's local file system
            print("url: \(url!)")
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: url!, fileTypeHint: AVFileType.m4a.rawValue)
                print("play")
                audioPlayer.play()
            }
            catch{
                print(error)
            }
          }
        }

    }
    
    func audioDelete(docID: String){
        let storage = Storage.storage()

        // Create a root reference
        let storageRef = storage.reference()

        // Create a reference to the file you want to upload
        let audioRef = storageRef.child("audio/\(docID).m4a")
        audioRef.delete{ error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("audio delete error: \(error)")
              } else {
                // File deleted successfully
                print("audio delete success")
              }
        }
    }
}



struct PostEnableEditView: View{
    var article: Article
    var viewModel: PostModel
   
    @State var screenSpace = 20
    @State private var showAlert = false
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            Text(article.title)
                .font(.title).bold()
            Text(String(article.id))
                .font(.footnote)

            Text(article.content)
                .padding([.top, .leading], 10)
                .frame(width: UIScreen.screenWidth - CGFloat(screenSpace) * 2, height: 400, alignment: .topLeading)
                .background(Color(red: 1, green: 1, blue: 1))
                .cornerRadius(20)

            Spacer()
            
        }
        .frame(minWidth: 300, idealWidth: 300, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 400, idealHeight: .infinity, maxHeight: .infinity, alignment: .leading)
        
        .padding(.leading, CGFloat(screenSpace))
        
        .navigationBarItems(
            trailing:
                HStack{
                    Button(action: {  }){
                        Text("編輯")
                    }
                    Button(action: { handleDelete(docID: article.id, type: article.type) }){
                        Text("刪除")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showAlert){ () -> Alert in
                        print("alert")
                            return Alert(
                                title: Text("成功刪除，請回上一頁")
                            )
                    }
                }
                
        )
        .offset(y: 90)
    }
    
    func handleDelete(docID: String, type: String){
        print("delete post: " + docID)
        self.showAlert = true
        viewModel.delPost(docID: docID)
 
        if(type == "audio"){
            audioDelete(docID: docID)
        }
    }
    func audioDelete(docID: String){
        let storage = Storage.storage()

        // Create a root reference
        let storageRef = storage.reference()

        // Create a reference to the file you want to upload
        let audioRef = storageRef.child("audio/\(docID).m4a")
        audioRef.delete{ error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("audio delete error")
              } else {
                // File deleted successfully
                print("audio delete success")
              }
        }
        
    }
}

struct CommentRow: View{
    var imgName: String
    var name: String
    var content: String
    var time: String
    var writer: Bool
    var body: some View{
        HStack{
            if(writer != true){
                VStack{
                    Image(imgName)
                        .resizable()
                        .frame(width: 45, height: 45, alignment: .center)
                        .cornerRadius(40)
                    Text(name)
                        .font(.system(size: 10))
                }
            }
            else{
                Spacer()
            }
            
            VStack{
                Text(content)
                    .padding(10)
                    .padding(.leading, 10)
                    .frame(minWidth: 100, alignment: .leading)
                    .background(Color.white.opacity(0.8))
//                    .background(Color.yellow)
    //                .cornerRadius(10)
                    .font(.system(size: 15))
                    .clipShape(Bubble(chat: writer))
//                    .padding(.bottom, 20)
                    
//                Spacer()
                Text(time)
                    .font(.system(size: 10))
                    .frame(alignment: .leading)
            }
            if(writer){
                VStack{
                    Image(imgName)
                        .resizable()
                        .frame(width: 45, height: 45, alignment: .center)
                        .cornerRadius(40)
                    Text(name)
                        .font(.system(size: 10))
                }
            }
            else{
                Spacer()
            }
        }
    }
}

struct Bubble: Shape{
    var chat: Bool
    
    func path(in rect: CGRect) -> Path{
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .topLeft, chat ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        
        return Path(path.cgPath)
    }
}

struct PostDetail_Previews: PreviewProvider {
    static var previews: some View {
        PostDetail(article: test)
//        PostEnableEditView(article: test, viewModel: PostModel())
        CommentRow(imgName: "penguin", name: "test", content: "hello", time: "2020.04.01", writer: false)
    }
}
