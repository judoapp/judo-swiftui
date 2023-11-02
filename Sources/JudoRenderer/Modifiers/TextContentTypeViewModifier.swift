// Copyright (c) 2023-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import JudoDocument
import SwiftUI

struct TextContentTypeViewModifier: SwiftUI.ViewModifier {
    var modifier: TextContentTypeModifier

    func body(content: Content) -> some SwiftUI.View {
        content.textContentType(textContentType)
    }
    
    private var textContentType: UIKit.UITextContentType? {
        switch modifier.textContentType {
        case .URL:
            return .URL
        case .namePrefix:
            return .namePrefix
        case .name:
            return .name
        case .nameSuffix:
            return .nameSuffix
        case .givenName:
            return .givenName
        case .middleName:
            return .middleName
        case .familyName:
            return .familyName
        case .nickname:
            return .nickname
        case .organizationName:
            return .organizationName
        case .jobTitle:
            return .jobTitle
        case .location:
            return .location
        case .fullStreetAddress:
            return .fullStreetAddress
        case .streetAddressLine1:
            return .streetAddressLine1
        case .streetAddressLine2:
            return .streetAddressLine2
        case .addressCity:
            return .addressCity
        case .addressCityAndState:
            return .addressCityAndState
        case .addressState:
            return .addressState
        case .postalCode:
            return .postalCode
        case .sublocality:
            return .sublocality
        case .countryName:
            return .countryName
        case .username:
            return .username
        case .password:
            return .password
        case .newPassword:
            return .newPassword
        case .oneTimeCode:
            return .oneTimeCode
        case .emailAddress:
            return .emailAddress
        case .telephoneNumber:
            return .telephoneNumber
        case .creditCardNumber:
            return .creditCardNumber
        case .dateTime:
            if #available(iOS 15, *) {
                return .dateTime
            } else {
                return nil
            }
        case .flightNumber:
            if #available(iOS 15, *) {
                return .flightNumber
            } else {
                return nil
            }
        case .shipmentTrackingNumber:
            if #available(iOS 15, *) {
                return .shipmentTrackingNumber
            } else {
                return nil
            }
        case .none:
            return nil
        }
    }
}
