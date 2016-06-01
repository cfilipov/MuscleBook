//
//  EFCalendarGraph.m
//  EFCalendarGraph
//
//  Created by Eliot Fowler on 7/6/15.
//
//

#import "EFCalendarGraph.h"
#import "NSDate+Utilities.h"

const CGFloat EFCalendarGraphMinBoxSideLength = 3;
const CGFloat EFCalendarGraphInterBoxMargin = 1;
const NSInteger EFCalendarGraphDaysInWeek = 7;

@interface EFCalendarGraph () <EFCalendarGraphDataSource>

// Public properties
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;

// Private properties

@property (nonatomic, strong) NSArray *layers;
@property (nonatomic, strong) NSArray *dataByColumns;
@property (nonatomic, strong) NSArray *layersByColumns;
@property (nonatomic, strong) NSDate *endDate;
//@property (nonatomic, strong) NSArray *values;

@property (nonatomic, assign, readonly) CGFloat minWidth;
@property (nonatomic, assign, readonly) CGFloat minHeight;
@property (nonatomic, assign, readonly) CGRect frameForViewInBounds;
@property (nonatomic, assign, readonly) CGSize boxSize;
@property (nonatomic, assign, readonly) NSInteger columns;
@property (nonatomic, assign, readonly) NSInteger rows;
@property (nonatomic, strong, readonly) id minValue;
@property (nonatomic, strong, readonly) id maxValue;

@end

@implementation EFCalendarGraph {
    NSDate *_startDate;
    id _minValue;
    id _maxValue;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithStartDate:nil];
    return self;
}

- (instancetype)initWithStartDate:(NSDate *)startDate
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        _startDate = startDate;
        [self initialize];
    }
    return self;
}

- (instancetype)initWithEndDate:(NSDate *)endDate
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        _endDate = endDate;
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // Defaults
//    self.backgroundColor = [UIColor redColor];
    
    if (!self.borderColor)
    {
        self.borderColor = [UIColor blackColor];
    }

    if (!self.borderWidth)
    {
        self.borderWidth = 2;
    }
    
    if (!self.zeroColor)
    {
        self.zeroColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.5];
    }
    
    if (!self.baseColor)
    {
        self.baseColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    }
    
    if (!self.squareModifier)
    {
        self.squareModifier = EFCalendarGraphSquareModifierAlpha;
    }
    
    if (!self.modifierDenominations)
    {
        self.modifierDenominations = @[@.3, @.4, @.5, @.6, @.7, @.9];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    for (int i = 0; i < self.layers.count; i++)
    {
        CALayer *layer = self.layers[i];
        layer.frame = [self rectForBoxWithDaysAfterStartDate:i];
    }
}

#pragma mark - Overrides

- (void)setStartDate:(NSDate *)startDate
{
    _startDate = startDate;
    [self reloadData];
}

- (NSDate *)startDate
{
    if (!_startDate && _endDate)
    {
        NSUInteger numberOfDataPoints = [self.dataSource numberOfDataPointsInCalendarGraph:self];
        _startDate = [_endDate dateBySubtractingDays:numberOfDataPoints-1];
    }
    return _startDate;
}

- (NSArray *)dataByColumns
{
    if (!_dataByColumns)
    {
        NSMutableArray *columnData = [NSMutableArray array];
        NSUInteger numberOfDataPoints = [self.dataSource numberOfDataPointsInCalendarGraph:self];
        for (int i = 0; i < numberOfDataPoints / EFCalendarGraphDaysInWeek; i++)
        {
            NSMutableArray *rowData = [NSMutableArray array];
            for (int j = 0; j < EFCalendarGraphDaysInWeek; j++)
            {
                id dataPoint = [self valueForDaysAfterStartDate:i * EFCalendarGraphDaysInWeek + j];
                [rowData addObject:dataPoint];
            }
            [columnData addObject:rowData];
        }
        
        _dataByColumns = [columnData copy];
    }
    
    return _dataByColumns;
}

- (CGSize)contentSize
{
    return CGSizeMake(CGRectGetWidth([self frameForViewInBounds]), CGRectGetHeight([self frameForViewInBounds]));
}

#pragma mark - Public methods

