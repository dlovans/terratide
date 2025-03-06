//
//  TOSView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-04.
//

import SwiftUI

struct TOSView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("**Terms of Service**")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("""
                1. **Introduction**
                Welcome to TerraTide! By using this app, you agree to comply with and be bound by the following terms and conditions. Please read them carefully.

                2. **Purpose of the App**
                The TerraTide app facilitates real-world meetings between anonymous people based on geolocation. It is not for dating, hookups, or any sexual activities. The app connects people nearby through 'Tides' to plan activities in a private chat.

                3. **Registration and Age Requirements**
                Users must be registered to use the app. Upon registration, you will be asked to provide your age. Users are divided into adults and non-adults. Adult-only content (+18) will be visible only to adults, while non-adult content will be shown to non-adults.

                4. **Content Ownership**
                Users retain ownership of the content they post within the app, such as messages. However, once posted, content cannot be deleted.

                5. **Monetization**
                Currently, the app does not have any monetization.

                6. **Data Collection**
                The app does not actively collect user data. The only information stored in the database is necessary for the app's functionality (e.g., email, username, and date of birth).

                7. **Prohibited Activities**
                The app is strictly prohibited from facilitating illegal activities, dating, hookups, or sexual activities. Any violations of these terms may result in account suspension or permanent banning.

                8. **Enforcement of Terms**
                If you violate the Terms of Service, the app may impose a temporary ban depending on the severity of the transgression. In case of serious violations, a permanent ban will be imposed.

                9. **Changes to the Terms**
                TerraTide reserves the right to update or modify these Terms of Service at any time. You will be notified of any significant changes.

                10. **Contact Us**
                If you have any questions regarding these Terms of Service, please contact us at app@terratide.app.
                """)
                    .font(.body)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarTitle("Terms of Service", displayMode: .inline)
        .padding()
    }
}

#Preview {
    TOSView()
}
