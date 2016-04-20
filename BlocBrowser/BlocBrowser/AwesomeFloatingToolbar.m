//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Hanna Xu on 4/17/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *pressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 buttons
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 - 3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            //label.textAlignment = NSTextAlignmentCenter;
            //button.font = [UIFont systemFontOfSize:10];
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            
            //button.text = titleForThisButton;
            [button setTitle:titleForThisButton forState: UIControlStateNormal];
            
            button.backgroundColor = colorForThisButton;
            
            //button.textColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
             [thisButton addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:thisButton];
            [thisButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
    
        }
        // 1
      // self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        // 2
        //[self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressFired:)];
        self.pressGesture.minimumPressDuration = 1.0f;
        self.pressGesture.allowableMovement = 100.0f;
        [self addGestureRecognizer:self.pressGesture];
        
    }
    return self;
}

- (void) layoutSubviews {
    // set frames for 4 buttons
    
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        // adjust buttonx and buttony for each button
        if (currentButtonIndex < 2) {
            // 0 or 1 so on top
            buttonY = 0;
        } else {
            // 2 or 3 so on bottom
            buttonY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentButtonIndex % 2 ==0) {
            // divisable by 2 so on left
            buttonX = 0;
        } else {
            // 1 or 3 so on right
            buttonX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Touch Handling

- (UIButton *) buttonFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    return (UIButton *)subview;
}

- (void) buttonDown:(id)sender  {
    UIButton *button = (UIButton *)sender;
    button.alpha = 0.5;
}

- (void) buttonUp:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
        [self.delegate floatingToolbar:self didSelectButtonWithTitle:button.titleLabel.text];
        button.alpha = 1.0;
    }
}

//- (void) tapFired:(UITapGestureRecognizer *)recognizer {
  //  if (recognizer.state == UIGestureRecognizerStateRecognized) { //3
    //    CGPoint location = [recognizer locationInView:self];  //4
      //  UIView *tappedView = [self hitTest:location withEvent:nil]; //5
        
        //if ([self.buttons containsObject:tappedView]) { //6
          //  if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
//                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).text];
            //}
        //}
    //}
//}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) pinchFired:(UIPinchGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat scale = [recognizer scale];
        
        NSLog(@"New scale: %f", recognizer.scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
        
        [recognizer setScale:1];
    }
}

- (void) pressFired:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        UIColor *pressedView = ((UIButton*)self.buttons[0]).backgroundColor;
        
        for (NSInteger i = 0; i < self.colors.count; i++) {
            UIButton *currentButton = self.buttons[i];
            currentButton.backgroundColor = ((UIButton*)self.buttons[(i+1) % self.colors.count]).backgroundColor;
        
        if (i == (self.colors.count - 1)) {
            ((UIButton*)self.buttons[i]).backgroundColor = pressedView;
        
        NSLog(@"Long Press");
        }
        }
}
}
#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index !=NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : .25;
    }
}

@end
