import Foundation

class WNY_DAThumbnailPlugin: NSObject, THOPluginProtocol
{
    let DeviantArtRegex = "http://([a-z0-9_-]+\\.deviantart\\.com/art/[a-z0-9_-]+|" +
        "fav\\.me/[a-z0-9_-]+|" +
        "sta\\.sh/[a-z0-9_-]+|" +
        "|[a-z0-9_-]+\\.deviantart\\.com/[a-z0-9_]+#/d[a-z0-9_-]+)"
    let DeviantArtOEmbed = "https://backend.deviantart.com/oembed?url=%@"
    var regex: NSRegularExpression
    
    override init() {
        self.regex = NSRegularExpression(pattern: DeviantArtRegex, options: .CaseInsensitive, error: nil)!
        super.init()
    }
    
    func isDeviantArtURL(url: String?) -> Bool {
        if let unwrapped = url {
            let rangeOfUrl = NSMakeRange(0, countElements(unwrapped))
            let matches = regex.numberOfMatchesInString(unwrapped, options: nil, range: rangeOfUrl)
            return matches > 0
        }
        return false
    }

    func thumbForDeviantArtURL(url: String) -> String? {
        if let req = buildDAEmbedRequest(url) {
            if let data = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: nil) {
                if let res = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary {
                    return res.objectForKey("thumbnail_url") as? String
                }
            }
        }
        return nil
    }
    
    func buildDAEmbedRequest(url: String?) -> NSURLRequest? {
        if let unwrapped = url {
            if let escaped = unwrapped.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
                let urlString = String(format: DeviantArtOEmbed, escaped)
                if let u = NSURL(string: urlString) {
                    return NSURLRequest(URL: u)
                }
            }
        }
        return nil
    }
    
    func processInlineMediaContentURL(resource: String!) -> String! {
        if let r = resource {
            if isDeviantArtURL(r) {
                if let thumb = thumbForDeviantArtURL(r) {
                    return thumb
                }
            }
        }
        return nil
    }
}
