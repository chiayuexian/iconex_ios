//
//  IXUtils.swift
//  iconex_ios
//
//  Copyright © 2018 ICON Foundation. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import BigInt
import Web3swift
import LocalAuthentication
import CryptoSwift
import Toast_Swift
import ICONKit

struct Tools {
    public enum LAStatus {
        case success
        case failed
        case userCancel
        case locked
        case notUsed
        case notSupported
        case userFallback
        case notAvailable
        case passcodeNotSet
    }
    
    static var decimalSeparator: String {
        var separator = "."
        let formatter = NumberFormatter()
        guard let id = Locale.current.collatorIdentifier else { return "." }
        formatter.locale = Locale(identifier: id)
        
        if let localizedSeparator = formatter.decimalSeparator {
            separator = localizedSeparator
        }
        
        return separator
    }
    
    static var groupingSeparator: String {
        var separator = ","
        let formatter = NumberFormatter()
        guard let id = Locale.current.collatorIdentifier else { return "." }
        formatter.locale = Locale(identifier: id)
        
        if let localizedSeparator = formatter.groupingSeparator {
            separator = localizedSeparator
        }
        
        return separator
    }
    
    static func hexStringToBalanceString(hexString: String, decimal: Int) -> String? {
        var stringValue = hexString as NSString
        if stringValue.hasPrefix("0x") {
            stringValue = stringValue.substring(from: 2) as NSString
        }
        guard let bigInt = BigUInt(String(stringValue), radix: 16) else {
            return nil
        }
        
        return bigToString(value: bigInt, decimal: decimal)
    }
    
    static func bigToString(value bigInt: BigUInt, decimal: Int, _ below: Int = 0, _ remove: Bool = false) -> String {
        let total = bigInt.quotientAndRemainder(dividingBy: BigUInt(10).power(decimal))
        let icx = String(total.quotient, radix: 10)
        var wei = String(total.remainder, radix: 10)
        
        while wei.length < decimal {
            wei = "0" + wei
        }
        
        var under = wei as NSString
        while under.length > below {
            under = under.substring(to: under.length - 1) as NSString
        }
        while remove && under.hasSuffix("0") {
            under = under.substring(to: under.length - 1) as NSString
        }

        wei = under as String
        
        return wei == "" ? icx : icx + Tools.decimalSeparator + wei
    }
    
    static func hexStringToBig(value: String) -> BigUInt? {
        var balance = value
        if balance.hasPrefix("0x") {
            balance = String(balance[balance.index(balance.startIndex, offsetBy: 2)..<balance.endIndex])
        }
        
        return BigUInt(balance, radix: 16)
    }
    
    static func getICXtoHEX(dic: [String: Any]) -> String {
        var response: String
        if let result = dic["result"] as? [String: Any] {
            response = result["response"] as! String
        } else {
            response = dic["response"] as! String
        }
        
        response = String(response[response.index(response.startIndex, offsetBy: 2)..<response.endIndex])
        
        return response
    }
    
    static func getICX(dic: [String: Any]) -> BigUInt? {
        var response: String
        if let result = dic["result"] as? [String: Any] {
            response = result["response"] as! String
        } else {
            response = dic["response"] as! String
        }
        
        response = String(response[response.index(response.startIndex, offsetBy: 2)..<response.endIndex])
        
        return hexStringToBig(value: response)
    }
    
    static func stringToBigUInt(inputText: String, decimal: Int = 18, fixed: Bool = false) -> BigUInt? {
        var groupingSeparator = Tools.groupingSeparator
        var decimalSeparator = Tools.decimalSeparator
        
        if fixed {
            groupingSeparator = ","
            decimalSeparator = "."
        }
        
        let strip = inputText.replacingOccurrences(of: groupingSeparator, with: "")
        let comp = strip.components(separatedBy: decimalSeparator)
        
        var result: BigUInt?
        if comp.count < 2 {
            guard let first = comp.first, let quotient = BigUInt(first) else {
                return nil
            }
            
            let completed = quotient * BigUInt(10).power(decimal)
            result = completed
        } else {
            guard let first = comp.first, let second = comp.last, let quotient = BigUInt(first, radix: 10), let remainder = BigUInt(second, radix: 10) else {
                return nil
            }
            let completed = (quotient * BigUInt(10).power(decimal)) + (remainder * BigUInt(10).power(decimal - second.length))
            result = completed
        }
        
        return result
    }
    