- (void)reloadData
{
#if !TARGET_INTERFACE_BUILDER
    _dataByColumns = nil;
#endif
    
    for(CALayer *layer in self.layer.sublayers)
    {
        [layer removeFromSuperlayer];
    }
    
    NSMutableArray *layers = [NSMutableArray array];
    NSMutableArray *layersByColumns = [NSMutableArray array];
    for (int i = 0; i < self.dataByColumns.count; i++)
    {
        NSMutableArray *column = [NSMutableArray array];
        for (int j = 0; j < EFCalendarGraphDaysInWeek; j++)
        {
            CALayer *layer = [CALayer layer];
            CGRect boxFrame = [self rectForBoxWithDaysAfterStartDate:i * EFCalendarGraphDaysInWeek + j];
            layer.frame = boxFrame;
            
            CGFloat value = [self.dataByColumns[i][j] floatValue];
            if (value > 0)
            {
                CGFloat maxValue = [self.maxValue floatValue];
                CGFloat minValue = [self.minValue floatValue];
                CGFloat valuePerDenomination = ((maxValue - minValue + 1) / self.modifierDenominations.count);
                NSUInteger denominationIndex = value / valuePerDenomination - 1;
                CGFloat alpha = [self.modifierDenominations[denominationIndex] floatValue];
                layer.backgroundColor = [self.baseColor colorWithAlphaComponent:alpha].CGColor;
            }
            else
            {
                layer.backgroundColor = self.zeroColor.CGColor;
            }
            [self.layer addSublayer:layer];
            [layers addObject:layer];
            [column addObject:layer];
        }
        [layersByColumns addObject:column];
    }
    
    self.layers = [layers copy];
    self.layersByColumns = [layersByColumns copy];
    
    if (self.automaticallyAdjustsFrameToContent)
    {
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), self.contentSize.width, self.contentSize.height);
    }
}

#pragma mark - Helpers

- (CGRect)rectForBoxWithDaysAfterStartDate:(NSInteger)daysAfterStartDate
{
    CGRect frame = self.frameForViewInBounds;
    NSInteger column = [self columnForDaysAfterStartDate:daysAfterStartDate];
    NSInteger row = [self rowForDaysAfterStartDate:daysAfterStartDate];
    CGFloat x = CGRectGetMinX(frame) +
                self.boxSize.width * column +
                EFCalendarGraphInterBoxMargin * column +
                self.borderWidth;
    CGFloat y = CGRectGetMinY(frame) +
                self.boxSize.height * row +
                EFCalendarGraphInterBoxMargin * row +
                self.borderWidth;
    return CGRectMake(x, y, self.boxSize.width, self.boxSize.height);
}

- (NSInteger)columnForDaysAfterStartDate:(NSInteger)daysAfterStartDate
{
    // 1 is Sunday and I want 0 to be Sunday
    NSInteger startDateWeekOffset = self.startDate.weekday - 1;
    return (daysAfterStartDate + startDateWeekOffset) / EFCalendarGraphDaysInWeek;
}

- (NSInteger)rowForDaysAfterStartDate:(NSInteger)daysAfterStartDate
{
    NSDate *rowDate = [self.startDate dateByAddingDays:daysAfterStartDate];
    
    // 1 is Sunday and I want 0 to be Sunday
    return rowDate.weekday - 1;
}

- (id)valueForDaysAfterStartDate:(NSUInteger)daysAfterStartDate
{
    NSDate *date = [self.startDate dateByAddingDays:daysAfterStartDate];
    NSUInteger daysBeforeEnd = [date daysBeforeDate:self.endDate];
    return [self.dataSource calendarGraph:self valueForDate:date
                       daysAfterStartDate:daysAfterStartDate
                        daysBeforeEndDate:daysBeforeEnd];
}

#pragma mark - Read-only property getters

- (CGRect)frameForViewInBounds
{
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        return CGRectZero;
    }
    
    CGFloat width = self.minWidth;
    CGFloat height = self.minHeight;
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (width > height && width < CGRectGetWidth(self.bounds))
    {
        width = CGRectGetWidth(self.bounds);
        CGFloat boxWidth = [self boxWidthBasedOnBoundsWidth:width];
        height = 2 * self.borderWidth +
                 EFCalendarGraphDaysInWeek * boxWidth +
                 (self.rows - 1) * EFCalendarGraphInterBoxMargin;
    }
    else if (height > width && height < CGRectGetHeight(self.bounds))
    {
        height = CGRectGetHeight(self.bounds);
        CGFloat boxHeight = [self boxHeightBasedOnBoundsHeight:height];
        width = 2 * self.borderWidth +
                self.columns * boxHeight +
                self.columns - 1 * EFCalendarGraphInterBoxMargin;
    }
    
    // Now that we know for sure that one of the edges is touching its bounds edge,
    // we need to check again if one of the edges is still off so we can center in
    // that dimension
    if (width < CGRectGetWidth(self.bounds))
    {
        CGFloat widthDifference = CGRectGetWidth(self.bounds) - width;
        x = widthDifference/2;
    }
    else if (height < CGRectGetHeight(self.bounds))
    {
        CGFloat heightDifference = CGRectGetHeight(self.bounds) - height;
        y = heightDifference/2;
    }
    
    return CGRectMake(x, y, width, height);
}

