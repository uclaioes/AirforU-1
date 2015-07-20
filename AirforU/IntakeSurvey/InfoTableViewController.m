/*!
 * @name        InfoTableViewController.m
 * @version     1.1
 * @copyright   Qingwei Lan (qingweilandeveloper@gmail.com) 2015
 */

#import "InfoTableViewController.h"
#import "GASend.h"
#import "AppDelegate.h"

@interface InfoTableViewController() <UITextFieldDelegate>
@end

@implementation InfoTableViewController

- (IBAction)next:(id)sender
{
    NSString *email = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).userInformation[0];
    NSString *phone = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).userInformation[1];
    NSString *zipcode = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).userInformation[2];
    
    if ([zipcode length] == 5) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:zipcode forKey:@"zipcode"];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).zipcode = zipcode;
    }

    if ([email length] == 0 && [phone length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter either Email Address or Phone Number" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BOOL shouldWarn = NO;
    NSMutableString *warning = [[NSMutableString alloc] initWithCapacity:0];
    
    BOOL emailBad = NO;
    BOOL phoneBad = NO;
    
    if ([email length] != 0 && (![email containsString:@"@"] || ![email containsString:@"."])) {
        shouldWarn = YES;
        emailBad = YES;
        [warning appendString:@"Email Address"];
    }
    
    if ([phone length] != 0 && [phone length] != 10) {
        shouldWarn = YES;
        phoneBad = YES;
        if (emailBad)
            [warning appendString:@"\n"];
        [warning appendString:@"Phone Number"];
    }
    
    if (![zipcode isEqualToString:@""] && [zipcode length] != 5) {
        shouldWarn = YES;
        if (phoneBad || emailBad)
            [warning appendString:@"\n"];
        [warning appendString:@"Zipcode"];
    }
    
    if (shouldWarn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please correct the following" message:warning delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    /* Google Analytics Initialize & Report */
    NSString *identification;
    if (!emailBad && [email length] != 0)
        identification = email;
    else
        identification = phone;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:identification forKey:@"identification"];
        
    if (!emailBad && [email length] != 0)
        [GASend sendEventWithAction:@"Email" withLabel:email];
    if (!phoneBad && [phone length] != 0)
        [GASend sendEventWithAction:@"Phone" withLabel:phone];
    if ([zipcode length] == 5)
        [GASend sendEventWithAction:@"Zipcode" withLabel:zipcode];
    
    
    NSString *segueIdentifier = @"To Question 1";
    [self performSegueWithIdentifier:segueIdentifier sender:sender];
}

#pragma mark - UITableViewControllerDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - IBActions

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    NSString *answer = textField.text;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).userInformation[indexPath.section] = answer;
    NSLog(@"%@", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).userInformation);

}

@end
