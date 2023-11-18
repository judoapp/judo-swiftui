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

import Foundation

public enum TextContentType: Codable {

    case `none`

    // Identifying Contacts
    case name
    case namePrefix
    case givenName
    case middleName
    case familyName
    case nameSuffix
    case nickname
    case jobTitle
    case organizationName

    // Setting Location Data
    case location
    case fullStreetAddress
    case streetAddressLine1
    case streetAddressLine2
    case addressCity
    case addressCityAndState
    case addressState
    case postalCode
    case sublocality
    case countryName

    // Setting Communication Details
    case telephoneNumber
    case emailAddress

    // Defining Web Addresses
    case URL

    // Accepting Payment
    case creditCardNumber

    // Managing Accounts
    case username
    case password
    case newPassword

    // Securing Accounts
    case oneTimeCode

    // Tracking Events
    case shipmentTrackingNumber
    case flightNumber

    // Scheduling Events
    case dateTime
}
