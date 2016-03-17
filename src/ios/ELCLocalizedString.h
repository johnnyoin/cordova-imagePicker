@interface ELCLocalizedString : NSObject

@property NSDictionary *dictionary;

+ (NSDictionary *)dictionary;
+ (NSString *)get:(NSString *)key;

@end