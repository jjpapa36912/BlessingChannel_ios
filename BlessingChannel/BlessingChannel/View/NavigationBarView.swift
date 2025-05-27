//
//  NavigationBarView.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/26/25.
//

import Foundation
import SwiftUI

struct NavigationBarView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "house.fill")
            Spacer()
            Image(systemName: "ellipsis")
            Spacer()
            Image(systemName: "gearshape")
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.5))
    }
}
