//
//  KeyboardAccessoryView.m
//  Rosenthal
//
//  Created by Ion Postolachi on 8/23/17.
//  Copyright © 2017 Rosenthal. All rights reserved.
//

#import "KeyboardAccessoryView.h"

@implementation KeyboardAccessoryView {
    IBOutlet UIButton *upButtonOutlet;
    IBOutlet UIButton *downButtonOutlet;
}

-(void)setTextfields:(NSArray *)textfields{
    _textfields = textfields;
    
    [textfields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(inputAccessoryView)]) {
            @try {
                [obj setInputAccessoryView:self];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
            } @catch (NSException *exception) {}
        }
    }];
}

- (void)keyboardDidShow:(NSNotification *)notification{
    __block NSUInteger index = 0;
    
    [_textfields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(isEditing)]) {
            @try {
                if ([obj isEditing]) {
                    index = idx;
                    *stop = YES;
                }
            } @catch (NSException *exception) {}
        }
    }];
    
    if (index == 0) {
        upButtonOutlet.enabled = false;
        downButtonOutlet.enabled = true;
    }else if (index == _textfields.count - 1) {
        upButtonOutlet.enabled = true;
        downButtonOutlet.enabled = false;
    }else{
        upButtonOutlet.enabled = true;
        downButtonOutlet.enabled = true;
    }
}

- (IBAction)upButtonAction:(UIButton *)sender {
    NSInteger idx = [self currentIndex] - 1;
    
    if (idx <= 0) {
        idx = 0;
    }
    
    if ([_textfields[idx] respondsToSelector:@selector(becomeFirstResponder)]) {
        @try {
           [_textfields[idx] becomeFirstResponder];
        } @catch (NSException *exception) {}
    }
}

- (IBAction)downButtonAction:(UIButton *)sender {
    NSInteger idx = [self currentIndex] + 1;
    
    if (idx >= _textfields.count - 1) {
        idx = _textfields.count - 1;
    }
    
    if ([_textfields[idx] respondsToSelector:@selector(becomeFirstResponder)]) {
        @try {
            [_textfields[idx] becomeFirstResponder];
        } @catch (NSException *exception) {}
    }
}

- (IBAction)doneButtonAction:(UIButton *)sender {
    for (id textfield in _textfields) {
        if ([textfield respondsToSelector:@selector(resignFirstResponder)]) {
            @try {
                [textfield resignFirstResponder];
            } @catch (NSException *exception) {}
        }
    }
}

-(NSInteger)currentIndex{
    __block NSInteger index = 0;
    [_textfields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(isEditing)]) {
            @try {
                if ([obj isEditing]) {
                    index = idx;
                }
            } @catch (NSException *exception) {}
        }
    }];
    
    return index;
}
@end
