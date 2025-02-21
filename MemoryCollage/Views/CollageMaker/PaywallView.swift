//
//  PaywallView.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/26/25.
//
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var iapManager = IAPManager.shared

    var body: some View {
        ZStack {
            // Beautiful Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Title
                Text("Unlock Premium Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                // Premium Benefits List
                   VStack(alignment: .leading, spacing: 15) {
                       HStack {
                           Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                           Text("Export collages without watermarks")
                       }
                       HStack {
                           Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                           Text("Access exclusive templates")
                       }
                       HStack {
                           Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                           Text("Priority support and updates")
                       }
                   }
                   .padding()


                Spacer()

                // Unlock Button
                Button(action: {
                    IAPManager.shared.startPurchase()
                }) {
                    Text("Unlock Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }

                // Restore Purchase Button
                Button(action: {
                    IAPManager.shared.restorePurchases()
                }) {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }

                // Cancel Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }

                Spacer()
            }
        }
        .onAppear {
            IAPManager.shared.fetchProducts()
        }
        .onReceive(iapManager.$purchaseState) {state in
            if state == .purchased {
                dismiss()
            }
            else if case .failed = state {
                dismiss()
            }
        }
    }
      
}



