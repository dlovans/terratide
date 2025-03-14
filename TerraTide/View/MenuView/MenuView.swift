//
//  MenuView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-24.
//

import SwiftUI

struct MenuView: View {
    let tideId: String = "123"
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var tidesViewModel = TidesViewModel()
    @StateObject private var singleTideViewModel = SingleTideViewModel()
    @StateObject private var reportViewModel = ReportViewModel()
    
    @EnvironmentObject var locationService: LocationService
    @State private var path: [Route] = []
    @State private var position = ScrollPosition(edge: .leading)
    @State private var currentPage = 1
    @State private var displayMenu: Bool = false
    @State private var rotateLines: Bool = false
    @State private var isTransitioning: Bool = false
    @FocusState var chatFieldIsFocused: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                TabView(selection: $currentPage) {
                    Tab(value: 0) {
                        ActiveTideListView(path: $path)
                            .environmentObject(tidesViewModel)
                            .environmentObject(reportViewModel)
                            .environmentObject(singleTideViewModel)
                            .onAppear {
                                if currentPage == 0 && isTransitioning {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        isTransitioning = false
                                    }
                                }
                            }
                    }
                    Tab(value: 1) {
                        AvailableTideListView(path: $path)
                            .environmentObject(tidesViewModel)
                            .environmentObject(reportViewModel)
                            .environmentObject(singleTideViewModel)
                            .onAppear {
                                if currentPage == 1 && isTransitioning {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        isTransitioning = false
                                    }
                                }
                            }
                    }
                    
                    Tab(value: 2) {
                        ChatView(chatFieldIsFocused: $chatFieldIsFocused)
                            .environmentObject(chatViewModel)
                            .environmentObject(reportViewModel)
                            .onAppear {
                                if currentPage == 2 && isTransitioning {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        isTransitioning = false
                                    }
                                }
                            }
                    }
                    
                    Tab(value: 3) {
                        SettingsView(path: $path)
                            .onAppear {
                                if currentPage == 3 && isTransitioning {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        isTransitioning = false
                                    }
                                }
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    if chatFieldIsFocused {
                        withAnimation {
                            chatFieldIsFocused = false
                        }
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case let .general(routeName):
                        if routeName == "createTide" {
                            CreateTideView(path: $path)
                                .navigationBarBackButtonHidden()
                        } else if routeName == "blockedUsers" {
                            BlockedUsersView(path: $path)
                                .navigationBarBackButtonHidden()
                        } else if routeName == "deleteAccount" {
                            DeleteAccountConfirmationView(path: $path)
                                .navigationBarBackButtonHidden()
                        }
                    case let .tide(tideId):
                        TidePageView(path: $path, tideId: tideId)
                            .navigationBarBackButtonHidden()
                    @unknown default:
                        Text("Unknown Route")
                    }
                }
                
                SideMenuView(displayMenu: $displayMenu, currentPage: $currentPage, rotateLines: $rotateLines, isTransitioning: $isTransitioning)
                HamburgerMenuButtonView(displayMenu: $displayMenu, rotateLines: $rotateLines)
                    .padding()
                
                ZStack{}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .all)
                    .background(.white)
                    .opacity(isTransitioning ? 0.4 : 0)
                    .allowsHitTesting(isTransitioning)
            }
        }
    }
}

struct SideMenuView: View {
    @Binding var displayMenu: Bool
    @Binding var currentPage: Int
    @Binding var rotateLines: Bool
    @Binding var isTransitioning: Bool
    
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                HStack (spacing: 0) {
                    VStack {
                        VStack {
                            if let username = userViewModel.user?.username {
                                Text("👋 \(username)")
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Button {
                                isTransitioning = true
                                withAnimation {
                                    displayMenu = false
                                    rotateLines = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        currentPage = 0
                                    }
                                }
                            } label: {
                                HStack {
                                    Group {
                                        Image("tides")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundStyle(.green)
                                        Text("Active Tides")
                                    }
                                    .foregroundStyle(currentPage == 0 ? .white: .black)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(currentPage == 0 ? .orange : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button {
                                isTransitioning = true
                                withAnimation {
                                    displayMenu = false
                                    rotateLines = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        currentPage = 1
                                    }
                                }
                            } label: {
                                HStack {
                                    Group {
                                        Image("tides")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                        Text("Available Tides")
                                    }
                                    .foregroundStyle(currentPage == 1 ? .white: .black)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(currentPage == 1 ? .orange : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button {
                                isTransitioning = true
                                withAnimation {
                                    displayMenu = false
                                    rotateLines = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        currentPage = 2
                                    }
                                }
                            } label: {
                                HStack {
                                    Group {
                                        Image(systemName: "bubble.left.and.bubble.right")
                                        Text("Chat")
                                    }
                                    .foregroundStyle(currentPage == 2 ? .white: .black)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(currentPage == 2 ? .orange : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button {
                                isTransitioning = true
                                withAnimation {
                                    displayMenu = false
                                    rotateLines = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        currentPage = 3
                                    }
                                }
                            } label: {
                                HStack {
                                    Group {
                                        Image(systemName: "gear")
                                        Text("Settings")
                                    }
                                    .foregroundStyle(currentPage == 3 ? .white: .black)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(currentPage == 3 ? .orange : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.top, 100)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .background(Color.black)
                    }
                    .frame(width: geometry.size.width * 0.65)
                    .frame(maxHeight: .infinity)
                    
                    VStack {
                        EmptyView()
                    }
                    .frame(width: geometry.size.width * 0.35)
                    .frame(maxHeight: .infinity)
                    .background(Color.black)
                    .opacity(0.01)
                    .onTapGesture {
                        withAnimation {
                            displayMenu = false
                            rotateLines = false
                        }
                    }
                    
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(x: displayMenu ? 0: -UIScreen.main.bounds.width)
    }
}


struct HamburgerMenuButtonView: View {
    @Binding var displayMenu: Bool
    @Binding var rotateLines: Bool
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        displayMenu.toggle()
                        rotateLines.toggle()
                    }
                } label: {
                    VStack (spacing: 7) {
                        Group {
                            Rectangle()
                                .fill(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .rotationEffect(rotateLines ? Angle(degrees: 45) : .zero, anchor: .center)
                                .offset(y: rotateLines ? 10: 0)
                            Rectangle()
                                .fill(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .offset(x: rotateLines ? -100 : 0)
                                .opacity(rotateLines ? 0 : 1)
                            Rectangle()
                                .fill(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .rotationEffect(rotateLines ? Angle(degrees: -45): .zero, anchor: .center)
                                .offset(y: rotateLines ? -11: 0)
                            
                        }
                        .frame(width: 40, height: 3.5)
                    }
                    .frame(alignment: .bottom)
                }
                .padding(.top, 8)
                .padding(.leading, 5)
                
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    MenuView()
}
