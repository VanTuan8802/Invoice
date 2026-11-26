//
//  DefaultEmailMessageScreen.swift
//  Invoice
//
//  Settings/Default Email Message: the message pre-filled when emailing a
//  document. Stored in `@AppStorage(SettingsStorage.Key.defaultEmailMessage)`.
//

import SwiftUI
import Factory

struct DefaultEmailMessageScreen: View {
    @Injected(\.app) private var app

    @AppStorage(SettingsStorage.Key.defaultEmailMessage) private var storedMessage = ""
    @State private var message = ""
    @State private var didLoad = false

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_default_email(),
                            showBack: true,
                            backAction: { app.navi.pop() }) {
                HeaderTextButton(title: R.stringLocalizable.save(), action: save)
            }

            Form {
                Section {
                    TextField("",
                              text: $message,
                              prompt: settingsPrompt(R.stringLocalizable.settings_default_email()),
                              axis: .vertical)
                        .font(.subheadline)
                        .foregroundStyle(Color(R.color.color111118))
                        .lineLimit(4...12)
                        .frame(minHeight: 80, alignment: .top)
                        .padding(.vertical, 4)
                } header: {
                    SettingsCaption(text: R.stringLocalizable.settings_message_to_customer())
                }
            }
            .settingsFormStyle()
        }
        .groupedScreenBackground()
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            message = storedMessage
        }
        .trackScreen(.settingsDefaultEmail)
    }

    private func save() {
        storedMessage = message
        app.navi.pop()
    }
}

#if DEBUG
#Preview {
    DefaultEmailMessageScreen()
}
#endif
