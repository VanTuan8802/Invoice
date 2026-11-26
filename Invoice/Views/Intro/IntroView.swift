//
//  IntroView.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI
import ads_swift

/// Onboarding/Intro 1–4 (+ "With Ad" variants): swipeable hero artwork on top,
/// white bottom sheet with the page copy, page dots and Next / Start. When a
/// native ad is loaded for the page it sits at the bottom of the sheet and the
/// hero shrinks to make room (the "With Ad" frames).
struct IntroView: View {
    @EnvironmentObject private var coordinator: AppFlowCoordinator
    @State private var index = 0

    private let pages = IntroPage.all
    private var isLast: Bool { index == pages.count - 1 }

    @State private var nativeIntro1VM: NativeAdViewModel?
    @State private var nativeIntro3VM: NativeAdViewModel?

    #if DEBUG
    init() {
        // `-uiPreviewIntroPage <1…4>` opens the carousel on that page.
        let arguments = ProcessInfo.processInfo.arguments
        if let i = arguments.firstIndex(of: "-uiPreviewIntroPage"), i + 1 < arguments.count,
           let page = Int(arguments[i + 1]), (1...IntroPage.all.count).contains(page) {
            _index = State(initialValue: page - 1)
        }
    }
    #endif

    /// Existing placements only: `nativeIntro1` on page 1, `nativeIntro3` on page 3.
    private var currentAdVM: NativeAdViewModel? {
        switch index {
        case 0:  return nativeIntro1VM
        case 2:  return nativeIntro3VM
        default: return nil
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            TabView(selection: $index) {
                ForEach(pages) { page in
                    hero(page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            sheet
        }
        .background(Color(R.color.colorF4F4F6).ignoresSafeArea())
        .onAppear { loadAds() }
        .trackScreen(.intro)
    }

    // MARK: - Hero

    /// 361pt-wide rounded block; top-aligned so a shorter frame (ad showing)
    /// crops the bottom of the artwork like the "With Ad" frames.
    private func hero(_ page: IntroPage) -> some View {
        Color.clear
            .overlay(alignment: .top) {
                Image(page.image)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            .padding(.horizontal, 16)
    }

    // MARK: - Bottom sheet

    private var sheet: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(pages[index].title())
                    .font(.title2.bold())
                    .foregroundStyle(Color(R.color.color111118))
                    .opacity(0.8)
                Text(pages[index].message())
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color6B6B78))
                    .frame(maxWidth: 300)
                    .frame(minHeight: 60, alignment: .top)
            }
            .multilineTextAlignment(.center)
            // Never truncate the copy; the hero above gives up the space instead.
            .fixedSize(horizontal: false, vertical: true)
            .id(index)
            .transition(.opacity)
            .padding(.horizontal, 32)
            .padding(.top, 24)

            VStack(spacing: 16) {
                pageIndicator
                nextButton
            }
            .padding(.top, 28)
            .padding(.bottom, currentAdVM == nil ? 6 : 0)

            if let vm = currentAdVM {
                NativeContentView(nativeViewModel: vm, style: .nativeNormalMediaCtaBottom)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            TopRoundedRectangle(radius: 32)
                .fill(Color(R.color.colorFFFFFF))
                .ignoresSafeArea(edges: .bottom)
        )
        .gesture(pageSwipe)
        .animation(.easeInOut(duration: 0.25), value: index)
    }

    /// 20×8 ink pill for the current page, 8pt grey dots for the others.
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? Color(R.color.color111118) : Color(R.color.colorC7C7CC))
                    .frame(width: i == index ? 20 : 8, height: 8)
            }
        }
    }

    /// 112×44 ink capsule ("Next", "Start" on the last page).
    private var nextButton: some View {
        Button {
            if isLast {
                coordinator.introDidFinish()
            } else {
                withAnimation { index += 1 }
            }
        } label: {
            Text(isLast ? R.stringLocalizable.onboarding_intro_start() : R.stringLocalizable.next())
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(R.color.colorFFFFFF))
                .frame(width: 112, height: 44)
                .background(Capsule().fill(Color(R.color.color111118)).buttonElevation())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    /// Lets the user page by swiping on the sheet too (the hero pages natively).
    private var pageSwipe: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > abs(value.translation.height) else { return }
                withAnimation {
                    if dx < 0, index < pages.count - 1 { index += 1 }
                    if dx > 0, index > 0 { index -= 1 }
                }
            }
    }

    // MARK: - Ads

    /// Load both intro placements up front so they're ready as the user pages.
    private func loadAds() {
        let c1 = AdUtil.config.nativeIntro1
        if c1.isEnable, nativeIntro1VM == nil {
            let vm = NativeAdViewModel(adUnitID: c1.id)
            vm.refreshAd()
            nativeIntro1VM = vm
        }
        let c3 = AdUtil.config.nativeIntro3
        if c3.isEnable, nativeIntro3VM == nil {
            let vm = NativeAdViewModel(adUnitID: c3.id)
            vm.refreshAd()
            nativeIntro3VM = vm
        }
    }
}

#if DEBUG
#Preview {
    IntroView()
        .environmentObject(AppFlowCoordinator())
}
#endif
