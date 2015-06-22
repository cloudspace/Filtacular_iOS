//
//  CATransformLayer+HideOpaqueWarning.h
//  Filtacular
//
//  Created by Isaac Paul on 6/22/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

/*Hides a strange warning from just loading a nib. The only thing that causes it to appear is setting a custom class for a uiview in the xib file. This happens before it runs any non-sdk code so I'm assuming its a bug.*/
@interface CATransformLayer (HideOpaqueWarning)

@end
