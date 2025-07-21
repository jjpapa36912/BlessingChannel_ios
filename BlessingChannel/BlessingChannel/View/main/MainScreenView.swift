import SwiftUI

struct MainScreenView: View {
    @State private var activeHelper: HelperType? = nil

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerView()
                    helperButtonListView()
                    Spacer()
                }
                .padding(.top, 48)
            }

            if let type = activeHelper {
                helperOverlayView(for: type)
            }
        }
        // ✅ 하단 배너 광고 고정
            BannerAdView()
                .frame(height: 50)
                .background(Color.clear)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Header View
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BlessingChannel")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.blue)

            Text("원하는 작업을 선택해주세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Helper Buttons
    @ViewBuilder
    private func helperButtonListView() -> some View {
        ForEach(HelperType.allCases, id: \.self) { type in
            Button {
                withAnimation { activeHelper = type }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(type.instruction)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground)) // 자동 다크모드 대응
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                        .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1) // ⭐ 테두리 추가
                                )
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helper Modal
    @ViewBuilder
    private func helperOverlayView(for type: HelperType) -> some View {
        Color.black.opacity(0.2)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation { activeHelper = nil }
            }

        VStack {
            UniversalHelperView(
                isPresented: Binding(
                    get: { activeHelper != nil },
                    set: { if !$0 { activeHelper = nil } }
                ),
                helperType: type
            )
            .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
        .transition(.move(edge: .bottom))
    }
}
