import SwiftUI

// Example of generated iOS app code for a typical website
struct ExampleGeneratedApp: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Hero Section
                        VStack(spacing: 16) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Welcome to Our App")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Discover amazing features and content designed specifically for mobile")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Get Started") {
                                selectedTab = 1
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Features Section
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            FeatureCard(icon: "star.fill", title: "Premium Quality", description: "High-quality content and features")
                            FeatureCard(icon: "bolt.fill", title: "Fast Performance", description: "Optimized for speed and efficiency")
                            FeatureCard(icon: "shield.fill", title: "Secure", description: "Your data is safe with us")
                            FeatureCard(icon: "heart.fill", title: "User Friendly", description: "Intuitive and easy to use")
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
                .navigationTitle("Home")
                .refreshable {
                    // Pull to refresh functionality
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Content Tab
            NavigationView {
                List {
                    Section("Recent") {
                        ForEach(1...5, id: \.self) { index in
                            ContentRow(title: "Article \(index)", subtitle: "Lorem ipsum dolor sit amet", date: Date())
                        }
                    }
                    
                    Section("Popular") {
                        ForEach(6...10, id: \.self) { index in
                            ContentRow(title: "Popular Article \(index)", subtitle: "Consectetur adipiscing elit", date: Date())
                        }
                    }
                }
                .navigationTitle("Content")
                .searchable(text: $searchText)
            }
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Content")
            }
            .tag(1)
            
            // Profile Tab
            NavigationView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("John Doe")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("john.doe@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Settings List
                    VStack(spacing: 0) {
                        SettingsRow(icon: "bell.fill", title: "Notifications", hasChevron: true)
                        SettingsRow(icon: "lock.fill", title: "Privacy & Security", hasChevron: true)
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", hasChevron: true)
                        SettingsRow(icon: "info.circle.fill", title: "About", hasChevron: true)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button("Sign Out") {
                        // Sign out action
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(2)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ContentRow: View {
    let title: String
    let subtitle: String
    let date: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let hasChevron: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    ExampleGeneratedApp()
}