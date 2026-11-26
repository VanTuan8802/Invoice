//
//  NotificationPromptView.swift
//  Invoice
//
//  History/Notification Prompt: "Allow notifications?" card over a dimmed editor,
//  with the phone mockup and a (decorative) notifications switch.
//

import SwiftUI

struct NotificationPromptView: View {
    let onContinue: () -> Void
    let onLater: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    Text(R.stringLocalizable.doc_notification_title())
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(R.color.color111118))
                    Text(R.stringLocalizable.doc_notification_message())
                        .font(.subheadline)
                        .foregroundStyle(Color(R.color.color6B6B78))
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: 257)

                ZStack(alignment: .topLeading) {
                    Image(R.image.img_document_notification_phone)
                        .resizable()
                        .frame(width: 339, height: 302)
                    notificationRow
                        .frame(width: 319)
                        .offset(x: 10, y: 120)
                }
                .frame(width: 339, height: 302)
                .padding(.top, 3)
                .accessibilityHidden(true)

                VStack(spacing: 0) {
                    PrimaryButton(R.stringLocalizable.continue(), action: onContinue)
                    Button(action: onLater) {
                        Text(R.stringLocalizable.doc_later())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(R.color.color6B6B78))
                            .frame(maxWidth: .infinity)
                            .frame(height: 47)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 266)
                // The buttons sit on the mockup's faded bottom edge.
                .padding(.top, -50)
            }
            .padding(.top, 20)
            .padding(.bottom, 12)
            .padding(.horizontal, 11)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(R.color.colorFFFFFF))
            )
        }
    }

    private var notificationRow: some View {
        HStack(spacing: 12) {
            Image(R.image.ic_document_bell)
            Text(R.stringLocalizable.doc_notification_row())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(R.color.color111118))
                .lineLimit(1)
            Spacer(minLength: 8)
            Toggle(R.stringLocalizable.doc_notification_row(), isOn: .constant(true))
                .labelsHidden()
                .tint(Color(R.color.color111118))
                .allowsHitTesting(false)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(R.color.colorFFFFFF))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(Color(R.color.color111118), lineWidth: 1.5)
        )
    }
}
