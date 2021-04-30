//
//  FeedsHelper.m
//  MPScoreboard2
//
//  Created by David Smith on 2/19/21.
//  Copyright © 2021 MaxPreps Inc. All rights reserved.
//

#import "FeedsHelper.h"

#define kTokenBusterKey @"TokenBuster"
#define kUserDefaults [NSUserDefaults standardUserDefaults]

@implementation FeedsHelper

#pragma mark- Legacy Security Methods

+ (NSString *)getDateCode:(NSTimeInterval)utcOffset
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:utcOffset];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormat setDateFormat:@"MM.dd.yyyy.HH.mm"];
    NSString *dateString = [dateFormat stringFromDate:now];
    return dateString;
}

+ (NSString *)getHashCodeWithPassword:(NSString *)inputstr andDate:(NSString *)date
{
    NSString *hashInput = [NSString stringWithFormat:@"%@%@",inputstr,date];
    
    NSData *data = [hashInput dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    
    if (CC_SHA256(data.bytes, (uint)data.length, hash))
    {
        NSData *sha1 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
        NSData *sha1Base64 = [sha1 base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString *hashString = [[NSString alloc]initWithData:sha1Base64 encoding:NSUTF8StringEncoding];
        return hashString;
    }
    
    return nil;
}

#pragma mark- Configuration Method for multipart request

+ (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

+ (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                              path:(NSString *)path
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    //Add params (all params are strings)
    
    NSError *jsonError;
    NSString *json;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&jsonError];
    /*
    if(jsonError)
    {
        [Utility showAlertViewControllerInWindowWithActionNames:@[@"Ok"] title:kErrorTitle message:jsonError.localizedDescription block:^(int tag) {
            
        }];
    }
    */
    json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *str = [NSMutableString string];
    
    // Add image data
    if (path)
    {
        // Remove the Query parameters
        NSArray *pathArray = [path componentsSeparatedByString:@"?"];
        NSString *fixedPath = [pathArray firstObject];
        
        NSString *filename  = [fixedPath lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        if (data == nil)
        {
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        }
        
        NSString *mimetype;
        if (![path  isEqualToString: @""])
        {
            if ([self mimeTypeForPath:path])
                mimetype  = [self mimeTypeForPath:path];
            else
                mimetype = @"";
        }
        else
        {
            mimetype = @"";
        }
        
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [str appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [str appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [str appendString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype]];
        [httpBody appendData:data];
        [str appendString:@"data"];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [str appendString:@"\r\n"];
        
    }
    
    //Add Json
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [str appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", @"JSON"] dataUsingEncoding:NSUTF8StringEncoding]];
    [str appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", @"JSON"]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"application/json"] dataUsingEncoding:NSUTF8StringEncoding]];
    [str appendString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"application/json"]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n",json] dataUsingEncoding:NSUTF8StringEncoding]];
    [str appendString:[NSString stringWithFormat:@"%@\r\n",json]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [str appendString:[NSString stringWithFormat:@"--%@--", boundary]];
    
    return httpBody;
}

+ (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    // Added in V2.5.0
    // Filter out any Query parameters
    NSArray *pathArray = [[path pathExtension]componentsSeparatedByString:@"?"];
    NSString *extensionComponent = [pathArray firstObject];
    
    CFStringRef extension = (__bridge CFStringRef)extensionComponent;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    //assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

#pragma mark - Encryption Methods

+ (NSString *)encryptString:(NSString *)input
{
    //NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName: kUserDefaultsSuiteName];
    
    NSString *key = @"ShVmYq3t6v9y$B&E)H@McQfTjWnZr4u7";
    NSString *iv = @"Xfk1Pg5Usw9RZLPc";
    
    NSDate *now = [NSDate date];
    
    /*
    NSInteger previousTimeInterval = [[kUserDefault objectForKey:kTokenLastCreatedTimeIntervalKey] integerValue];
    NSTimeInterval currentTimeInterval = [now timeIntervalSinceReferenceDate];
    
    // Use the existing token if 23 hours hasn't elapsed
    if (currentTimeInterval < (previousTimeInterval + (23 * 60 * 60)))
    {
        // Use the saved token instead (If it exists. Could be missing after a logout)
        if ([kUserDefault objectForKey:kLatestTokenValueKey])
        {
            NSLog(@"Saved Token Encrypted Result: %@", [kUserDefault objectForKey:kLatestTokenValueKey]);
            return [kUserDefault objectForKey:kLatestTokenValueKey];
        }
    }
    */
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    //[dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    NSString *dayString = [dateFormat stringFromDate:now];
    NSString *dateString = [NSString stringWithFormat:@"%@ 1:01 AM", dayString];
    
    // Hash the JSON text
    // { \"userId\": \"\", \"createdOn\": \"\", tokenSource=\"teamsapp\" }
    // HeaderName: X-MP-UserToken
    // MM/DD/YYYY HH:MM [AM/PM] // Change to hourly or daily
    // UTC Time
    
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:input, @"userId", dateString, @"createdOn", @"teamsapp", @"tokenSource", nil];
    
    // Added in V2.8.9 to break the token when a user logs in
    if ([kUserDefaults objectForKey:kTokenBusterKey])
    {
        if ([[kUserDefaults objectForKey:kTokenBusterKey] length] > 0)
        {
            // 601411797
            NSString *tokenBusterString = [kUserDefaults objectForKey:kTokenBusterKey];
            payload = [NSDictionary dictionaryWithObjectsAndKeys:input, @"userId", dateString, @"createdOn", @"teamsapp", @"tokenSource", tokenBusterString, @"tokenBuster", nil];
        }
    }
    
    NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:NULL];
    NSString *payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
    
    NSData *dEncrypt = [self doCipher:payloadData key:key iv:iv context:kCCEncrypt];
    
    NSData *base64 = [dEncrypt base64EncodedDataWithOptions:0];
    NSString *encryptString = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    
    // For Testing
    //NSData *decodedBase64 = [[NSData alloc]initWithBase64EncodedData:base64 options:0];
    //NSData *decrypt = [self decrypt:decodedBase64 key:key iv:iv];
    //NSDictionary *dectryptJsonDict = [NSJSONSerialization JSONObjectWithData:decrypt options:0 error:nil];
    
    NSLog(@"Input: %@", input);
    NSLog(@"JSON Payload: %@", payloadString);
    //NSLog(@"Key: %@", key);
    //NSLog(@"Initial Value: %@", iv);
    NSLog(@"Fresh Token Encrypted Result: %@", encryptString);
    
    return encryptString;
}

+ (NSData *)doCipher:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv context:(CCOperation)encryptOrDecrypt
{
    NSUInteger dataLength = [plainText length];
    
    size_t buffSize = dataLength + kCCBlockSizeAES128;
    void *buff = malloc(buffSize);
    
    size_t numBytesEncrypted = 0;
    
    NSData *dIv = [iv dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorStatus status = CCCrypt(encryptOrDecrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     dKey.bytes, kCCKeySizeAES256,
                                     dIv.bytes,
                                     [plainText bytes], [plainText length],
                                     buff, buffSize,
                                     &numBytesEncrypted);
    if (status == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:buff length:numBytesEncrypted];
    }
    
    free(buff);
    return nil;
}

+ (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv
{
    char keyPointer[kCCKeySizeAES256+2],// room for terminator (unused) ref: https://devforums.apple.com/message/876053#876053
    ivPointer[kCCBlockSizeAES128+2];
    
    /*
    BOOL patchNeeded;
    
    patchNeeded = ([key length] > kCCKeySizeAES256+1);
    
    if(patchNeeded)
    {
        NSLog(@"Key length is longer %lu", (unsigned long)[[[StringEncryption alloc] md5:key] length]);
        key = [key substringToIndex:kCCKeySizeAES256]; // Ensure that the key isn't longer than what's needed (kCCKeySizeAES256)
    }
    */
    [key getCString:keyPointer maxLength:sizeof(keyPointer) encoding:NSUTF8StringEncoding];
    [iv getCString:ivPointer maxLength:sizeof(ivPointer) encoding:NSUTF8StringEncoding];
    /*
    if (patchNeeded)
    {
        keyPointer[0] = '\0';  // Previous iOS version than iOS7 set the first char to '\0' if the key was longer than kCCKeySizeAES256
    }
    */
    NSUInteger dataLength = [encryptedText length];

    // For block ciphers, the output size will always be less than or equal to the input size plus the size of one block.
    size_t buffSize = dataLength + kCCBlockSizeAES128;
    
    void *buff = malloc(buffSize);
    
    size_t numBytesEncrypted = 0;

    //Stateless, one-shot encrypt or decrypt operation.
    CCCryptorStatus status = CCCrypt(kCCDecrypt,/* kCCEncrypt, etc. */
                                     kCCAlgorithmAES128, /* kCCAlgorithmAES128, etc. */
                                     kCCOptionPKCS7Padding, /* kCCOptionPKCS7Padding, etc. */
                                     keyPointer, kCCKeySizeAES256,/* key and its length */
                                     ivPointer, /* initialization vector - use same IV which was used for decryption */
                                     [encryptedText bytes], [encryptedText length], //input
                                     buff, buffSize,//output
                                     &numBytesEncrypted);
    if (status == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buff length:numBytesEncrypted];
    }
    
    free(buff);
    return nil;
}

@end
