//
//  RewardedAdManager.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/1/25.
//

import Foundation
import GoogleMobileAds
import SwiftUI

class RewardedAdManager: NSObject, FullScreenContentDelegate, ObservableObject {
    private var rewardedAd: RewardedAd?
    @Published var isAdLoaded = false

    func loadAd() {
        let request = Request()
        RewardedAd.load(
            with: "ca-app-pub-3940256099942544/1712485313",       // ✅ Ad Unit ID
            request: Request(),               // ✅ 광고 요청 객체
            completionHandler: { ad, error in
            if let error = error {
                print("❌ 보상형 광고 로드 실패: \(error.localizedDescription)")
                self.isAdLoaded = false
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            self.isAdLoaded = true
            print("✅ 보상형 광고 로드 완료")
        })
    }

    func showAd(from rootVC: UIViewController, onReward: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("⚠️ 광고가 아직 로드되지 않았습니다.")
            return
        }

        ad.present(
            from: rootVC,
            userDidEarnRewardHandler: {
                print("🎁 보상 지급됨")
                onReward()
            }
        )
    }

}
