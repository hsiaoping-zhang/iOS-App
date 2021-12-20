//
//  LoginView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/12.
//

import SwiftUI


struct LoginView: View {
    @State var userIDString: String = ""
    @State var userName: String = "user-"
    
    @Binding var signInSuccess: Bool

    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .frame(width: 200, height: 200, alignment: .center)
            
            Text("Enter")
                .font(.largeTitle).bold()

            TextField("User ID", text: $userIDString)
                .padding()
                .background(RoundedRectangle(cornerRadius: 4).stroke(self.userName != "" ? Color.red : Color.gray, lineWidth: 2))
                .padding(.top, 20)
                .font(.system(size: 20))
            
            HStack{
                if(userIDString != ""){
                    Text("User Name : user-\(userIDString)")
                        .foregroundColor(.gray)
                   
                }
                else{
                    Text("User Name : ")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
//                .frame(width: UIScreen.screenWidth-20, alignment: .leading)

//            TextField("User Name", text: "user-" + $userIDString)
//                .padding()
//                .background(RoundedRectangle(cornerRadius: 4).stroke(self.userName != "" ? Color.red : Color.gray, lineWidth: 2))
//                .padding(.top, 20)
//                .font(.system(size: 20))
            
            Button(action:{
                if(userIDString != ""){
                    self.signInSuccess = true
                    // get user id
//                    currentUserID = Int(userName) as? Int ?? 0
                    currentUserID = Int(userIDString) ?? 0
                    currentUserName = userName + String(currentUserID)
                }
                else{
                    
                }
                
            }){
                Text("Log in")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .background(Color.red)
            .cornerRadius(10)
            .padding(.top, 25)
            
            Spacer()
                    

        }.padding(.horizontal, 25)
        .padding([.leading, .trailing], 20)
        .frame(width: UIScreen.screenWidth-20, height: UIScreen.screenHeight*0.4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
}
//
//struct LoginView_Previews: PreviewProvider {
////    @Binding var test: Bool = false
//    static var previews: some View {
//        LoginView(signInSuccess: false)
////        LoginView(signInSuccess: test)
//    }
//}