    static func convertedHexString(value: String, decimal: Int = 18) -> String? {
        let comp = value.components(separatedBy: Tools.decimalSeparator)
        
        var converted: BigUInt?
        if comp.count < 2 {
            guard let first = comp.first, let quotient = BigUInt(first) else {
                return nil
            }
            
            let completed = quotient * BigUInt(10).power(decimal)
            converted = completed
        } else {
            guard let first = comp.first, let second = comp.last, let quotient = BigUInt(first, radix: 10), let remainder = BigUInt(second, radix: 10) else {
                return nil
            }
            let completed = (quotient * BigUInt(10).power(decimal)) + (remainder * BigUInt(10).power(decimal - second.length))
            converted = completed
        }
        
        let result = String(converted!, radix: 16)
        
        return "0x" + result
    }
    
    static func balanceToExchange(_ value: BigUInt, from: String, to: String, belowDecimal: Int = 4, decimal: Int = 18) -> String? {
        guard let exchanged = balanceToExchangeBigInt(value, from: from, to: to, decimal: decimal) else { return nil }
        
        return bigToString(value: exchanged, decimal: decimal, belowDecimal, false)
    }
    
    static func balanceToExchangeBigInt(_ value: BigUInt, from: String, to: String, decimal: Int = 18) -> BigUInt? {
        guard let rateString = Exchange.exchangeInfoList[from+to], rateString.createDate != nil, let rate = Tools.stringToBigUInt(inputText: rateString.price, decimal: decimal, fixed: true) else {
            return nil
        }
        
        let exchanged = value * rate / BigUInt(10).power(decimal)
        
        return exchanged
    }
    
    static func rotateAnimation(inView: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = CGFloat(.pi * 2.0)
        animation.duration = 1.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        
        inView.layer.add(animation, forKey: "rotation")
    }
    
    static func rotateReverseAnimation(inView: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = CGFloat(.pi * 2.0)
        animation.toValue = 0.0
        animation.duration = 1.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        
        inView.layer.add(animation, forKey: "rotation")
    }
    
    static func isPasscode() -> Bool {
        guard (UserDefaults.standard.string(forKey: "u8djdnuEe2xIddfkD") != nil) else { return false }
        guard (UserDefaults.standard.string(forKey: "aExd73E0dxvdQrx") != nil) else { return false }
        
        return UserDefaults.standard.bool(forKey: "useLock")
    }
    
    static func createPasscode(code: String) -> Bool {
        let uuid = UUID().uuidString
        let uuidArray = Array(uuid.utf8)
        let word = Array(code.utf8)
        do {
            let encryptedData = try HMAC(key: uuidArray, variant: .sha256).authenticate(word)
            let encrypted = encryptedData.toHexString()
            
            UserDefaults.standard.set(uuid, forKey: "u8djdnuEe2xIddfkD")
            UserDefaults.standard.set(encrypted, forKey: "aExd73E0dxvdQrx")
            UserDefaults.standard.set(true, forKey: "useLock")
            UserDefaults.standard.synchronize()
        } catch {
            return false
        }
        return true
    }
    
    static func verifyPasscode(code: String) -> Bool {
        guard let uuid = UserDefaults.standard.string(forKey: "u8djdnuEe2xIddfkD") else { return false }
        guard let saved = UserDefaults.standard.string(forKey: "aExd73E0dxvdQrx") else { return false }
        let uuidArray = Array(uuid.utf8)
        let word = Array(code.utf8)
        do {
            let encryptedData = try HMAC(key: uuidArray, variant: .sha256).authenticate(word)
            let encrypted = encryptedData.toHexString()
            
            if saved == encrypted { return true }
        } catch {
            return false
        }
        return false
    }
    
    static func removePasscode() {
        UserDefaults.standard.removeObject(forKey: "u8djdnuEe2xIddfkD")
        UserDefaults.standard.removeObject(forKey: "aExd73E0dxvdQrx")
        UserDefaults.standard.removeObject(forKey: "useLock")
        UserDefaults.standard.synchronize()
    }
    
