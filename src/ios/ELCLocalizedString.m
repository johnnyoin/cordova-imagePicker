#import "ELCLocalizedString.h"

@implementation ELCLocalizedString

+ (NSDictionary *)dictionary {
    static NSDictionary *dict = nil;
    NSString *locale = [[[NSLocale preferredLanguages] objectAtIndex:0] componentsSeparatedByString:@"-"].firstObject;

    if(dict == nil)
    {
        NSDictionary *fr = [NSDictionary dictionaryWithObjectsAndKeys:@"%d sur %d sélectionnées", @"Selected %d of %d",
                            @"%d sélectionnées", @"Selected %d",
                            @"Chargement...", @"Loading...",
                            @"Erreur: %@ - %@", @"Album Error: %@ - %@",
                            @"Sélectionner un album", @"Select an Album",
                            @"Choisir une photo", @"Pick Photo",
                            @"Choisir des photos", @"Pick Photos",
                            @"%d photos maximum.", @"Maximum %d photos.",
                            @"Vous pouvez sélectionner seulement %d photos à la fois.", @"You can only select %d photos at a time.",
                            @"Ok", @"Okay",
                            @"Terminé", @"Done",
                            @"Annuler", @"Cancel",
                            @"Retour", @"Back",
                            @"%d", @"%d",
                            nil];

        dict = [NSDictionary dictionaryWithObjectsAndKeys:fr, @"fr", nil];
    }

    return [dict objectForKey:locale];
}

+ (NSString *)get:(NSString *)key {
    NSDictionary *dictionary = [ELCLocalizedString dictionary];

    if(dictionary == nil)
    {
        return key;
    }

    return [dictionary valueForKey:key];
}

@end