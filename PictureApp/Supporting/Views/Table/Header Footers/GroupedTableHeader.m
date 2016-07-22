//
//  GroupedTableHeader.m
//  InstagramFollowers
//
//  Created by Michael Orcutt on 12/3/13.
//  Copyright (c) 2013 Michael Orcutt. All rights reserved.
//

#import "GroupedTableHeader.h"

@implementation GroupedTableHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.textLabel           = [[UILabel alloc] init];
        self.textLabel.textColor = [UIColor colorWithRed:146.0/255.0 green:150.0/255.0 blue:156.0/255.0 alpha:1.0];
        self.textLabel.font      = [UIFont fontWithName:@"Ubuntu" size:12.0];

        [self addSubview:self.textLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGRect textLabelFrame;
    textLabelFrame.size.height = [self.textLabel.text sizeWithAttributes:@{ NSFontAttributeName : self.textLabel.font }].height;
    textLabelFrame.origin.x    = 10.0;
    textLabelFrame.origin.y    = (bounds.size.height - textLabelFrame.size.height - 10.0);
    textLabelFrame.size.width  = (bounds.size.width - 20.0);
    
    self.textLabel.frame = textLabelFrame;
}

@end
