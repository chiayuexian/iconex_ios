//
//  Alert.swift
//  iconex_ios
//
//  Created by sweepty on 06/08/2019.
//  Copyright © 2019 ICON Foundation. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    static func basic(title: String, subtitle: String? = nil, hasHeaderTitle: Bool = false, isOnlyOneButton: Bool = true, leftButtonTitle: String? = nil, rightButtonTitle: String? = nil, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.titleText = title
        alertVC.subTitleText = subtitle ?? ""
        alertVC.type = hasHeaderTitle ? .allText : .basic
        alertVC.isButtonOne = isOnlyOneButton
        
        if let leftTitle = leftButtonTitle {
            alertVC.leftButtonTitle = leftTitle
        }
        if let rightTitle = rightButtonTitle {
            alertVC.rightButtonTitle = rightTitle
        }
        alertVC.confirmHandler = confirmAction
        
        return alertVC
    }
    
    static func txHash(txData: AlertTxHashInfo) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .txHash
        alertVC.txHashData = txData
        return alertVC
    }
    
    static func password(address: String, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .password
        alertVC.walletAddress = address
        return alertVC
    }
    
    static func changeWalletName(walletName: String, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .walletName
        alertVC.walletName = walletName
        return alertVC
    }
    
    static func addAddress(confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .addAddress
        return alertVC
    }
    
    static func stake(stakeInfo: StakeInfo, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .stake
        alertVC.stakeInfo = stakeInfo
        return alertVC
    }
    
    static func unstake(unstakeInfo: StakeInfo, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .unstake
        alertVC.stakeInfo = unstakeInfo
        return alertVC
    }
    
    static func unstakeCancel(cancelInfo: StakeInfo, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .unstakecancel
        alertVC.stakeInfo = cancelInfo
        return alertVC
    }
    
    static func send(sendInfo: SendInfo, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .send
        alertVC.sendInfo = sendInfo
        return alertVC
    }
    
    static func iScore(iscoreInfo: IScoreClaimInfo, confirmAction: (() -> Void)? = nil) -> AlertViewController {
        let alertVC = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        alertVC.type = .iscore
        alertVC.iscoreInfo = iscoreInfo
        return alertVC
    }
    
}

enum AlertType {
    case basic, txHash, password, walletName, allText, stake, unstake, send, iscore, unstakecancel, addAddress
}

struct AlertBasicInfo {
    var title: String
    var subtitle: String?
}

struct AlertTxHashInfo {
    var txHash: String
    var trackerURL: String
}

struct SendInfo {
    var isICX: Bool
    var amount: String
    var stepLimit: String
    var estimatedFee: String
    var estimatedUSD: String
    var receivingAddress: String
}

struct IScoreClaimInfo {
    var currentIScore: String
    var youcanReceive: String
    var stepLimit: String
    var estimatedFee: String
    var estimateUSD: String
}

struct StakeInfo {
    var timeRequired: String
    var stepLimit: String
    var estimatedFee: String
    var estimatedFeeUSD: String
}