    static func canVerificateTouchID() -> LAStatus {
        let context = LAContext()
        
        var errorPointer: NSError?
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorPointer)
        
        guard let error = errorPointer as? LAError else {
            return .success
        }
        
        switch error {
        case LAError.touchIDLockout:
            return LAStatus.locked
            
        case LAError.touchIDNotEnrolled:
            return LAStatus.notUsed
            
        default:
            if #available(iOS 11, *) {
                switch error {
                case LAError.biometryLockout:
                    return LAStatus.locked
                    
                case LAError.biometryNotEnrolled:
                    return LAStatus.notUsed
                    
                case LAError.biometryNotAvailable:
                    return LAStatus.notAvailable
                    
                case LAError.passcodeNotSet:
                    return LAStatus.passcodeNotSet
                    
                default:
                    return LAStatus.notSupported
                }
            } else {
                return LAStatus.notSupported
            }
        }
    }
    
    static var isTouchIDEnabled: Bool {
        return UserDefaults.standard.bool(forKey: "useBio")
    }
    
    static func touchIDVerification(message: String, completion: @escaping ((_ state: LAStatus) -> Void)) {
        let context = LAContext()
        var reason = ""
        switch UIDevice.current.type {
        case .iPhoneX:
            reason = "LockScreen.Setting.Bio.Use.FaceID".localized
            
        default:
            reason = "LockScreen.Setting.Bio.Use.TouchID".localized
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (isSuccess, error) in
            
            var state = LAStatus.success
            
            if isSuccess {
                if let domain = context.evaluatedPolicyDomainState {
                    UserDefaults.standard.set(domain, forKey: "domain")
                    UserDefaults.standard.synchronize()
                    
                    Log.Debug("save users domain.")
                }
            } else {
                switch error!._code {
                case LAError.Code.systemCancel.rawValue, LAError.Code.userCancel.rawValue:
                    state = .userCancel
                    break
                    
                case LAError.Code.authenticationFailed.rawValue:
                    state = .failed
                    break
                    
                case LAError.Code.passcodeNotSet.rawValue, LAError.Code.touchIDNotEnrolled.rawValue:
                    state = .notUsed
                    break
                    
                case LAError.Code.touchIDNotAvailable.rawValue:
                    state = .notSupported
                    break
                    
                case LAError.Code.userFallback.rawValue:
                    state = .userFallback
                    break
                    
                default:
                    if (error!._code == LAError.Code.appCancel.rawValue) {
                        state = .userCancel
                    } else if (error!._code == LAError.Code.touchIDLockout.rawValue) {
                        state = .locked
                    } else {
                        state = .userCancel
                    }
                    
                    break
                }
            }
            DispatchQueue.main.async {
                completion(state)
            }
        }
    }
    
    static func touchIDChanged() -> Bool {
        let context = LAContext()
        
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        guard let oldDomain = UserDefaults.standard.data(forKey: "domain") else {
            return false
        }
        
        guard let newDomain = context.evaluatedPolicyDomainState else {
            return false
        }
        
        let changed = oldDomain != newDomain
        
        Log.Debug("TouchID domain status: \(changed)")
        
        return changed
    }
    
    static func biometryType() -> NSString {
        switch UIDevice.current.type {
        case .iPhoneX:
            return "Face ID"
            
        default:
            return "Touch ID"
        }
    }
    
    static func invalidateTouchID() {
        let context = LAContext()
        
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        guard let newDomain = context.evaluatedPolicyDomainState else {
            return
        }
        
        UserDefaults.standard.set(newDomain, forKey: "domain")
        UserDefaults.standard.synchronize()
        
        Log.Debug("TouchID domain saved.")
    }
    
    static func removeTouchID() {
        UserDefaults.standard.removeObject(forKey: "domain")
        UserDefaults.standard.removeObject(forKey: "useBio")
        UserDefaults.standard.synchronize()
    }
    
    static func toast(message: String) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        
        guard let window = app.window else { return }
        
        window.makeToast(message)        
    }
}


