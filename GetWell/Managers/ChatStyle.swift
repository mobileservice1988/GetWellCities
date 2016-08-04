//
//  ChatStyle.swift
//  GetWell
//
//  Created by Marcos Curvello on 2/9/16.
//  Copyright © 2016 Get Well. All rights reserved.
//

import UIKit
import ZDCChat
import ZendeskSDK

class ChatStyle: NSObject {

    class func applyStyling() {
        
        ZDCChat.instance().overlay.setEnabled(false)
        ZDCChat.instance().hidesBottomBarWhenPushed = true
        
        ZDCChatOverlay.appearance().alignment = 3
        ZDCChatOverlay.appearance().insets = NSValue(UIEdgeInsets: UIEdgeInsetsMake(75, 30, 154, 24))
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Default Styles
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        let SFUITextRegular14 = UIFont(name: "SFUIText-Regular", size: 14)
        let SFUITextMedium14  = UIFont(name: "SFUIText-Medium", size: 14)
        let AgentTextColor    = UIColor(white: 0.0, alpha: 1.0)
        
        let BlueBubbleColor = UIColor( red: 0.0392, green: 0.3333, blue: 0.4706, alpha: 1.0 )
        let backgroundColor = UIColor( red: 0.9263, green: 0.9255, blue: 0.9507, alpha: 1.0 )
        
        UIScrollView.appearanceWhenContainedInInstancesOfClasses([ZDKRequestListViewController.self]).backgroundColor = backgroundColor
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // History - Create Ticket View
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ZDKCreateRequestView.appearance().viewBackgroundColor      = UIColor.whiteColor()        
        ZDKCreateRequestView.appearance().textEntryBackgroundColor = backgroundColor
        ZDKCreateRequestView.appearance().attachmentButtonImage    = UIImage(named: "icon-Attachment")
        ZDKCreateRequestView.appearance().automaticallyHideNavBarOnLandscape = true
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // History List View
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
//      ZDKRequestListTable.appearance().backgroundColor         = cellBackgroundColor
//      ZDKRequestListTableCell.appearance().cellBackgroundColor = cellBackgroundColor
        ZDKRequestListTableCell.appearance().descriptionFont = SFUITextMedium14
   
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // History Ticket Detail
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ZDKCommentInputView.appearance().backgroundColor          = UIColor.whiteColor()
        ZDKCommentInputView.appearance().topBorderColor           = UIColor.whiteColor()
        ZDKCommentInputView.appearance().textEntryBackgroundColor = UIColor.whiteColor()
        ZDKCommentInputView.appearance().textEntryBorderColor     = UIColor.whiteColor()
        ZDKCommentInputView.appearance().areaBackgroundColor      = UIColor.whiteColor()
        ZDKCommentInputView.appearance().textEntryColor           = UIColor.blackColor()
        ZDKCommentInputView.appearance().sendButtonColor          = UIColor ( red: 0.0392, green: 0.3333, blue: 0.4706, alpha: 1.0 )
        ZDKCommentInputView.appearance().sendButtonFont           = SFUITextMedium14
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Concierge No Agents View
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        ZDCLoadingErrorView.appearance().iconImage = "icon-Envelope"
        ZDCLoadingErrorView.appearance().errorBackgroundColor  = backgroundColor
        ZDCLoadingErrorView.appearance().buttonBackgroundColor = UIColor ( red: 0.0392, green: 0.3333, blue: 0.4706, alpha: 1.0 )
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Cocierge Loading View
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ZDCLoadingView.appearance().loadingLabelFont       = SFUITextMedium14
        ZDCLoadingView.appearance().loadingBackgroundColor = UIColor ( red: 0.9263, green: 0.9255, blue: 0.9507, alpha: 1.0 )
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Cocierge View
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ZDCChatUI.appearance().endChatButtonImage    = "icon-Envelope"
        ZDCChatUI.appearance().cancelChatButtonImage = "icon-Envelope"
        ZDCChatUI.appearance().backgroundColor       = backgroundColor
        
        ZDCChatView.appearance().chatBackgroundColor = backgroundColor
        ZDCChatView.appearance().backgroundColor     = backgroundColor
        
//        ZDCChatAvatar.appearance().defaultAvatarImage = UIImage(named: "icon-Envelope")

