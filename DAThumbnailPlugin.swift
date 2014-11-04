
/* We create a class that inherits from NSObject so we need Foundation. */
import Foundation

/* As Textual creates a new instance of our primary class when the plugin
loads, it must inherit NSObject to allow proper initialization. */
/* THOPluginProtocol is the protocol available for plugin specific callbacks.
It is appended to our new class object to inform swift that we conform to it.
However, all methods in this class are optional. The plugin does not have to
inherit anyone of them and can instead manipulate using any calls within its
public header files available at /Applications/Textual.app/Contents/Headers/ */
class WNY_DAThumbnailPlugin: NSObject, THOPluginProtocol
{
    let DeviantArtRegex = "http://([a-z0-9_-]+\\.deviantart\\.com/art/[a-z0-9_-]+|" +
        "fav\\.me/[a-z0-9_-]+|" +
        "sta\\.sh/[a-z0-9_-]+|" +
    "|[a-z0-9_-]+\\.deviantart\\.com/[a-z0-9_]+#/d[a-z0-9_-]+)"
    let DeviantArtOEmbed = "http://backend.deviantart.com/oembed?url=%@"
    
    func isDeviantArtURL(url: String) -> Bool {
        var error: NSError?
        let r = NSRegularExpression(pattern: DeviantArtRegex, options: .CaseInsensitive, error: &error)!
        return r.numberOfMatchesInString(url, options: nil, range: NSMakeRange(0, countElements(url))) > 0
    }
    
    func thumbForDeviantArtURL(url: String) -> String? {
        let escaped = url.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        
        let requestString = String(format: DeviantArtOEmbed, escaped)
        let requestURL = NSURL(string: requestString)!
        let request = NSURLRequest(URL: requestURL)
        var reqError: NSError?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &reqError)
        var jsonError: NSError?
        let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
        if jsonResult != nil && jsonResult.objectForKey("thumbnail_url") != nil {
            return jsonResult["thumbnail_url"]! as? String
        } else {
            return nil
        }
    }
    
    func processInlineMediaContentURL(resource: String!) -> String! {
        if isDeviantArtURL(resource) {
            let thumb = thumbForDeviantArtURL(resource)
            if thumb != nil {
                return thumb!
            }
        }
        return nil
    }
}
