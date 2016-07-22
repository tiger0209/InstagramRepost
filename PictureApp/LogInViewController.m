//
//  ViewController.m
//  PictureApp
//
//  Created by Lion0324 on 10/19/15.
//  Copyright © 2015 Lion0324. All rights reserved.
//

#import "LogInViewController.h"


@interface LogInViewController ()

@end



@implementation LogInViewController

@synthesize m_LogInBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Welcome";
    float v_radius = self.m_LogInBtn.frame.size.height/2.0f;
    self.m_LogInBtn.layer.cornerRadius = v_radius;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginBtn:(id)sender
{
    
}

@end
