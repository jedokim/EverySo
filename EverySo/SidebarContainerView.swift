//
//  SidebarContainerView.swift
//  EverySo
//
//  Created by Jeremy Kim on 6/11/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SidebarContainerView: View {
    @Binding var isSidebarVisible: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if isSidebarVisible {
                // Dimmed background overlay
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSidebarVisible = false
                        }
                    }
            }

            // The sliding sidebar
            SideBarView()
                .frame(width: 250)
                .background(Color(.systemGray6))
                .offset(x: isSidebarVisible ? 0 : -250)
                .opacity(isSidebarVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isSidebarVisible)
        }
    }
}

struct SideBarView: View {
    @AppStorage("firstName") private var userName: String?
    @State private var manualName: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            if let name = userName {
                Text("Welcome \(name)!")
                    .font(.headline)
                    .padding(.top, 100)
            } else {
                Text("Menu")
                    .font(.headline)
                    .padding(.top, 100)

                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let auth):
                            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                                DispatchQueue.main.async {
                                    if let givenName = appleIDCredential.fullName?.givenName {
                                        userName = givenName
                                        UserDefaults.standard.set(givenName, forKey: "firstName")
                                    } else if let storedName = UserDefaults.standard.string(forKey: "firstName") {
                                        userName = storedName
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Apple Sign In Failed: \(error)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 45)
                .padding(.vertical)

                if manualName.isEmpty && userName == nil {
                    TextField("Enter your name", text: $manualName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 8)

                    Button("Continue") {
                        userName = manualName
                        UserDefaults.standard.set(manualName, forKey: "firstName")
                    }
                    .disabled(manualName.isEmpty)
                }
            }

            Divider()
            Text("Quick Actions")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 16)

            Button("First Option") { }
                .padding(.vertical, 10)
            Button("Second Option") { }
                .padding(.vertical, 10)
            Button(userName ?? "Mocha") { }
                .padding(.vertical, 10)
            Spacer()
            if userName != nil {
                Divider()
                Button("Sign Out") {
                    userName = nil
                    UserDefaults.standard.removeObject(forKey: "firstName")
                }
                .foregroundColor(.red)
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}
