//
//  CellularAutomataIntro.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/20/25.
//

import SwiftUI

struct CellularAutomataIntro: View {
        
    var body: some View {
        Text("Cellular Automata Intro")
        
        
        
        HStack {
            Button("Reset") {
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            NavigationLink(destination: VoronoiCellView()) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
   
    
}


#Preview {
    CellularAutomataIntro()
}
