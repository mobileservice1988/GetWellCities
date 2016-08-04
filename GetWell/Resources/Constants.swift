//
//  Constants.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

struct Constants {
    
    struct Auth {
        static let auth0UserURL = "https://app47232952.auth0.com/api/v2/users/"
        static let auth0UpdateToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzc0RkejBQOGFVOU1sVGdtemc0V2RsVWczRmxjZDNwMiIsInNjb3BlcyI6eyJ1c2Vyc19hcHBfbWV0YWRhdGEiOnsiYWN0aW9ucyI6WyJ1cGRhdGUiXX19LCJpYXQiOjE0NTU2NTA1MzEsImp0aSI6ImY4ODUwNGM4YTE3NTY5ZGI3ZThkYzc3N2M1YmUyMjQ5In0.mhk0ldf2xZkTIxSM5nrPGww4RGaD_Iv1BNQXGJMO-zI"
    }
    struct Payment {
        static let merchantID           = "merchant.com.gwc"
        static let stripeTestPublicKey  = "pk_test_ygW85qQWpe5PxIAZfycNT1JY"
        static let stripeTestPrivateKey = "sk_test_qZR0rjyiSL0iabDZ1AhC9OOr"
        static let stripeLivePublicKey  = "sk_live_PVUNZroLn4lC2pjGgBuFKeX2"
        static let stripeLivePrivateKey = "pk_live_Az1ljjnBemC6SHHW2JKyXHbX"
        static let stripeChargeURL      = "https://gwc-stripe.herokuapp.com"
        static let stripePlanURL        = "https://api.stripe.com/v1/plans"
        static let stripeCustomerURL    = "https://api.stripe.com/v1/customers"
    }
    struct Localytics {
        static let key = "ed0a0a84752f3e22d3abc96-d83b2d9a-2684-11e6-b132-00342b7f5075"
    }
    struct Intercom {
        static let appID  = "ka66hw1c"
        static let appKey = "ios_sdk-1e92f23ebbc3d9b2e29ea1e8bf8c0eccdf87be6e"
    }
    struct GWAPI {
        static let token       = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiYWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vYXBwNDcyMzI5NTIuYXV0aDAuY29tLyIsInN1YiI6ImZhY2Vib29rfDEwMjA3MTUwNTYxODYwMjM3IiwiYXVkIjoibzB2V1pXZXJPMW93ejNzVlFBOUdsVmt2VTZ3WGJ2ZzUiLCJleHAiOjE0OTEwNjMwNTYsImlhdCI6MTQ1OTUyNzA1Nn0.LPjw7Xq6XrnWf9y2vSBa3bk0USkjwMakIbU_CZi0m9E"
        static let baseURL     = "https://www.gtwll.io/api/"
        static let queryURL    = "https://www.gtwll.io/api/venues?q="
        static let consumerURL = "https://www.gtwll.io/v/"
        static let historyURL  = "http://bkn-history-api.herokuapp.com/api/clients/"
        static let legalURL    = "http://www.getwellcities.com/legal"
        static let helpURL     = "http://www.getwellcities.com/help"
        static let acknowledgmentURL = "http://www.getwellcities.com/acknowledgments"
        static let hero_mor_URL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1466261557/iosV3/morn.png"
        static let hero_aft_URL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1468440205/iosV3/aft.jpg"
        static let hero_eve_URL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1468440778/iosV3/eve.jpg"
        static let hero_night_URL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1466260781/iosV3/night.jpg"
        static let chatURL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1468440426/iosV3/chat.jpg"
        static let faveURL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1466261038/iosV3/fave.jpg"

    }
    struct Notification {
        static let Region = "RegionImportComplete"
        static let Slider = "SliderImportComplete"
        static let BGMode = "FromBGToFG"
    }
}