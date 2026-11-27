//
//  DocumentEditorScreen.swift
//  Invoice
//
//  Invoice/Edit, Estimate/Edit: one editor for both kinds with the Edit / Preview /
//  History segmented control, backed by the shared `DocumentEditor`. Also hosts the
//  "…" actions sheet (History/Actions), Invoice/Mark As Paid and Invoice/Share.
//

import SwiftUI
import Factory
import UserNotifications

enum DocumentEditorTab: String, Hashable, CaseIterable, Identifiable {
    case edit
    case preview
    case history

    var id: String { rawValue }

    var title: String {
        switch self {
        case .edit:    return R.stringLocalizable.common_edit()
        case .preview: return R.stringLocalizable.doc_tab_preview()
        case .history: return R.stringLocalizable.doc_tab_history()
        }
    }
}

struct DocumentEditorScreen: View {
    /// Which document to open.
    enum Source: Hashable {
        /// Stored document, or a new one when `id == nil` (`DocumentEditor.begin`).
        case document(DocumentKind, id: UUID?)
        /// Whatever `DocumentEditor` already holds (Mark As Paid / Share routes).
        case current
        /// First stored document of the kind (debug previews).
        case firstStored(DocumentKind)
    }

    /// Overlay to present right after opening.
    enum StartAction {
        case none
        case share
        case markPaid
    }

    let source: Source
    var initialTab: DocumentEditorTab = .edit
    var startAction: StartAction = .none

    @InjectedObject(\.documentEditor) private var editor: DocumentEditor
    @InjectedObject(\.dataStore) private var store: DataStore
    @Injected(\.app) private var app
    @StateObject private var model = DocumentEditorViewModel()

    @State private var tab: DocumentEditorTab = .edit
    @State private var didStart = false
    @State private var showValidation = false
    @State private var showActions = false
    @State private var showShareMenu = false
    @State private var showMarkPaid = false
    @State private var showDeleteAlert = false
    @State private var showMissingInfo = false
    @State private var shareText: SharedText?
    @State private var showNotificationPrompt = false

    private var kind: DocumentKind { editor.document.kind }

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(kind.title, showBack: true, backAction: close, trailingView: {
                HeaderIconButton(systemImage: "ellipsis") { showActions = true }
            })

