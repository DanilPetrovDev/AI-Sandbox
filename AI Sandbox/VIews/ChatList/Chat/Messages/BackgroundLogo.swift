//
//  BackgroundLogo.swift
//  GPT Sandbox
//
//  Created by Yami on 7/6/23.
//

import SwiftUI

struct BackgroundLogo: View {
    var body: some View {
        ZStack (alignment: .center) {
            VStack {
                Image(systemName: "hand.tap.fill")
                    .font(.title)
                    .padding(5)
                
                Spacer()
            }
            
//            Text("Tap to edit chat settings")
            
            Text("GPT\nSandbox")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.gray)
    }
}

//struct BackgroundLogo_Previews: PreviewProvider {
//    static var previews: some View {
//        BackgroundLogo()
//    }
//}