struct Validator {
    static func validateCharacterSet(password: String) -> Bool {
        var charSet = CharacterSet.lowercaseLetters
        let digitSet = CharacterSet.decimalDigits
        let specialSet = CharacterSet(charactersIn: "?!:.,%+-/*<>{}()[]`\"'~_^\\|@#$&")
        let letterSet = charSet.union(CharacterSet.uppercaseLetters)

        charSet = letterSet.union(digitSet)
        charSet = charSet.union(specialSet)
        
        let notAllowed = password.unicodeScalars.filter { charSet.inverted.contains($0) }
        let hasLetters = password.unicodeScalars.filter { letterSet.contains($0) }
        let hasDigits = password.unicodeScalars.filter { digitSet.contains($0) }
        let hasSpecial = password.unicodeScalars.filter { specialSet.contains($0) }
        
        return notAllowed.count == 0 && hasLetters.count > 0 && hasDigits.count > 0 && hasSpecial.count > 0
    }
    
    static func validateSequenceNumber(password: String) -> Bool {
        var valid = true
        
        let pinArray = password.unicodeScalars.filter({ $0.isASCII }).map({ $0.value })
        
        for i in 2..<pinArray.count {
            let c1 = Int(String(pinArray[i - 2]))!
            let c2 = Int(String(pinArray[i - 1]))!
            let c3 = Int(String(pinArray[i]))!
            
            if c1 == c2 && c2 == c3 {
                valid = false
                break
            }
        }
        
        return valid
    }
    
    static func validateICXAddress(address: String) -> Bool {
        let pattern = "^(hx[a-zA-Z0-9]{40})$"
        let result = NSPredicate(format: "SELF MATCHES %@", pattern)
        return result.evaluate(with: address)
    }
    
    static func validateIRCAddress(address: String) -> Bool {
        let pattern = "^(cx[a-zA-Z0-9]{40})$"
        let result = NSPredicate(format: "SELF MATCHES %@", pattern)
        return result.evaluate(with: address)
    }
    
    static func validateETHAddress(address: String) -> Bool {
        let tempAddress = address.add0xPrefix()
        guard tempAddress.length == 42 else { return false }
        let pattern = "^(0x[a-zA-Z0-9]{40})$"
        let result = NSPredicate(format: "SELF MATCHES %@", pattern)
        return result.evaluate(with: tempAddress)
    }
}

func scaleQRCode(origin: CIImage) -> UIImage {
    let scaled = origin.transformed(by: CGAffineTransform(scaleX: 3.0, y: 3.0))
    
    return UIImage(ciImage: scaled, scale: UIScreen.main.scale, orientation: .up)
}

// about RxSwift
func keyboardHeight() -> Observable<CGFloat> {
    return Observable
        .from([
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                .map { notification -> CGFloat in
                    (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
            },
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                .map { _ -> CGFloat in
                    0
            }
            ])
        .merge()
}

func exchangeListDidChanged() -> Observable<Notification> {
    return Observable
        .from([NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "kNotificationExchangeListDidChanged"))])
        .merge()
}

func balanceListDidChanged() -> Observable<(Notification)> {
    return Observable
        .from([
            NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: "kNotificationBalanceListDidChanged"))])
        .merge()
}

func exchangeIndicatorChanged() -> Observable<Notification> {
    return Observable
        .from([NotificationCenter.default.rx.notification(NSNotification.Name("kNotificationExchangeIndicatorChanged"))])
        .merge()
}

func languageDidChanged() -> Observable<Notification> {
    return Observable
        .from([NotificationCenter.default.rx.notification(NSNotification.Name("kNotificationLanguageDidChanged"))])
        .merge()
}

func copyString(message: String) {
    UIPasteboard.general.string = message

    let feedback = UINotificationFeedbackGenerator()
    feedback.prepare()
    feedback.notificationOccurred(.success)
}

func getID() -> String {
    let size = 3
    var randomBytes = Array<UInt8>(repeating: 0, count: size)
    _ = SecRandomCopyBytes(kSecRandomDefault, size, &randomBytes)
    let id = Data(randomBytes).toHexString()
    
    return id
}

