//
//  IAPManager.swift
//  MemoryCollage
//
//  Created by Gaurav Kumar on 1/26/25.
//

import Foundation
import StoreKit

class IAPManager: NSObject, ObservableObject {
    static let shared = IAPManager()

    @Published var products: [SKProduct] = []
    @Published var purchaseState: PurchaseState = .notPurchased

    private let productIdentifiers = Set(["com.memorycollage.premium"])
    private var productsRequest: SKProductsRequest?

    enum PurchaseState: Equatable {
        case notPurchased
        case purchased
        case restoring
        case failed(String)

        static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
            switch (lhs, rhs) {
            case (.notPurchased, .notPurchased),
                 (.purchased, .purchased),
                 (.restoring, .restoring):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Fetch Products
    func fetchProducts() {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    // MARK: - Purchase Product
    func startPurchase() {
        guard let product = products.first else { return }
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            purchaseState = .failed("Transaction failed.")
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() {
        purchaseState = .restoring
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - Check if Product is Purchased
    func isPurchased() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasPurchasedPremium")
    }

    // MARK: - Save Purchase
    private func savePurchase() {
        UserDefaults.standard.set(true, forKey: "hasPurchasedPremium")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            self.purchaseState = .purchased
            self.objectWillChange.send()
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.purchaseState = .failed(error.localizedDescription)
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                savePurchase()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                savePurchase()
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                DispatchQueue.main.async {
                    self.purchaseState =  .failed(transaction.error?.localizedDescription ?? "Transaction failed.")
                }
               // savePurchase()
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            self.purchaseState = .purchased
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.purchaseState = .failed(error.localizedDescription)
        }
    }
}


