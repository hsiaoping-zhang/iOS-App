//
//  AudioManager.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/5/1.
//

import Foundation
import AVFoundation
import SwiftSocket

class AudioManager: ObservableObject{
    
    var record = false
    var session: AVAudioSession!
    var recorder: AVAudioRecorder!
    
    var audios: [URL] = []
    var names: [String] = []
    
    func uploadFileToServer(fileUrl: URL) -> String{
        if FileManager.default.fileExists(atPath: fileUrl.path)
        {
            //金鑰
            let token:String="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJpZCI6NzgsInVzZXJfaWQiOiIwIiwic2VydmljZV9pZCI6IjMiLCJzY29wZXMiOiI5OTk5OTk5OTkiLCJzdWIiOiIiLCJpYXQiOjE1NDEwNjUwNzEsIm5iZiI6MTU0MTA2NTA3MSwiZXhwIjoxNjk4NzQ1MDcxLCJpc3MiOiJKV1QiLCJhdWQiOiJ3bW1rcy5jc2llLmVkdS50dyIsInZlciI6MC4xfQ.K4bNyZ0vlT8lpU4Vm9YhvDbjrfu_xuPx8ygoKsmovRxCCUbj4OBX4PzYLZxeyVF-Bvdi2-wphGVEjz8PsU6YGRSh5SDUoHjjukFesUr8itMmGfZr4BsmEf9bheDm65zzbmbk7EBA9pn1TRimRmNG3XsfuDZvceg6_k6vMWfhQBA"
            //選用模組,之後有針對醫療詞彙加強會更改main的字串
            let data:String = token+String("@@@main    A")
            
            do{
                //音檔
                let audioData = try Data(contentsOf: fileUrl)
                let mydata = Data(data.utf8) + audioData
                //**data count要用big endian並大小為4bytes
                var count = UInt32(mydata.count).bigEndian
                let datacount = Data(bytes: &count, count: 4)
                
                let client = TCPClient(address: "140.116.245.149", port: 2802)
                switch client.connect(timeout: 5) {
                case .success:
                    switch client.send(data : datacount+mydata) {
                    case .success:
                        guard let data = client.read(1024,timeout: 10) else { return "X" }

                        if let response = String(bytes: data, encoding: .utf8) {
                            let splitarray = response.components(separatedBy: "result:")
                            
                            //輸出
                            print("responseString = \(String(describing: splitarray[0]))")
                            return String(describing: splitarray[0])
    //                        textchange(text: splitarray[0],sender: sender.tag)
    //                        sender.isEnabled = true
                        }
                    case .failure(let error):
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }catch{
                print("error")
            }
        }
        else{
    //        display_alert(msg_title: "Error", msg_desc: "Audio file has not been recorded yet!", action_title: "OK")
            print("Audio file has not been recorded yet!")
        }
        
        return "X"
    }
    
    func getAudios(name: String)-> String{
        do{
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            // update with remove all old file
            self.audios.removeAll()
            
            for item in result{
                if(item.absoluteString.contains(name)){
                    return item.absoluteString
                }
//                self.audios.append(i)
            }
        }
        catch{
            print(error.localizedDescription)
        }
        return ""
    }
}



