//
//  LoginController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "LoginController.h"
#import "LoginActionCell.h"
#import "LoginInputCell.h"

@interface LoginController () <LoginActionCellDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *loginSegment;

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.loginSegment.selectedSegmentIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginSegmentChanged:(id)sender
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.loginSegment.selectedSegmentIndex == 0 ? 2 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.loginSegment.selectedSegmentIndex == 0)
        return section == 0 ? 2 : 1;
    else
        return section == 0 ? 3 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.loginSegment.selectedSegmentIndex == 0)
    {
        if (indexPath.section == 0)
        {
            LoginInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inputCell"];
            if (indexPath.row == 0)
            {
                cell.inputTitle.text = @"User ID";
                cell.inputContent.placeholder = @"Please input your user name";
                cell.inputContent.keyboardType = UIKeyboardTypeASCIICapable;
                cell.inputContent.secureTextEntry = NO;
            }
            else
            {
                cell.inputTitle.text = @"Password";
                cell.inputContent.placeholder = @"Please input your password";
                cell.inputContent.keyboardType = UIKeyboardTypeASCIICapable;
                cell.inputContent.secureTextEntry = YES;
            }
            return cell;
        }
        else
        {
            LoginActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            cell.tag = 0;
            cell.delegate = self;
            cell.actionButton.layer.cornerRadius = 4.0f;
            [cell.actionButton setTitle:@"LOGIN" forState:UIControlStateNormal];
            return cell;
        }
    }
    else
    {
        if (indexPath.section == 0)
        {
            LoginInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inputCell"];
            if (indexPath.row == 0)
            {
                cell.inputTitle.text = @"User ID";
                cell.inputContent.placeholder = @"Please input your user name";
                cell.inputContent.keyboardType = UIKeyboardTypeASCIICapable;
                cell.inputContent.secureTextEntry = NO;
            }
            else if (indexPath.row == 1)
            {
                cell.inputTitle.text = @"Password";
                cell.inputContent.placeholder = @"Please input your password";
                cell.inputContent.keyboardType = UIKeyboardTypeASCIICapable;
                cell.inputContent.secureTextEntry = YES;
            }
            else if (indexPath.row == 2)
            {
                cell.inputTitle.text = @"Confirm";
                cell.inputContent.placeholder = @"Repeat your password";
                cell.inputContent.keyboardType = UIKeyboardTypeASCIICapable;
                cell.inputContent.secureTextEntry = YES;
            }
            return cell;
        }
        else
        {
            LoginActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
            cell.tag = 1;
            cell.delegate = self;
            cell.actionButton.layer.cornerRadius = 4.0f;
            [cell.actionButton setTitle:@"REGISTRATION" forState:UIControlStateNormal];
            return cell;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Welcome to Magicard!";
    else
        return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        cell.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 44.0f;
    return 55.0f;
}

#pragma mark - LoginActionCellDelegate

- (void)actionExeicute:(LoginActionCell *)cell
{
    if (cell.tag == 0)
        [self performSegueWithIdentifier:@"loginSuccess" sender:cell];
    else if (cell.tag == 1)
    {
        [self.loginSegment setSelectedSegmentIndex:0];
        [self.tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
