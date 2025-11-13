//
//  CareTeamView.swift
//  Monitor
//
//  Manage care team members (dietitians, therapists, peer mentors, etc.)
//

import SwiftUI
import SwiftData

struct CareTeamView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: UserSettings

    @State private var showingAddMember = false

    var body: some View {
        List {
            Section {
                ForEach(settings.careTeam) { member in
                    CareTeamMemberRow(member: member)
                }
                .onDelete(perform: deleteMembers)

                Button {
                    showingAddMember = true
                } label: {
                    Label("Add Care Team Member", systemImage: "plus.circle.fill")
                        .foregroundColor(Theme.Colors.primary)
                }
            } header: {
                Text("Care Team")
            } footer: {
                Text("Add healthcare providers, therapists, dietitians, and other members of your care team.")
                    .font(Theme.Typography.caption)
            }

            Section {
                HStack {
                    Text("Emergency Contact")
                        .font(Theme.Typography.body)
                    Spacer()
                    TextField("Name", text: Binding(
                        get: { settings.emergencyContact ?? "" },
                        set: { settings.emergencyContact = $0.isEmpty ? nil : $0 }
                    ))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Theme.Colors.textSecondary)
                }

                HStack {
                    Text("Emergency Phone")
                        .font(Theme.Typography.body)
                    Spacer()
                    TextField("Phone", text: Binding(
                        get: { settings.emergencyPhone ?? "" },
                        set: { settings.emergencyPhone = $0.isEmpty ? nil : $0 }
                    ))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .keyboardType(.phonePad)
                }
            } header: {
                Text("Emergency Contact")
            } footer: {
                Text("A contact to reach in case of crisis or emergency.")
                    .font(Theme.Typography.caption)
            }
        }
        .navigationTitle("Care Team")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddMember) {
            AddCareTeamMemberView(settings: settings)
        }
    }

    private func deleteMembers(at offsets: IndexSet) {
        for index in offsets {
            let member = settings.careTeam[index]
            modelContext.delete(member)
        }
    }
}

// MARK: - Care Team Member Row

struct CareTeamMemberRow: View {
    let member: CareTeamMember

    var body: some View {
        NavigationLink {
            EditCareTeamMemberView(member: member)
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: member.role.icon)
                    .font(.title3)
                    .foregroundColor(Theme.Colors.primary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(member.name)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)

                    Text(member.role.rawValue)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)

                    if let phone = member.phone {
                        Text(phone)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.xs)
        }
    }
}

// MARK: - Add Care Team Member View

struct AddCareTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var settings: UserSettings

    @State private var name = ""
    @State private var role: CareTeamRole = .dietitian
    @State private var phone = ""
    @State private var email = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)

                    Picker("Role", selection: $role) {
                        ForEach(CareTeamRole.allCases) { role in
                            Label(role.rawValue, systemImage: role.icon)
                                .tag(role)
                        }
                    }
                }

                Section("Contact Information") {
                    TextField("Phone (optional)", text: $phone)
                        .keyboardType(.phonePad)

                    TextField("Email (optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Care Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMember()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addMember() {
        let member = CareTeamMember(
            name: name,
            role: role,
            phone: phone.isEmpty ? nil : phone,
            email: email.isEmpty ? nil : email,
            notes: notes.isEmpty ? nil : notes
        )

        member.settings = settings
        modelContext.insert(member)

        dismiss()
    }
}

// MARK: - Edit Care Team Member View

struct EditCareTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var member: CareTeamMember

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $member.name)

                Picker("Role", selection: $member.role) {
                    ForEach(CareTeamRole.allCases) { role in
                        Label(role.rawValue, systemImage: role.icon)
                            .tag(role)
                    }
                }
            }

            Section("Contact Information") {
                TextField("Phone (optional)", text: Binding(
                    get: { member.phone ?? "" },
                    set: { member.phone = $0.isEmpty ? nil : $0 }
                ))
                .keyboardType(.phonePad)

                TextField("Email (optional)", text: Binding(
                    get: { member.email ?? "" },
                    set: { member.email = $0.isEmpty ? nil : $0 }
                ))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            }

            Section("Notes") {
                TextEditor(text: Binding(
                    get: { member.notes ?? "" },
                    set: { member.notes = $0.isEmpty ? nil : $0 }
                ))
                .frame(minHeight: 100)
            }
        }
        .navigationTitle("Edit Care Team Member")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CareTeamView(settings: UserSettings())
            .modelContainer(for: [UserSettings.self, CareTeamMember.self])
    }
}
