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
            Text("누적 참여 기록: \(current)❤️ / \(goal)❤️")
                .fontWeight(.bold)
                .foregroundColor(.brown)

            ProgressView(value: Float(current) / Float(goal))
                .progressViewStyle(LinearProgressViewStyle(tint: .brown))
        }
        .padding()
    }
}
