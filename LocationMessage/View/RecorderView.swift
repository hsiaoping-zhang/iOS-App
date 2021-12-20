//
//  RecorderView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/5/1.
//

import SwiftUI
import AVFoundation
import FirebaseStorage
import MapKit

struct RecorderView: View {
    let bgColor = Color(red: 223.0/255, green: 201.0/255, blue: 181.0/255)
    @State var alert = false
    @State var record = false
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var iconName = "play.fill"
    @State var fileName = ""
    
    @StateObject var postModel = PostModel()
    @ObservedObject private var audioManger = AudioManager()
    @State var manager = CLLocationManager()
    @StateObject var managerDelegate = locationDelegate()
    
    @State var showText = "開始錄音!!"
    
    var body: some View {

        VStack{
            HStack{
                Text("標題")
                    .font(.system(size: 25))
                TextField("", text: $postModel.post.title)
                    .font(.system(size: 25))
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.trailing, 5)
                    
            }
            .padding(.top, 5)
            
            Image("bg-2")
                .resizable()
                .scaledToFit()
            
            Text("Info: \(showText)")
                .foregroundColor(.black)
                .frame(width:200, height: 20, alignment: .leading)
            
            HStack{
                // record
                Button(action: {
                    startRecord()
                }, label: {
                    ZStack{
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: iconName)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            
                    }
                })
                .alert(isPresented: self.$alert, content: {
                    Alert(title: Text("ERROR"), message: Text("Enable Access"))
                })
                .onAppear{
                    do{
                        session = AVAudioSession.sharedInstance()
                        try session.setCategory(.playAndRecord)
                        
                        session.requestRecordPermission{ (status) in
                            if !status{
                                self.alert.toggle()
                            }
                            else{
                                _ = audioManger.getAudios(name: "")
                            }
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
                
                Button(action: {
                    uploadToStorage()
                }, label: {
                    Text("上傳")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                        .frame(width:200)
                        .background(Color.yellow)
                        .cornerRadius(10)
                })
                
                Button(action: {
                    
                }, label: {
                    Text("刪除")
                })
            }
            .padding(.bottom, 10)
            .foregroundColor(.black)
            
        }
        .frame(width: UIScreen.screenWidth*0.8, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .padding()
        .background(bgColor)
        .cornerRadius(20)
        .onAppear{
            manager.delegate = managerDelegate
        }
    }
    
    func startRecord(){
        do{
            // record -> stop
            if(record){
                self.recorder.stop()
                self.record.toggle()
                showText = "錄音完成"
                iconName = "stop.fill"
                
                return
            }
            
            // prepare to record
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileName = getRandomString(length: 20) + ".m4a"
            let fileName = url.appendingPathComponent(self.fileName)
            print(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recorder = try AVAudioRecorder(url: fileName, settings: settings)
            recorder.record()
            record.toggle()
            iconName = "waveform.circle.fill"
            showText = "錄音中..."
            
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func uploadToStorage(){
        
        let storage = Storage.storage()
        
        // Create a root reference
        let storageRef = storage.reference()
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(self.fileName)
        
        // File located on disk
        let localFile = URL(string: filePath.absoluteString)!
        print("absolute string: \(localFile)")
        
        let riversRef = storageRef.child("audio/\(self.fileName)")

        // Upload the file to the path ""
        _ = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            print("upload to storage")
            guard metadata != nil else {
                // Uh-oh, an error occurred!
                print("error")
                print(error?.localizedDescription)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                recorder.deleteRecording()
                print("delete success")
            }
        }
        
        // upload to firestore as article type
        postModel.post.type = "audio"
        postModel.post.writerID = currentUserID
        print("check: \(currentUserID)")
        postModel.post.content = self.fileName
        postModel.save(lat: managerDelegate.currentUserLatitude, lon: managerDelegate.currentUserLogitude)
        
    }
}

struct RecorderView_Previews: PreviewProvider {
    static var previews: some View {
        RecorderView()
    }
}
