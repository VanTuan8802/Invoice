//
//  DocumentHistoryTab.swift
//  Invoice
//
//  "History" tab of the editor (Invoice/History + Empty, Estimate/History) and the
//  one-time notification prompt (History/Notification Prompt).
//

import SwiftUI
import Factory
import UserNotifications

struct DocumentHistoryTab: View {
    /// Set to show the notification prompt (drawn by the editor over the whole screen).
    @Binding var showPrompt: Bool
    /// "+" on the empty state: start a new document of the same kind.
    let onCreate: () -> Void

    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.documentHistory) private var history: DocumentHistoryLog

    @AppStorage("document.notificationPromptShown") private var promptShown = false

    private var entries: [DocumentHistoryEntry] { history.entries(for: editor.document) }

    var body: some View {
        Group {
            if entries.isEmpty {
                DocumentEmptyStateView(
                    image: R.image.illus_history,
                    tile: Color(R.color.colorE8EBFF),
                    title: R.stringLocalizable.doc_history_empty_title(),
                    message: editor.document.kind.emptyMessage
                )
                .floatingActionButton(action: onCreate)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(entries) { entry in
                            row(entry)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 1)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: offerNotifications)
        .trackScreen(.documentHistory)
    }

    private func row(_ entry: DocumentHistoryEntry) -> some View {
        HStack(spacing: 12) {
            Image(R.image.ic_document_mail_fast)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.event.title)
                    .font(.subheadline)
                    .foregroundStyle(Color(R.color.color111118))
                Text(R.stringLocalizable.doc_history_timestamp(entry.date.numericDateText, entry.date.timeWithSecondsText))
                    .font(.footnote)
                    .foregroundStyle(Color(R.color.color6B6B78))
            }
            Spacer(minLength: 0)
        }
        .cardSurface(cornerRadius: 24)
    }

    /// Shows the prompt once, the first time there is history to be notified about.
    private func offerNotifications() {
        guard !promptShown, !entries.isEmpty else { return }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            DispatchQueue.main.async {
                promptShown = true
                withAnimation { showPrompt = true }
            }
        }
    }
}
