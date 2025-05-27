//
//  DonationProgressView.swift
//  BlessingChannel
//
//  Created by 김동준 on 5/26/25.
//

import Foundation
import SwiftUI

struct DonationProgressView: View {
    let current: Int
    let goal: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text("현재 모금액: \(current)원 / \(goal)원")
                .fontWeight(.bold)
                .foregroundColor(.brown)

            ProgressView(value: Float(current) / Float(goal))
                .progressViewStyle(LinearProgressViewStyle(tint: .brown))
        }
        .padding()
    }
}