- (CGFloat)boxWidthBasedOnBoundsWidth:(CGFloat)width
{
    return MAX((width -
                EFCalendarGraphInterBoxMargin * (self.columns - 1) -
                self.borderWidth * 2) / self.columns, EFCalendarGraphMinBoxSideLength);
}

- (CGFloat)boxHeightBasedOnBoundsHeight:(CGFloat)height
{
    return MAX((height -
                EFCalendarGraphInterBoxMargin * (self.rows - 1) -
                self.borderWidth * 2) / self.rows, EFCalendarGraphMinBoxSideLength);
}

- (CGSize)boxSize
{
    CGRect frame = self.frameForViewInBounds;
    CGFloat width = [self boxWidthBasedOnBoundsWidth:CGRectGetWidth(frame)];
    CGFloat height = [self boxHeightBasedOnBoundsHeight:CGRectGetHeight(frame)];

    NSAssert(fabs(width - height) < .01, @"Box not square; width: %f, height: %f", width, height);
    
    return CGSizeMake(width, height);
}

- (CGFloat)minWidth
{
    return 2 * self.borderWidth +
           self.dataByColumns.count * EFCalendarGraphMinBoxSideLength +
           self.dataByColumns.count - 1 * EFCalendarGraphInterBoxMargin;
}

- (CGFloat)minHeight
{
    return 2 * self.borderWidth +
           EFCalendarGraphDaysInWeek * EFCalendarGraphMinBoxSideLength +
           (EFCalendarGraphDaysInWeek - 1) * EFCalendarGraphInterBoxMargin;
}

- (NSInteger)columns
{
    return [self columnForDaysAfterStartDate:(self.dataByColumns.count - 1) * EFCalendarGraphDaysInWeek + EFCalendarGraphDaysInWeek - 1] + 1;
}

- (NSInteger)rows
{
    return EFCalendarGraphDaysInWeek;
}

- (id)minValue
{
    if (!_minValue)
    {
        id minValue = @(MAXFLOAT);
        NSUInteger numberOfDataPoints = [self.dataSource numberOfDataPointsInCalendarGraph:self];
        for (int i = 0; i < numberOfDataPoints; i++)
        {
            id value = [self valueForDaysAfterStartDate:i];
            if ([value floatValue] < [minValue floatValue] && [value floatValue] > 0)
            {
                minValue = value;
            }
        }
        _minValue = minValue;
    }
    
    return _minValue;
}

- (id)maxValue
{
    if (!_maxValue)
    {
        id maxValue = @(0);
        NSUInteger numberOfDataPoints = [self.dataSource numberOfDataPointsInCalendarGraph:self];
        for (int i = 0; i < numberOfDataPoints; i++)
        {
            id value = [self valueForDaysAfterStartDate:i];
            if ([value floatValue] > [maxValue floatValue])
            {
                maxValue = value;
            }
        }
        _maxValue = maxValue;
    }
    
    return _maxValue;
}

#pragma mark - For Storyboards

- (void)prepareForInterfaceBuilder
{
    // Fake Data
    NSMutableArray *values = [NSMutableArray array];
    for (int i = 0; i < 365; i++)
    {
        [values addObject:arc4random() % 2 == 0 ? @0 : @(arc4random() % 5)];
    }
    
    NSMutableArray *columnData = [NSMutableArray array];
    for (int i = 0; i < values.count / EFCalendarGraphDaysInWeek; i++)
    {
        NSMutableArray *rowData = [NSMutableArray array];
        for (int j = 0; j < EFCalendarGraphDaysInWeek; j++)
        {
            id dataPoint = values[i * EFCalendarGraphDaysInWeek + j];
            [rowData addObject:dataPoint];
        }
        [columnData addObject:rowData];
    }
    
    self.dataByColumns = [columnData copy];
    
    self.dataSource = self;
    [self reloadData];
}

- (id)calendarGraph:(EFCalendarGraph *)calendarGraph valueForDate:(NSDate *)date daysAfterStartDate:(NSUInteger)daysAfterStartDate daysBeforeEndDate:(NSUInteger)daysBeforeEndDate
{
    NSUInteger i = daysAfterStartDate / EFCalendarGraphDaysInWeek;
    NSUInteger j = daysAfterStartDate % EFCalendarGraphDaysInWeek;
    return self.dataByColumns[i][j];
}

- (NSUInteger)numberOfDataPointsInCalendarGraph:(EFCalendarGraph *)calendarGraph
{
    return self.dataByColumns.count;
}

@end