            Picker(R.stringLocalizable.doc_tab_preview(), selection: $tab) {
                ForEach(DocumentEditorTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .controlSize(.large)
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 8)

            content
        }
        .groupedScreenBackground()
        .blur(radius: showShareMenu || showNotificationPrompt ? 4 : 0)
        .overlay {
            if showShareMenu {
                DocumentShareMenu(
                    onText: shareAsText,
                    onEmail: sendEmail,
                    onClose: { withAnimation(.easeOut(duration: 0.2)) { showShareMenu = false } }
                )
                .transition(.opacity)
            }
        }
        .overlay {
            if showNotificationPrompt {
                NotificationPromptView(
                    onContinue: {
                        showNotificationPrompt = false
                        UNUserNotificationCenter.current()
                            .requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
                    },
                    onLater: { showNotificationPrompt = false }
                )
                .transition(.opacity)
            }
        }
        .optionsSheet(isPresented: $showActions) { actionButtons }
        .markAsPaidDialog(isPresented: $showMarkPaid) { method in
            model.markPaid(with: method)
        }
        .alert(R.stringLocalizable.doc_delete_title(), isPresented: $showDeleteAlert) {
            Button(R.stringLocalizable.common_delete(), role: .destructive) {
                model.delete()
                app.navi.pop()
            }
            Button(R.stringLocalizable.common_cancel(), role: .cancel) {}
        } message: {
            Text(R.stringLocalizable.doc_delete_message())
        }
        .alert(R.stringLocalizable.doc_missing_info_title(), isPresented: $showMissingInfo) {
            Button(R.stringLocalizable.common_ok(), role: .cancel) {}
        } message: {
            Text(R.stringLocalizable.doc_missing_info_message())
        }
        .sheet(item: $shareText) { item in
            ActivityView(items: [item.text])
                .presentationDetents([.medium, .large])
        }
        .onAppear(perform: start)
        .onChange(of: editor.document) { _ in
            model.autosave()
        }
    }

    // MARK: - "…" actions (History/Actions)

    @ViewBuilder
    private var actionButtons: some View {
        Button(R.stringLocalizable.common_delete(), role: .destructive) { showDeleteAlert = true }
        Button(R.stringLocalizable.common_share()) { shareAsText() }
        Button(R.stringLocalizable.doc_print()) { model.printDocument() }
        Button(R.stringLocalizable.doc_duplicate()) { model.duplicate() }
        if kind == .invoice {
            if editor.document.status == .paid {
                Button(R.stringLocalizable.doc_mark_unpaid()) { model.markUnpaid() }
            } else {
                Button(R.stringLocalizable.doc_mark_paid()) { presentMarkPaid() }
            }
        }
    }

    // MARK: - Tabs

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .edit:
            DocumentEditTab(
                model: model,
                showValidation: showValidation,
                onSendReminder: sendReminder,
                onMarkPaid: presentMarkPaid,
                onMakeInvoice: makeInvoice
            )
            .floatingActionButton(icon: R.image.ic_document_send) {
                withAnimation(.easeOut(duration: 0.2)) { showShareMenu = true }
            }
        case .preview:
            DocumentPreviewTab()
        case .history:
            DocumentHistoryTab(showPrompt: $showNotificationPrompt) {
                app.navi.push(.document(.editor(kind, id: nil)))
            }
        }
    }

    // MARK: - Actions

    private func start() {
        guard !didStart else { return }
        didStart = true
        tab = initialTab
        #if DEBUG
        // `-uiPreviewValidation`: red missing-info labels (Invoice/Edit/Scroll 1).
        showValidation = ProcessInfo.processInfo.arguments.contains("-uiPreviewValidation")
        #endif
        switch source {
        case .document(let kind, let id):
            editor.begin(kind: kind, id: id)
        case .current:
            break
        case .firstStored(let kind):
            editor.begin(kind: kind, id: store.documents(kind).first?.id)
            // `-uiPreview` prepares the editor after the root appears; open ours after it.
            DispatchQueue.main.async {
                editor.begin(kind: kind, id: store.documents(kind).first?.id)
            }
        }
        switch startAction {
        case .none:     break
        case .share:    showShareMenu = true
        case .markPaid: presentMarkPaid()
        }
    }

    private func close() {
        model.autosave()
        app.navi.pop()
    }

    private func presentMarkPaid() {
        AnalyticsTracker.logScreenView(.documentMarkAsPaid)
        showMarkPaid = true
    }

    /// Validates required info; turns the missing labels red when something is absent.
    private func validate() -> Bool {
        guard model.isReadyToSend else {
            showValidation = true
            tab = .edit
            showMissingInfo = true
            return false
        }
        return true
    }

    private func sendEmail() {
        showShareMenu = false
        guard validate() else { return }
        model.record(.sent)
        app.navi.push(.documentField(.email))
    }

    private func shareAsText() {
        showShareMenu = false
        guard validate() else { return }
        model.record(.shared)
        shareText = SharedText(text: model.shareSummary())
    }

    private func sendReminder() {
        guard validate() else { return }
        model.record(.reminder)
        app.navi.push(.documentField(.email))
    }

    private func makeInvoice() {
        guard validate() else { return }
        let id = model.makeInvoice()
        app.navi.push(.document(.editor(.invoice, id: id)))
    }
}

/// Text handed to the system share sheet.
struct SharedText: Identifiable {
    let id = UUID()
    let text: String
}

/// `UIActivityViewController` for sharing a document summary.
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
