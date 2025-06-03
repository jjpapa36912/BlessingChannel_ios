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
        let banner = BannerView(adSize: AdSizeBanner) // ✅ 최신 이름 사용
        banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // 테스트용 ID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

