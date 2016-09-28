//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"

@interface ELCAssetCell ()

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;
@property (nonatomic, assign) CGFloat assetDimension;
@property (nonatomic, assign) int assetPadding;

@end

@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
	}
	return self;
}

- (void)setAssets:(NSArray *)assets withDimension:(CGFloat)dimension withPadding:(int)padding
{
    self.assetDimension = dimension;
    self.assetPadding = padding;
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (UIImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {

        ELCAsset *asset = [_rowAssets objectAtIndex:i];

        if (i < [_imageViewArray count]) {
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.image = [UIImage imageWithCGImage:asset.asset.aspectRatioThumbnail];
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.aspectRatioThumbnail]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imageViewArray addObject:imageView];
        }
        
        if (i < [_overlayViewArray count]) {
            UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
        } else {
            if (overlayImage == nil) {
                overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            UIImageView *overlayView = [[UIImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
        }
    }
}

- (void)toggleOverlay:(int)index
{
    ELCAsset *asset = [_rowAssets objectAtIndex:index];
    UIImageView *overlayView = [_overlayViewArray objectAtIndex:index];
    overlayView.hidden = !asset.selected;
    if ([self.parent respondsToSelector:@selector(updateCounter)]) {
        [self.parent updateCounter];
    }
}

- (void)toggleOverlays
{
    for (int i = 0; i < [_rowAssets count]; ++i) {
        [self toggleOverlay:i];
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    CGFloat startX = self.assetPadding / 2;
    
	CGRect frame = CGRectMake(startX, self.assetPadding / 2, self.assetDimension, self.assetDimension);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            [self toggleOverlay:i];
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + self.assetPadding;
    }
}

- (void)layoutSubviews
{    
    CGFloat startX = self.assetPadding / 2;
    
	CGRect frame = CGRectMake(startX, self.assetPadding / 2, self.assetDimension, self.assetDimension);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        UIImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width + self.assetPadding;
	}
}


@end