func Localized(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

struct Alert {
    public enum EditingMode {
        case add, edit
    }
    
    static func Basic(message: String, alignment: NSTextAlignment = .center) -> BasicActionViewController {
        let basic = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "BasicActionView") as! BasicActionViewController
        basic.message = message
        basic.setAlignment(alignment)
        return basic
    }
    
    static func Basic(attributed: NSAttributedString) -> BasicActionViewController {
        let basic = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "BasicActionView") as! BasicActionViewController
        basic.attrMessage = attributed
        
        return basic
    }
    
    static func Confirm(message: String, cancel: String? = "Common.No".localized, confirm: String? = "Common.Yes".localized, handler: (() -> Void)?, _ cancelHandler: (() -> Void)? = nil) -> ConfirmActionViewController {
        let confirmAction = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "ConfirmActionView") as! ConfirmActionViewController
        confirmAction.message = message
        confirmAction.addConfirm(action: handler)
        confirmAction.cancel = cancelHandler
        confirmAction.confirmTitle = confirm
        confirmAction.cancelTitle = cancel
        return confirmAction
    }
    
    static func shareBackup(filePath: URL) {
        
    }
    
    static func editingAddress(name: String? = nil, address: String? = nil, mode: EditingMode, type: String, handler: (() -> Void)?) -> EditingAddressViewController {
        let add = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "EditingAddressView") as! EditingAddressViewController
        add.name = name
        add.address = address
        add.type = type
        add.mode = mode
        add.handler = handler
        
        return add
    }
    
    static func transactionDetail(txHash: String) -> TransactionDetailViewController {
        let detail = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "TransactionDetailView") as! TransactionDetailViewController
        detail.txHash = txHash
        
        return detail
    }
    
    static func checkPassword(walletInfo: WalletInfo, action: @escaping (_ isSuccess: Bool, _ privateKey: String) -> Void) -> WalletPasswordViewController{
        let auth = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "WalletPasswordView") as! WalletPasswordViewController
        auth.walletInfo = walletInfo
        auth.addConfirm(completion: action)
        
        return auth
    }
    
    static func TokenManage(walletInfo: WalletInfo) -> UINavigationController {
        let token = UIStoryboard(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: "TokenListNav") as! TokenListViewController
        token.walletInfo = walletInfo
        
        let nav = UINavigationController(rootViewController: token)
        nav.isNavigationBarHidden = true
        return nav
    }
    
    static func PrivateInfo(walletInfo: WalletInfo) -> WalletPrivateInfoViewController {
        let info = UIStoryboard(name: "Side", bundle: nil).instantiateViewController(withIdentifier: "WalletPrivateInfo") as! WalletPrivateInfoViewController
        info.wallet = WManager.loadWalletBy(info: walletInfo)
        
        return info
    }
    
    static func NetworkProvider(source: UIViewController, completion: (() -> Void)?) {
        let selectable = UIStoryboard(name: "ActionControls", bundle: nil).instantiateViewController(withIdentifier: "SelectableActionController") as! SelectableActionController
        selectable.handler = { index in
            UserDefaults.standard.set(index, forKey: "Provider")
            UserDefaults.standard.synchronize()
            
            if let compl = completion {
                compl()
            }
        }
        selectable.present(from: source, title: "AppInfo.SelectNetwork".localized, items: ["Mainnet", "Testnet", "Yeouido (여의도)"])
    }
    
    static func DeveloperNetworkProvider(source: UIViewController, completion: (() -> Void)?) {
        let selectable = UIStoryboard(name: "ActionControls", bundle: nil).instantiateViewController(withIdentifier: "SelectableActionController") as! SelectableActionController
        selectable.handler = { index in
            switch index {
            case 0:
                ConnManager.provider = ICONService(provider: "https://wallet.icon.foundation/api/v3", nid: "0x1")
            case 1:
                ConnManager.provider = ICONService(provider: "https://testwallet.icon.foundation/api/v3", nid: "0x2")
            case 2:
                ConnManager.provider = ICONService(provider: "https://bicon.net.solidwallet.io/api/v3", nid: "0x3")
            default:
                ConnManager.provider = ICONService(provider: "https://wallet.icon.foundation/api/v3", nid: "0x1")
            }
            
            if let compl = completion {
                compl()
            }
        }
        selectable.present(from: source, title: "AppInfo.SelectNetwork".localized, items: ["Mainnet", "Testnet", "Yeouido (여의도)"])
    }
}
