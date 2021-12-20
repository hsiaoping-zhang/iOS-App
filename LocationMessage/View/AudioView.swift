//
//  AudioView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/13.
//

import SwiftUI
import AVKit
import FirebaseFirestore
import FirebaseStorage


struct AudioView: View {
    
    var body: some View {
        HomeView()
//            .preferredColorScheme(.dark)
    }
}

struct HomeView: View {
    
    @State var alert = false
    @ObservedObject private var audioManger = AudioManager()
    
    @State var showText = "Start Record"
    @State var returnText = "[]"
    @State var iconName = "play.circle.fill"
    @State var currentAudioName = ""
    @State var uploadName = ""
    
    var body: some View {
        VStack{
            
            
            Image("bg-1")
                .resizable()
                .frame(width:UIScreen.screenWidth*0.85)
                .scaledToFit()
            
            Text("Info: \(showText)")
                .foregroundColor(.blue)
                .frame(width:200, height: 20, alignment: .leading)
            
            
            HStack{
                // play, stop button
                Button(action: {
                    clickButton()
                }){
                    ZStack{
                        
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .cornerRadius(25)
                            .padding(3)

                        Image(systemName: iconName)
                            .resizable()
                            .foregroundColor(showText == "Upload" ? .gray : Color(red: 129.0/255, green: 197.0/255, blue: 250.0/255))
                            .frame(width: 40, height: 40)
                            .cornerRadius(25)
                            .padding(3)
                        
                        if(audioManger.record){
                            Circle()
                                .stroke(showText == "Upload" ? Color.gray : Color(red: 129.0/255, green: 197.0/255, blue: 250.0/255), lineWidth: 3)
                                .frame(width: 50, height: 50)
                        }
                    }

                }
                .disabled(showText == "Upload")
                .alert(isPresented: self.$alert, content: {
                    Alert(title: Text("ERROR"), message: Text("Enable Access"))
                })
                .onAppear{
                    do{
                        audioManger.session = AVAudioSession.sharedInstance()
                        try audioManger.session.setCategory(.playAndRecord)
                        
                        audioManger.session.requestRecordPermission{ (status) in
                            if !status{
                                self.alert.toggle()
                            }
                            else{
                                uploadName = audioManger.getAudios(name: currentAudioName)
                                print("get audio name: \(uploadName)")
                            }
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
                
                // upload
                Button(action:{
                    print("click: upload audio: \(currentAudioName)")
                    self.uploadAudio()
                    showText = "Upload"
                }){
                    Text("Upload")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black)
                        .frame(width: 100, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(Color(red: 129.0/255, green: 197.0/255, blue: 250.0/255))
                        .cornerRadius(40)
                }
                .disabled(showText == "Upload")

                Button(action:{
                    print("Cancel")

                    showText = "Delete"
                }){
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black)
                        .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(Color(red: 129.0/255, green: 197.0/255, blue: 250.0/255))
                        .cornerRadius(40)
                }
            }

            Text(returnText)
                .frame(width: UIScreen.screenWidth*0.7, height: 40)
                .truncationMode(.tail)
           
        }
        
        .frame(height: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .padding()
        .background(Color(red: 201.0/255, green: 221.0/255, blue: 216.0/255))
        .cornerRadius(20)

    }
    
    func clickButton(){
        do{
            if(audioManger.record){
                audioManger.recorder.stop()
                audioManger.record.toggle()
//                audioManger.getAudios()
                showText = "Finish"
                iconName = "repeat.circle.fill"
                return
            }
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let name = getRandomString(length: 20) + ".m4a"
            audioManger.names.append(name)
            currentAudioName = name
            
            let fileName = url.appendingPathComponent(name)
            print(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioManger.recorder = try AVAudioRecorder(url: fileName, settings: settings)
            
            audioManger.recorder.record()
            audioManger.record.toggle()
            iconName = "waveform.circle.fill"
            showText = "Recording"
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func uploadAudio(){
        
        let storage = Storage.storage()

        // Create a root reference
        let storageRef = storage.reference()
        
        // File located on disk
        let localFile = URL(string: uploadName)!
        print("absolute string: \(uploadName)")
        

        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("audio/\(currentAudioName)")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("error")
                print(error?.localizedDescription)
                return
            }
            
            returnText = audioManger.uploadFileToServer(fileUrl: localFile)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                audioManger.recorder.deleteRecording()
                print("delete success")
            }

        }
    }
}

struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        AudioView()
    }
}
