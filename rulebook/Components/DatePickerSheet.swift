import SwiftUI

// MARK: - Date Picker Sheet
// Modal sheet for selecting a date to view rules

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let theme: AppTheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(theme.accentColor)
                .padding()
                
                Spacer()
            }
            .background(theme.backgroundPrimaryColor)
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(theme.textSecondaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(theme.accentColor)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
