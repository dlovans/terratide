//
//  PrivacyPolicyView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-04.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("**Privacy Policy for Terratide**")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("**Last updated: March 2025**")
                    .font(.subheadline)
                    .padding(.bottom)

                Text("""
                Terratide ("we", "our", or "us") is committed to protecting and respecting your privacy. This Privacy Policy explains how we collect, use, and store your personal data when you use the Terratide app ("app"). By using this app, you agree to the collection and use of information in accordance with this policy.

                **1. Information We Collect**
                To provide you with the best experience and enable the functionality of the app, we may collect and store the following types of information:

                - **Personal Information**: When registering for the app, you may provide personal information, such as:
                  - Email address
                  - Username
                  - Date of birth (to determine if you are an adult or a non-adult)

                - **Location Information**: The app uses your **geolocation** for two main purposes:
                  1. To show nearby "tides" that you can join, based on your location.
                  2. To enable the **geo chat** feature, which allows you to send messages to people globally based on your location.
                  Your location data is used solely to facilitate these features and is not stored long-term.

                **2. How We Use Your Information**
                We use the information we collect for the following purposes:
                - To provide the app's core functionalities, including showing nearby tides and facilitating private chats with other users.
                - To ensure that content (such as messages) is displayed appropriately based on your age (i.e., adult-only content is visible to adults, and non-adult content is visible to non-adults).
                - To manage your account and allow you to participate in app features.
                - To comply with legal obligations, including preventing misuse of the app and ensuring that it is not used for illegal activities.
                
                We do not collect, share, or sell any additional personal data for marketing or third-party advertising purposes.

                **3. Data Retention**
                We retain your data only for as long as necessary to provide the services you use within the app. This includes:
                - Storing your account details, messages, and location data temporarily for functionality purposes.
                - We do not offer a way for you to delete your content (e.g., messages), but you can choose to deactivate your account at any time by contacting us.

                **4. Data Security**
                We take reasonable measures to protect the personal information we collect from unauthorized access, alteration, disclosure, or destruction. However, please be aware that no method of transmission over the Internet or electronic storage is 100% secure.

                **5. Age Restrictions**
                Terratide requires users to be at least **13 years old** to use the app. Users will be divided into **adults** and **non-adults** based on the date of birth they provide during registration. Users who are under 18 years old will not be able to access adult content (+18). 

                We do not knowingly collect personal data from children under 13. If we learn that we have collected personal data from a child under 13, we will take steps to delete such data.

                **6. Prohibited Uses**
                Terratide is designed for real-world meetings and **not for dating, hookups, or sexual activities**. Users must comply with the Terms of Service and avoid engaging in illegal activities, including but not limited to fraud, harassment, and other criminal actions.

                If we find that you have violated this policy, we may take action by suspending or banning your account, depending on the severity of the violation.

                **7. Changes to This Privacy Policy**
                We may update this Privacy Policy from time to time to reflect changes in our practices or for other operational, legal, or regulatory reasons. We will notify users of any significant changes by updating the "Last updated" date at the top of this page. We encourage you to review this policy periodically for any updates.

                **8. Your Rights**
                You have the right to:
                - Access the personal information we hold about you.
                - Request that we correct or update your personal information.
                - Request the deactivation of your account. Please note that we do not offer the ability to delete content once it is posted within the app.

                If you have any questions or concerns about your personal data or this Privacy Policy, please contact us at app@terratide.app.
                """)
            }
            .padding()
        }
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
    }
}

#Preview {
    PrivacyPolicyView()
}
