import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://calyveriona193.site/privacy/219"
    case termsOfUse = "https://calyveriona193.site/terms/219"

    var url: URL? {
        URL(string: rawValue)
    }
}
