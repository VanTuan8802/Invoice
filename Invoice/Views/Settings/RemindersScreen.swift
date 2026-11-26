//
//  RemindersScreen.swift
//  Invoice
//
//  Settings/Reminders: payment reminder schedule and "notify me" switches.
//  Values persist immediately in `@AppStorage` (no Save button in the design).
//

import SwiftUI
import Factory

struct RemindersScreen: View {
    @Injected(\.app) private var app

    @AppStorage(SettingsStorage.Key.paymentReminders) private var paymentReminders = true
    @AppStorage(SettingsStorage.Key.reminderDaysBefore) private var daysBefore = 3
    @AppStorage(SettingsStorage.Key.reminderOnDueDate) private var onDueDate = true
    @AppStorage(SettingsStorage.Key.reminderEveryDaysAfter) private var everyDaysAfter = 7
    @AppStorage(SettingsStorage.Key.notifyPaid) private var notifyPaid = true
    @AppStorage(SettingsStorage.Key.notifyOverdue) private var notifyOverdue = true
    @AppStorage(SettingsStorage.Key.notifyRecurringSent) private var notifyRecurringSent = false

    var body: some View {
        VStack(spacing: 0) {
            BasicHeaderView(R.stringLocalizable.settings_reminders(),
                            showBack: true,
                            backAction: { app.navi.pop() })

            Form {
                Section {
                    toggle(R.stringLocalizable.settings_payment_reminders(), isOn: $paymentReminders)
                } footer: {
                    Text(R.stringLocalizable.settings_payment_reminders_footer())
                        .settingsSectionFooter()
                }

                Section {
                    Menu {
                        Picker(selection: $daysBefore) {
                            ForEach(SettingsStorage.reminderDaysBeforeOptions, id: \.self) { days in
                                Text(daysText(days)).tag(days)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        SettingsMenuRowLabel(title: R.stringLocalizable.settings_before_due(),
                                             value: daysText(daysBefore))
                    }

                    toggle(R.stringLocalizable.settings_on_due(), isOn: $onDueDate)

                    Menu {
                        Picker(selection: $everyDaysAfter) {
                            ForEach(SettingsStorage.reminderEveryDaysOptions, id: \.self) { days in
                                Text(R.stringLocalizable.settings_every_days(days)).tag(days)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.inline)
                    } label: {
                        SettingsMenuRowLabel(title: R.stringLocalizable.settings_after_due(),
                                             value: R.stringLocalizable.settings_every_days(everyDaysAfter))
                    }
                } header: {
                    Text(R.stringLocalizable.settings_send_reminder()).settingsSectionHeader()
                }
                .disabled(!paymentReminders)

                Section {
                    toggle(R.stringLocalizable.settings_notify_paid(), isOn: $notifyPaid)
                    toggle(R.stringLocalizable.settings_notify_overdue(), isOn: $notifyOverdue)
                    toggle(R.stringLocalizable.settings_notify_recurring(), isOn: $notifyRecurringSent)
                } header: {
                    Text(R.stringLocalizable.settings_notify_me()).settingsSectionHeader()
                }
            }
            .settingsFormStyle(topMargin: 8, sectionSpacing: 32)
        }
        .groupedScreenBackground()
        .trackScreen(.settingsReminders)
    }

    private func toggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.body)
                .foregroundStyle(Color(.label))
        }
        .tint(Color(.systemGreen))
    }

    private func daysText(_ days: Int) -> String {
        days == 1 ? R.stringLocalizable.settings_one_day() : R.stringLocalizable.settings_days_count(days)
    }
}

#if DEBUG
#Preview {
    RemindersScreen()
}
#endif
