import Foundation

class WNY_DAThumbnailPlugin: NSObject, THOPluginProtocol
{
    let DeviantArtRegex = "http://([a-z0-9_-]+\\.deviantart\\.com/art/[a-z0-9_-]+|" +
        "fav\\.me/[a-z0-9_-]+|" +
        "sta\\.sh/[a-z0-9_-]+|" +
        "|[a-z0-9_-]+\\.deviantart\\.com/[a-z0-9_]+#/d[a-z0-9_-]+)"
    let DeviantArtOEmbed = "http://backend.deviantart.com/oembed?url=%@"
    var regex: NSRegularExpression
    
    func isDeviantArtURL(url: String) -> Bool {
        let rangeOfUrl = NSMakeRange(0, countElements(url))
        let matches = regex.numberOfMatchesInString(url, options: nil, range: rangeOfUrl)
        return matches > 0
    }
    
    func thumbForDeviantArtURL(url: String) -> String? {
        let escaped = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        
        let requestString = String(format: DeviantArtOEmbed, escaped)
        let requestURL = NSURL(string: requestString)!
        let request = NSURLRequest(URL: requestURL)
        var reqError: NSError?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &reqError)
        if reqError != nil || data == nil { return nil }
        var jsonError: NSError?
        let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
        if jsonError == nil && jsonResult != nil && jsonResult.objectForKey("thumbnail_url") != nil {
            return jsonResult["thumbnail_url"]! as? String
        } else {
            return nil
        }
    }
    
    override init() {
        self.regex = NSRegularExpression(pattern: DeviantArtRegex, options: .CaseInsensitive, error: nil)!
        super.init()
    }
    
    func processInlineMediaContentURL(resource: String!) -> String! {
        if isDeviantArtURL(resource) {
            let thumb = thumbForDeviantArtURL(resource)
            if thumb != nil { return thumb! }
        }
        return nil
    }
}
