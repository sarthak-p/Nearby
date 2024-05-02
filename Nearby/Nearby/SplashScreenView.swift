//
//  SplashScreenView.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 5/2/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            ContentView()  // This transitions to your main ContentView
        } else {
            VStack {
                Image("Icon")  // Make sure the image is added to your asset catalog
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text("Epic App")
                    .font(Font.custom("Baskerville-Bold", size: 26))
                    .foregroundColor(.white)  // Lighter text color for better visibility
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 0.9
                    self.opacity = 1.00
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // Make VStack fill the screen
            .background(Color(#colorLiteral(red: 3/255, green: 39/255, blue: 68/255, alpha: 1)))  // Custom dark bluish-green background color
            .edgesIgnoringSafeArea(.all)  // Let the background extend to the edges of the display
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}

