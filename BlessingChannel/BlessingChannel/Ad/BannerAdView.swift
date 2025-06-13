//
//  BannerAdView.swift
//  BlessingChannel
//
//  Created by 김동준 on 6/1/25.
//

import Foundation
import GoogleMobileAds
import SwiftUI
import GoogleMobileAds
import SwiftUI

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)

        // ✅ 광고 ID 설정 (DEBUG/RELEASE 분기)
        let adUnitID: String = {
        #if DEBUG
            return "ca-app-pub-3940256099942544/2934735716" // 테스트용 배너 광고 ID
        #else
            return "ca-app-pub-2190585582842197/7374412737" // 실제 배너 광고 ID 입력
        #endif
        }()

        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(Request())
        return banner
    }


    func updateUIView(_ uiView: BannerView, context: Context) {}
}

