//
//  ViewController.m
//  List
//
//  Created by Yonat Sharon on 12/2/12.
//  Copyright (c) 2012 Roy Sharon Ltd. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate> {
    NSMutableArray *rowsContent;
}
@end

@implementation ViewController

#pragma mark - Table Changes

- (void)deleteRow:(NSIndexPath *)indexPath
{
    [rowsContent removeObjectAtIndex:indexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

- (void)addRow:(NSIndexPath *)indexPath text:(NSString *)text
{
    [rowsContent addObject:text];
    NSIndexPath *nextRow = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextRow] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowsContent.count + 1; // extra one for inserting new row
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"TextCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    UITextField *textField = (UITextField *)[cell viewWithTag:100];
    textField.delegate = self;
    textField.text = indexPath.row < rowsContent.count ? [rowsContent objectAtIndex:indexPath.row] : nil;

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {

        case UITableViewCellEditingStyleDelete: {
            [self deleteRow:indexPath];
            break;
        }
            
        case UITableViewCellEditingStyleInsert: {
            UITableViewCell *sourceCell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *textField = [sourceCell viewWithTag:100];
            [textField becomeFirstResponder];
            break;
        }
            
        case UITableViewCellEditingStyleNone:
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *rowToMove = [rowsContent objectAtIndex:fromIndexPath.row];
    [rowsContent removeObjectAtIndex:fromIndexPath.row];
    [rowsContent insertObject:rowToMove atIndex:toIndexPath.row];
}

#pragma mark - Table View Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < rowsContent.count ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < rowsContent.count;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    UITableViewCell *parentCell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *currRow = [self.tableView indexPathForCell:parentCell];
    NSUInteger cellIndex = currRow.row;
    if (cellIndex < rowsContent.count) {
        if ([textField.text length]) {
            [rowsContent replaceObjectAtIndex:cellIndex withObject:textField.text];
        }
        else {
            [self deleteRow:currRow];
        }
    }
    else if ([textField.text length]) { // new row
        [self addRow:currRow text:textField.text];
    }
	return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	rowsContent = [NSMutableArray arrayWithObjects:@"First note", @"Another one", nil];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
