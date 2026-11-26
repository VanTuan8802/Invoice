//
//  IntroPage.swift
//  Invoice
//
//  Created by VanTuan on 18/6/26.
//

import SwiftUI

/// One page of the onboarding intro carousel (Onboarding/Intro 1–4).
struct IntroPage: Identifiable {
    let id: Int
    /// Hero artwork (lavender / blue / pink / orange block with the phone mockup).
    let image: RswiftResources.ImageResource
    /// Resolved on every call (not stored) so the text follows the in-app
    /// language when it changes at runtime.
    let title: () -> String
    let message: () -> String

    /// The four slides shown in order.
    static let all: [IntroPage] = [
        IntroPage(
            id: 0,
            image: R.image.img_onboarding_intro_1,
            title: { R.stringLocalizable.onboarding_intro_title_1() },
            message: { R.stringLocalizable.onboarding_intro_message_1() }
        ),
        IntroPage(
            id: 1,
            image: R.image.img_onboarding_intro_2,
            title: { R.stringLocalizable.onboarding_intro_title_2() },
            message: { R.stringLocalizable.onboarding_intro_message_2() }
        ),
        IntroPage(
            id: 2,
            image: R.image.img_onboarding_intro_3,
            title: { R.stringLocalizable.onboarding_intro_title_3() },
            message: { R.stringLocalizable.onboarding_intro_message_3() }
        ),
        IntroPage(
            id: 3,
            image: R.image.img_onboarding_intro_4,
            title: { R.stringLocalizable.onboarding_intro_title_4() },
            message: { R.stringLocalizable.onboarding_intro_message_4() }
        )
    ]
}
