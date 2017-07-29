//
//  OpneCVWrapper.m
//  Anliven
//
//  Created by Chirag Desai on 7/28/17.
//  Copyright © 2017 Chirag Desai. All rights reserved.
//

#import "OpneCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>


@implementation OpneCVWrapper

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (UIImage*)matchTemplate:(UIImage*)templateImage in:(UIImage*)src {
    // http://opencv-code.com/quick-tips/how-to-handle-template-matching-with-multiple-occurences/
    cv::Mat ref,tpl,gref, gtpl;
//    UIImageToMat(src, ref);
//    UIImageToMat(templateImage, tpl);
    ref = [self cvMatWithImage:src];
    tpl = [self cvMatWithImage:templateImage];
    cv::cvtColor(ref, gref, CV_RGB2GRAY);
    cv::cvtColor(tpl, gtpl, CV_RGB2GRAY);
    
    cv::Mat res(ref.rows+1, ref.cols+1, CV_32FC1);
    cv::matchTemplate(gref, gtpl, res, CV_TM_CCOEFF_NORMED);
    cv::threshold(res, res, 0.7, 1., CV_THRESH_TOZERO);
    
    int count = 0;
    while (true)
    {
        double minval, maxval, threshold = 0.7;
        cv::Point minloc, maxloc;
        cv::minMaxLoc(res, &minval, &maxval, &minloc, &maxloc);
        
        if (maxval >= threshold)
        {
            cv::rectangle(
                          ref,
                          maxloc,
                          cv::Point(maxloc.x + tpl.cols, maxloc.y + tpl.rows),
                          CV_RGB(0,255,0), 2
                          );
            cv::floodFill(res, maxloc, cv::Scalar(0), 0, cv::Scalar(.1), cv::Scalar(1.));
            count++;
        }
        else
            break;
    }
    
    NSLog(@"# of matches: %d", count);
    UIImage *result = [self UIImageFromCVMat:gtpl];
    return count? result:nil;
}

+ (cv::Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpace);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    
    // check whether the UIImage is greyscale already
    if (numberOfComponents == 1){
        cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,             // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    bitmapInfo);              // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
                      
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
                          NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
                          
                          CGColorSpaceRef colorSpace;
                          CGBitmapInfo bitmapInfo;
                          
                          if (cvMat.elemSize() == 1) {
                              colorSpace = CGColorSpaceCreateDeviceGray();
                              bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
                          } else {
                              colorSpace = CGColorSpaceCreateDeviceRGB();
                              bitmapInfo = kCGBitmapByteOrder32Little | (
                                                                         cvMat.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst
                                                                         );
                          }
                          
                          CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
                          
                          // Creating CGImage from cv::Mat
                          CGImageRef imageRef = CGImageCreate(
                                                              cvMat.cols,                 //width
                                                              cvMat.rows,                 //height
                                                              8,                          //bits per component
                                                              8 * cvMat.elemSize(),       //bits per pixel
                                                              cvMat.step[0],              //bytesPerRow
                                                              colorSpace,                 //colorspace
                                                              bitmapInfo,                 // bitmap info
                                                              provider,                   //CGDataProviderRef
                                                              NULL,                       //decode
                                                              false,                      //should interpolate
                                                              kCGRenderingIntentDefault   //intent
                                                              );
                          
                          // Getting UIImage from CGImage
                          UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
                          CGImageRelease(imageRef);
                          CGDataProviderRelease(provider);
                          CGColorSpaceRelease(colorSpace);
                          
                          return finalImage;
}


@end
