//
//  CustomLoginButton.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/26/25.
//

import Foundation
import SwiftUI

struct CustomLoginButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(Color(hex: "#6B3E26"))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FFEB85"))
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
        }
        .frame(height: 45)
    }
}
