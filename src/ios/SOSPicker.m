//
//  SOSPicker.m
//  SyncOnSet
//
//  Created by Christopher Sullivan on 10/25/13.
//
//

#import "SOSPicker.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"

#define CDV_PHOTO_PREFIX @"snw_photo_"

@implementation SOSPicker

@synthesize callbackId;

- (void) getPictures:(CDVInvokedUrlCommand *)command {
    NSDictionary *options = [command.arguments objectAtIndex: 0];
    NSInteger maximumImagesCount = [[options objectForKey:@"maximumImagesCount"] integerValue];
    self.useOriginal = [[options objectForKey:@"useOriginal"] boolValue];
    self.createThumbnail = [[options objectForKey:@"createThumbnail"] boolValue];
    self.saveToDataDirectory = [[options objectForKey:@"saveToDataDirectory"] boolValue];
    self.width = [[options objectForKey:@"width"] integerValue];
    self.height = [[options objectForKey:@"height"] integerValue];
    self.quality = [[options objectForKey:@"quality"] integerValue];
    
    // Create the an album controller and image picker
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
    
    if (maximumImagesCount == 1) {
        albumController.immediateReturn = true;
        albumController.singleSelection = true;
    } else {
        albumController.immediateReturn = false;
        albumController.singleSelection = false;
    }
    
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    imagePicker.maximumImagesCount = maximumImagesCount;
    imagePicker.returnsOriginalImage = 1;
    imagePicker.imagePickerDelegate = self;
    
    albumController.parent = imagePicker;
    self.callbackId = command.callbackId;
    // Present modally
    [self.viewController presentViewController:imagePicker
                                      animated:YES
                                    completion:nil];
    // You can run the plugin in background to avoid Xcode warning by putting above code inside the execution block below.
    // But there seems to have a problem with navigation bullet being delayed to appear.
    // [self.commandDelegate runInBackground:^{
    // }];
}


- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    CDVPluginResult* result = nil;
    NSMutableArray *resultStrings = [[NSMutableArray alloc] init];
    Byte *buffer = 0;
    NSUInteger buffered = 0;
    NSData* data = nil;
    NSData* thumbData = nil;
    NSString *docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    if (self.saveToDataDirectory) {
        NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        docsPath = [libPath stringByAppendingPathComponent:@"NoCloud"];
    }
    NSError* err = nil;
    ALAsset* asset = nil;
    UIImageOrientation orientation = UIImageOrientationUp;;
    CGSize targetSize = CGSizeMake(self.width, self.height);
    NSMutableDictionary* photos = [NSMutableDictionary dictionaryWithDictionary:@{}];
    for (NSDictionary *dict in info) {
        asset = [dict objectForKey:@"ALAsset"];
        // From ELCImagePickerController.m
        
        @autoreleasepool {
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            CGImageRef imgRef = NULL;
            
            // modifs luckybird
            NSURL *assetUrl = [assetRep url];
            NSString *assetUrlString = [assetUrl absoluteString];
            NSString *assetFilename = [assetRep filename];

            NSDictionary* photo;
            photo = @{
                @"localURL": assetUrlString,
                @"filename": assetFilename
            };
            [photos setObject:photo forKey:photo[@"localURL"]];
      
        }
        
    }
    
    if (nil == result) {
        //result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultStrings];
        NSArray* photoMsg = [photos allValues];
        NSLog(@"[picker] Sending to phonegap application message with %lu photos",(unsigned long)[photoMsg count]);
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photoMsg];
    }
    
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    CDVPluginResult* pluginResult = nil;
    NSArray* emptyArray = [NSArray array];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:emptyArray];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (UIImage*)imageByScalingNotCroppingForSize:(UIImage*)anImage toSize:(CGSize)frameSize
{
    UIImage* sourceImage = anImage;
    UIImage* newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = frameSize.width;
    CGFloat targetHeight = frameSize.height;
    CGFloat scaleFactor = 0.0;
    CGSize scaledSize = frameSize;

    if (CGSizeEqualToSize(imageSize, frameSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        // opposite comparison to imageByScalingAndCroppingForSize in order to contain the image within the given bounds
        if (widthFactor == 0.0) {
            scaleFactor = heightFactor;
        } else if (heightFactor == 0.0) {
            scaleFactor = widthFactor;
        } else if (widthFactor > heightFactor) {
            scaleFactor = heightFactor; // scale to fit height
        } else {
            scaleFactor = widthFactor; // scale to fit width
        }
        scaledSize = CGSizeMake(width * scaleFactor, height * scaleFactor);
    }

    UIGraphicsBeginImageContext(scaledSize); // this will resize

    [sourceImage drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }

    // pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
