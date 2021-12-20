//
//  TestView.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/5/7.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        List([1, 2, 3], id: \.self) { row in
            HStack {
                Button(action: { print("Button at \(row)") }) {
                    Text("Row: \(row) Name: A")
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: { print("Button at \(row)") }) {
                    Text("Row: \(row) Name: B")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