        ZDCTextEntryView.appearance().backgroundColor          = UIColor.whiteColor()
        ZDCTextEntryView.appearance().topBorderColor           = UIColor.whiteColor()
        ZDCTextEntryView.appearance().textEntryBackgroundColor = UIColor.whiteColor()
        ZDCTextEntryView.appearance().textEntryBorderColor     = UIColor.whiteColor()
        ZDCTextEntryView.appearance().attachButtonImage        = "icon-Attachment"
        ZDCTextEntryView.appearance().textEntryFont            = SFUITextMedium14

        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Cocierge Cells
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ZDCJoinLeaveCell.appearance().textInsets = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 70, 10, 20))
        ZDCJoinLeaveCell.appearance().textColor  = AgentTextColor
        ZDCJoinLeaveCell.appearance().textFont   = SFUITextRegular14
        
        ZDCVisitorChatCell.appearance().bubbleInsets           = NSValue(UIEdgeInsets: UIEdgeInsetsMake(8, 75, 7, 15))
        ZDCVisitorChatCell.appearance().textInsets             = NSValue(UIEdgeInsets: UIEdgeInsetsMake(12, 15, 12, 15))
        ZDCVisitorChatCell.appearance().bubbleBorderColor      = BlueBubbleColor
        ZDCVisitorChatCell.appearance().bubbleColor            = UIColor ( red: 0.0392, green: 0.3333, blue: 0.4706, alpha: 1.0 )
        ZDCVisitorChatCell.appearance().bubbleCornerRadius     = 5.0
        ZDCVisitorChatCell.appearance().textAlignment          = 0
        ZDCVisitorChatCell.appearance().textColor              = UIColor.whiteColor()
        ZDCVisitorChatCell.appearance().textFont               = SFUITextRegular14
        ZDCVisitorChatCell.appearance().unsentTextColor        = UIColor.whiteColor()
        ZDCVisitorChatCell.appearance().unsentTextFont         = SFUITextRegular14
        ZDCVisitorChatCell.appearance().unsentMessageTopMargin = 5.0
        ZDCVisitorChatCell.appearance().unsentIconLeftMargin   = 10.0
    
        ZDCAgentChatCell.appearance().bubbleInsets       = NSValue(UIEdgeInsets: UIEdgeInsetsMake(8.0, 55.0, 7.0, 15.0))
        ZDCAgentChatCell.appearance().textInsets         = NSValue(UIEdgeInsets: UIEdgeInsetsMake(12.0, 15.0, 12.0, 15.0))
        ZDCAgentChatCell.appearance().bubbleBorderColor  = UIColor.whiteColor()
        
        ZDCAgentChatCell.appearance().bubbleColor        = UIColor.whiteColor()
        ZDCAgentChatCell.appearance().bubbleCornerRadius = 5.0
        ZDCAgentChatCell.appearance().textAlignment      = 0
        ZDCAgentChatCell.appearance().textColor          = UIColor.blackColor()
        ZDCAgentChatCell.appearance().textFont           = SFUITextRegular14
        ZDCAgentChatCell.appearance().avatarHeight       = 30.0
        ZDCAgentChatCell.appearance().avatarLeftInset    = 14.0
        ZDCAgentChatCell.appearance().authorColor        = UIColor ( red: 0.5765, green: 0.5765, blue: 0.5765, alpha: 1.0 )
        ZDCAgentChatCell.appearance().authorFont         = SFUITextRegular14
        ZDCAgentChatCell.appearance().authorHeight       = 25
        
        ZDCSystemTriggerCell.appearance().textInsets = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 20, 10, 20))
        ZDCSystemTriggerCell.appearance().textColor  = UIColor( red: 0.5044, green: 0.5044, blue: 0.5044, alpha: 1.0 )
        ZDCSystemTriggerCell.appearance().textFont   = SFUITextRegular14
        
        ZDCChatTimedOutCell.appearance().textInsets = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 20, 10, 20))
        ZDCChatTimedOutCell.appearance().textColor  = UIColor.blackColor()
        ZDCChatTimedOutCell.appearance().textFont   = SFUITextRegular14
        
        ZDCRatingCell.appearance().titleColor                  = UIColor ( red: 0.8363, green: 0.021, blue: 0.1727, alpha: 1.0 )
        ZDCRatingCell.appearance().titleFont                   = UIFont(name: "", size: 12)
        ZDCRatingCell.appearance().cellToTitleMargin           = 20
        ZDCRatingCell.appearance().titleToButtonsMargin        = 10
        ZDCRatingCell.appearance().ratingButtonToCommentMargin = 20
        ZDCRatingCell.appearance().editCommentButtonHeight     = 44
        ZDCRatingCell.appearance().ratingButtonSize            = 40
        
        ZDCAgentAttachmentCell.appearance().activityIndicatorViewStyle   = 2
        ZDCVisitorAttachmentCell.appearance().activityIndicatorViewStyle = 2
        
        ZDCFormCellDepartment.appearance().textFrameInsets          = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 15, 0, 15))
        ZDCFormCellDepartment.appearance().textInsets               = NSValue(UIEdgeInsets: UIEdgeInsetsMake(5, 15, 5, 15))
        ZDCFormCellDepartment.appearance().textFrameBorderColor     = UIColor(white: 0.9, alpha: 1.0)
        ZDCFormCellDepartment.appearance().textFrameBackgroundColor = UIColor.whiteColor()
        ZDCFormCellDepartment.appearance().textFrameCornerRadius    = 3.0
        ZDCFormCellDepartment.appearance().textFont                 = SFUITextRegular14
        ZDCFormCellDepartment.appearance().textColor                = UIColor(white: 0.2, alpha: 1.0)
        
        ZDCFormCellMessage.appearance().textFrameInsets          = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 15, 10, 15))
        ZDCFormCellMessage.appearance().textInsets               = NSValue(UIEdgeInsets: UIEdgeInsetsMake(5, 10, 5, 10))
        ZDCFormCellMessage.appearance().textFrameBorderColor     = UIColor(white: 0.9, alpha: 1.0)
        ZDCFormCellMessage.appearance().textFrameBackgroundColor = UIColor.whiteColor()
        ZDCFormCellMessage.appearance().textFont                 = SFUITextRegular14
        ZDCFormCellMessage.appearance().textColor                = UIColor(white: 0.2, alpha: 1.0)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // Pre Cocierge Form
        ////////////////////////////////////////////////////////////////////////////////////////////////
        
        ZDCPreChatFormView.appearance().formBackgroundColor         = backgroundColor
        ZDCFormCellSingleLine.appearance().textFrameInsets          = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 15, 0, 15))
        ZDCFormCellSingleLine.appearance().textInsets               = NSValue(UIEdgeInsets: UIEdgeInsetsMake(5.0, 15.0, 5.0, 15.0))
        ZDCFormCellSingleLine.appearance().textFrameBorderColor     = UIColor.whiteColor()
        ZDCFormCellSingleLine.appearance().textFrameBackgroundColor = UIColor.whiteColor()
        ZDCFormCellSingleLine.appearance().textFrameCornerRadius    = 3.0
        ZDCFormCellSingleLine.appearance().textFont                 = SFUITextMedium14
        ZDCFormCellSingleLine.appearance().textColor                = UIColor.blackColor()
        
        ZDCFormCellDepartment.appearance().textFrameInsets          = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 15, 0, 15))
        ZDCFormCellDepartment.appearance().textInsets               = NSValue(UIEdgeInsets: UIEdgeInsetsMake(5, 15, 5, 15))
        ZDCFormCellDepartment.appearance().textFrameBorderColor     = UIColor.whiteColor()
        ZDCFormCellDepartment.appearance().textFrameBackgroundColor = UIColor.whiteColor()
        ZDCFormCellDepartment.appearance().textFrameCornerRadius    = 3.0
        ZDCFormCellDepartment.appearance().textFont                 = SFUITextMedium14
        ZDCFormCellDepartment.appearance().textColor                = UIColor(white: 0.2, alpha: 1.0)
        
        ZDCFormCellMessage.appearance().textFrameInsets          = NSValue(UIEdgeInsets: UIEdgeInsetsMake(10, 15, 10, 15))
        ZDCFormCellMessage.appearance().textInsets               = NSValue(UIEdgeInsets: UIEdgeInsetsMake(5, 10, 5, 10))
        ZDCFormCellMessage.appearance().textFrameBorderColor     = UIColor.whiteColor()
        ZDCFormCellMessage.appearance().textFrameBackgroundColor = UIColor.whiteColor()
        ZDCFormCellMessage.appearance().textFont                 = SFUITextMedium14
        ZDCFormCellMessage.appearance().textColor                = UIColor.blackColor()
    
    }
    
}
