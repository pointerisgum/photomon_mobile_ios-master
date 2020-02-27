//
//  Collage.m
//  PhotoMon
//
//  Created by 경현 이 on 2015. 12. 25..
//  Copyright © 2015년 LeeKyunghyun. All rights reserved.
//

#import "Collage.h"
#import "Util.h"


// Animation이 일어나는 기간
//
#define AnimationDuration   (0.3f)


@implementation Collage


#pragma mark - Initialize

// 초기화
//
- (void)initialize
{
    // 기본 속성
    //
    self.backgroundColor = [UIColor blackColor];
    _ratio = CGSizeMake(1.f, 1.f);
    
    
    // Main container를 생성한다.
    //
    _mainContainer = [[UIView alloc] initWithFrame:self.bounds];
    _mainContainer.backgroundColor = [UIColor whiteColor];
    _mainContainer.autoresizesSubviews = NO;
    _mainContainer.clipsToBounds = NO;
    [self addSubview:_mainContainer];
    
    
    // Cell list를 생성한다.
    //
    _cellList = [[NSMutableArray alloc] init];
    
    
    // 셀간 이동을 위한 제스쳐 등록
    //
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(panGestureListener:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [_mainContainer addGestureRecognizer:panGesture];
    
    
    // 셀 선택을 확인하기 위한 제스쳐 등록
    //
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapGestureListener:)];
    [_mainContainer addGestureRecognizer:tapGesture];
}

// XIB또는 Storyboard로 생성되는 경우 이 초기화 함수가 호출된다.
//
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        [self initialize];
    }
    
    return self;
}


// InitWithFrame, Code로 직접 생성
//
- (instancetype)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [self initialize];
    }
    
    return self;
}


// Initialize with representation
//  Template으로 복원
- (instancetype)initWithRepresentation:(NSDictionary *)representation
{
    if( self = [super init] )
    {
        [self initialize];
        
        
        // 셀간 거리 값
        //
        _cellPadding = [representation[CollageDataKey_CellPadding] floatValue];
        
        
        // Cell list를 복원한다.
        //
        for( NSDictionary *cellRep in representation[CollageDataKey_CellList] )
        {
            Cell *cell = [[Cell alloc] initWithRepresentation:cellRep];
            cell.collage = self;
            [_mainContainer addSubview:cell];
            [_cellList addObject:cell];
        }
        
        
        // 너비/높이 Ratio
        //
        _ratio = CGSizeFromString(representation[CollageDataKey_Ratio]);
        
        
        // BG Color
        //
        NSArray *bgColors = representation[CollageDataKey_BGColor];
        _mainContainer.backgroundColor = [UIColor colorWithRed:([bgColors[0] floatValue] / 255.f)
                                                         green:([bgColors[1] floatValue] / 255.f)
                                                          blue:([bgColors[2] floatValue] / 255.f)
                                                         alpha:1.f];
        
        
        // Layout을 적용한다.
        //
        self.layout = [representation[CollageDataKey_Layout] integerValue];
        
        
        // 셀 corner radius
        //
        self.cellCornerRadius = [representation[CollageDataKey_CellCornerRadius] floatValue];
        
        
        self.inch = representation[CollageDataKey_Inch];
    }
    
    return self;
}


#pragma mark - Layout


// Layout이 변경되면 cell layout을 다시 잡아줘야 한다.
//
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    // Main container의 위치를 잡는다.
    //  정수형으로 소수점을 잘라낸다.
    CGRect rect = aspectFitRect(_ratio, self.bounds);
    rect.origin.x = (int)rect.origin.x;
    rect.origin.y = (int)rect.origin.y;
    rect.size.width = (int)rect.size.width;
    rect.size.height = (int)rect.size.height;
    _mainContainer.frame = rect;
    
    
    // Layout을 업데이트 한다.
    //
    [self applyCurrentLayout:NO];
    
    return;
}


// Layout setter
//
//  self.layout = xxx 로 불릴때마다 이 함수가 호출된다.
//
- (void)setLayout:(CollageLayout)layout
{
    // Setter를 직접 호출한 경우에는 animation을 적용하지 않는다.
    //
    [self setLayout:layout animate:NO];
}


// Layout을 적용하고, animate를 할지 결정한다.
//
- (void)setLayout:(CollageLayout)layout animate:(BOOL)animate
{
    // 변환된 레이아웃을 저장
    //
    _layout = layout;
    
    // Cell이 없을때에는 아무런 처리를 하지 않는다.
    //
    if( !_cellList.count )
        return;
    
    // 레이 아웃을 적용한다.
    //
    [self applyCurrentLayout:animate];
}


// 현재 Layout을 적용한다.
//
- (void)applyCurrentLayout:(BOOL)animate
{
    // Exception
    //  셀이 없으면 더 진행할 필요가 없다.
    if( !_cellList.count )
        return;

    
    // Animation 중에는 corner radius를 자연스럽게 애니매이션 하는것은 불가능하다.
    // 그래서 0으로 설정한 이후 애니매이션이 끝나면 corner radius를 다시 설정하도록 한다.
    // (Shutterfly도 동일하게 처리한다.)
    if( animate && _cellCornerRadius > 0.f )
    {
        float cornerRadius = self.cellCornerRadius;
        self.cellCornerRadius = 0.f;
        _cellCornerRadius = cornerRadius;
    }
    
    
    // Animate 여부 확인
    //
    float duration = animate ? AnimationDuration : 0.f;

    
    // duration 동안 딜레이 없이 애니매이션을 수행하도록 한다.
    //  각각의 옵션들의 기능은 직접 익혀보시길 바랍니다.
    //
    [UIView animateWithDuration:duration
                          delay:0.01f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         // Layout 별로 처리한다.
                         //
                         switch (_layout)
                         {
                             case CollageLayout_1:
                                 [self applyLayout1];
                                 break;
                                 
                             case CollageLayout_2:
                                 [self applyLayout2];
                                 break;
                                 
                             case CollageLayout_3:
                                 [self applyLayout3];
                                 break;
                                 
                             case CollageLayout_4:
                                 [self applyLayout4];
                                 break;
                                 
                             default:
                                 break;
                         }
                         
                     } completion:^(BOOL finished) {
                         
                         // 원래 cell corner radius로 복원한다.
                         //
                         if( finished && animate && self.cellCornerRadius > 0.f )
                         {
                             self.cellCornerRadius = _cellCornerRadius;
                         }
                         
                         [self.delegate completeCollage];
                     }];
}


// Layout1을 적용한다.
//
- (void)applyLayout1
{
    // Sutterfly의 정확한 rule을 파악하기 힘들어서 약간 상이하게 구현하였음
    //
    
    // 4개 이하일 경우에는 Layout2와 동일하게 배치한다.
    //
    if( _cellList.count <= 4 )
    {
        // 역순으로 집어넣는다.
        //
        NSArray *reverseArray = [[_cellList reverseObjectEnumerator] allObjects];
        [self layout1SubLayout:reverseArray andRect:_mainContainer.bounds];
    }
    else
    {
        NSMutableArray *leftUpLayout = [NSMutableArray array];
        NSMutableArray *rightUpLayout = [NSMutableArray array];
        NSMutableArray *leftDownLayout = [NSMutableArray array];
        NSMutableArray *rightDownLayout = [NSMutableArray array];
        
        
        // 처음에 하나씩 넣는다.
        //
        [leftUpLayout addObject:_cellList[0]];
        [rightUpLayout addObject:_cellList[1]];
        [leftDownLayout addObject:_cellList[2]];
        [rightDownLayout addObject:_cellList[3]];
        
        
        // 초기에 분할된 칸에 4개씩 넣고
        // 그래도 꽉 차면 4개씩 증가하면서 넣도록 한다.
        int count = 4;
        for( int i = 4 ; i < _cellList.count ; i++ )
        {
            // 왼쪽 위 부터 분할한다
            //
            if( leftUpLayout.count < count )
                [leftUpLayout addObject:_cellList[i]];
            
            // 그 다음은 오른쪽 아래를 분할한다.
            //
            else if( rightDownLayout.count < count )
                [rightDownLayout addObject:_cellList[i]];
            
            // 그 다음은 오른쪽 위를 분할한다.
            //
            else if( rightUpLayout.count < count )
                [rightUpLayout addObject:_cellList[i]];
            
            // 마지막으로 왼쪽 아래를 분할한다.
            //
            else if( leftDownLayout.count < count )
                [leftDownLayout addObject:_cellList[i]];
            
            // 더 이상 분할이 어려우면 갯수를 4개 더 늘려서 다시 분할한다.
            //
            else
            {
                count += 4;
                i--;
            }
        }
        
        
        NSArray *widthList = [self divideValuesA:CGRectGetWidth(_mainContainer.bounds) andB:2];
        NSArray *heightList = [self divideValuesA:CGRectGetHeight(_mainContainer.bounds) andB:2];
        
        
        // 분할된 영역을 적용한다.
        //
        [self layout1SubLayout:leftUpLayout andRect:CGRectMake(0.f,
                                                               0.f,
                                                               [widthList[0] floatValue],
                                                               [heightList[0] floatValue])];
        [self layout1SubLayout:rightUpLayout andRect:CGRectMake([widthList[0] floatValue],
                                                                0.f,
                                                                [widthList[1] floatValue],
                                                                [heightList[0] floatValue])];
        [self layout1SubLayout:leftDownLayout andRect:CGRectMake(0.f,
                                                                 [heightList[0] floatValue],
                                                                 [widthList[0] floatValue],
                                                                 [heightList[1] floatValue])];
        [self layout1SubLayout:rightDownLayout andRect:CGRectMake([widthList[0] floatValue],
                                                                  [heightList[0] floatValue],
                                                                  [widthList[0] floatValue],
                                                                  [heightList[1] floatValue])];
    }
    
    
    // Padding을 적용한다.
    //
    [self applyCellPadding];
}


// Layout1에서 부분 영역을 적용한다.
//  Layout2의 알고리즘과 동일하다.
- (void)layout1SubLayout:(NSArray<Cell *> *)cellList andRect:(CGRect)rect
{
    // 정사각형처럼 분할해서 배치한다.
    //
    int column = sqrtf(cellList.count);
    int row = column;
    
    // column * row로 부족한 경우 세로를 한줄씩 늘린다.
    //
    while (column * row < (int)cellList.count)
    {
        row++;
    }
    
    // column * row 보다 부족한 갯수
    //
    int lack = (column * row) - (int)cellList.count;
    
    
    // 너비 및 높이
    //
    NSArray *widthList = [self divideValuesA:CGRectGetWidth(rect) andB:column];
    NSArray *heightList = [self divideValuesA:CGRectGetHeight(rect) andB:row];
    float x = CGRectGetMinX(rect), y = CGRectGetMinY(rect);
    
    
    // 가로부터 분할해서 넣도록 한다.
    //
    int index = 0;
    for( int i = 0 ; i < row ; i++ )
    {
        // 짜투리?의 경우에는 너비를 넓혀서 배치하도록 한다.
        //
        if( lack > 0 && i == row - 1 )
            widthList = [self divideValuesA:CGRectGetWidth(rect) andB:(column - lack)];
        
        
        for( int j = 0 ; j < column ; j++ )
        {
            if( index == cellList.count )
                break;
            
            cellList[index++].frame = CGRectMake(x,
                                                 y,
                                                 [widthList[j] floatValue],
                                                 [heightList[i] floatValue]);
            
            x += [widthList[j] floatValue];
        }
        
        x = CGRectGetMinX(rect);
        y += [heightList[i] floatValue];
    }
}


// Layout2를 적용한다.
//
- (void)applyLayout2
{
    // Layout1에서 부분으로 적용하는 layout을 화면 전체에 적용한다.
    //
    [self layout1SubLayout:_cellList andRect:_mainContainer.bounds];
    
    
    // Padding을 적용한다.
    //
    [self applyCellPadding];
}


// Layout3를 적용한다.
//
- (void)applyLayout3
{
    // 위치별로 셀을 구별한다.
    //
    NSMutableArray<Cell *> *leftCells = [NSMutableArray array];
    NSMutableArray<Cell *> *upCells = [NSMutableArray array];
    NSMutableArray<Cell *> *rightCells = [NSMutableArray array];
    NSMutableArray<Cell *> *downCells = [NSMutableArray array];
    
    // 첫장만 가운데 배치하고 나머지는 주변으로 분리한다.
    //
    for( int i = 1 ; i < _cellList.count ; i++ )
    {
        switch ( i % 4) {
                
                // Down
                //
            case 0:
                [downCells addObject:_cellList[i]];
                break;
                
                // Left
                //
            case 1:
                [leftCells addObject:_cellList[i]];
                break;
                
                // Up
                //
            case 2:
                [upCells addObject:_cellList[i]];
                break;
                
                // Right
                //
            case 3:
                [rightCells addObject:_cellList[i]];
                break;
                
            default:
                break;
        }
    }
    
    
    // 가운데 사진(첫번쨰 사진)의 배치 영역.
    //
    CGRect centerRect = _mainContainer.bounds;
    
    
    // 왼쪽, 위, 오른쪽, 아래면의 너비 및 높이
    //
    int sideWidth = CGRectGetWidth(_mainContainer.bounds) * 0.3f;
    int sideHeight = CGRectGetHeight(_mainContainer.bounds) * 0.3f;
    
    
    // 왼쪽 배열한다.
    //
    if( leftCells.count > 0 )
    {
        NSArray *heightList = [self divideValuesA:CGRectGetHeight(_mainContainer.bounds)
                                             andB:(int)leftCells.count];
        int y = 0;
        for( int i = 0 ; i < leftCells.count ; i++ )
        {
            leftCells[i].frame = CGRectMake(0.f,
                                            y,
                                            sideWidth,
                                            [heightList[i] floatValue]);
            
            y += [heightList[i] floatValue];
        }
        
        // 왼쪽 영역만큼 뺀다.
        //
        centerRect.origin.x += sideWidth;
        centerRect.size.width -= sideWidth;
    }
    
    // 위 배열한다.
    //  오른쪽에 사진이 배치될 경우를 고려해서 너비를 잡아야 한다.
    if( upCells.count > 0 )
    {
        NSArray *widthList = [self divideValuesA:(CGRectGetWidth(_mainContainer.bounds) - sideWidth - (rightCells.count > 0 ? sideWidth : 0))
                                            andB:(int)upCells.count];
        int x = 0;
        for( int i = 0 ; i < upCells.count ; i++ )
        {
            upCells[i].frame = CGRectMake(sideWidth + x,
                                          0.f,
                                          [widthList[i] floatValue],
                                          sideHeight);
            
            x += [widthList[i] floatValue];
        }
        
        // 위쪽 영역만큼 뺀다.
        //
        centerRect.origin.y += sideHeight;
        centerRect.size.height -= sideHeight;
    }
    
    // 오른쪽 배열한다.
    //
    if( rightCells.count > 0 )
    {
        NSArray *heightList = [self divideValuesA:CGRectGetHeight(_mainContainer.bounds)
                                             andB:(int)rightCells.count];
        int y = 0;
        for( int i = 0 ; i < rightCells.count ; i++ )
        {
            rightCells[i].frame = CGRectMake(CGRectGetWidth(_mainContainer.bounds) - sideWidth,
                                             y,
                                             sideWidth,
                                             [heightList[i] floatValue]);
            
            y += [heightList[i] floatValue];
        }
        
        // 오른쪽 영역만큼 뺀다.
        //
        centerRect.size.width -= sideWidth;
    }
    
    // 아래 배열한다.
    //
    if( downCells.count > 0 )
    {
        NSArray *widthList = [self divideValuesA:(CGRectGetWidth(_mainContainer.bounds) - sideWidth * 2)
                                            andB:(int)downCells.count];
        int x = 0;
        for( int i = 0 ; i < downCells.count ; i++ )
        {
            downCells[i].frame = CGRectMake(sideWidth + x,
                                            CGRectGetHeight(_mainContainer.bounds) - sideHeight,
                                            [widthList[i] floatValue],
                                            sideHeight);
            
            x += [widthList[i] floatValue];
        }
        
        // 아래쪽 영역만큼 뺀다.
        //
        centerRect.size.height -= sideHeight;
    }
    
    
    // 가운데 사진 영역을 설정한다.
    //
    _cellList[0].frame = centerRect;
    
    
    // Padding을 적용한다.
    //
    [self applyCellPadding];
}


// Layout4를 적용한다.
//
- (void)applyLayout4
{
    // 세로로 잘라서 배치한다.
    //
    NSArray *heightList = [self divideValuesA:CGRectGetHeight(_mainContainer.bounds)
                                         andB:(int)_cellList.count];
    float y = 0.f;
    
    int i = 0;
    for( Cell *cell in _cellList )
    {
        cell.frame = CGRectMake(0.f,
                                y,
                                CGRectGetWidth(_mainContainer.bounds),
                                [heightList[i] floatValue]);
        
        y += [heightList[i] floatValue];
        i++;
    }
    
    
    // Padding을 적용한다.
    //
    [self applyCellPadding];
}


// Resolve precision
//  너비를 n등분 하였을때 소수점이 나오게 되면 1px 빈칸이 생기는 문제가 발생한다.
//  이것을 해걸하기 위해서 모두 동일한 너비를 사용할 수 없음으로 list로 반환해서 사용한다
- (NSArray *)divideValuesA:(int)a andB:(int)b
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:b];
    
    int length = a / b;
    int leftLength = a % b;
    
    for( int i = 0 ; i < b ; i++ )
    {
        [values addObject:@(length + (leftLength > 0 ? 1 : 0))];
        leftLength--;
    }
    
    return values;
}


#pragma mark - BG Color


// Collage의 배경색상을 설정한다.
//
- (void)setBgColor:(UIColor *)bgColor
{
    _mainContainer.backgroundColor = bgColor;
}


// BGColor
//
- (UIColor *)bgColor
{
    return _mainContainer.backgroundColor;
}


#pragma mark - Ratio


// Collage의 너비/높이 비율을 설정한다.
//
- (void)setRatio:(CGSize)ratio
{
    _ratio = ratio;
    
    [self setNeedsLayout];
}


#pragma mark - Cell options

// Cell padding 설정하기
//
- (void)setCellPadding:(float)cellPadding
{
    _cellPadding = cellPadding;
    
    // Layout을 다시 적용한다.
    //
    [self applyCurrentLayout:NO];
}


// Cell padding을 적용한다.
//
- (void)applyCellPadding
{
    // _cellPadding 값을 그대로 사용하지 않고 비율로 계산해서 사용한다.
    //
    float ratioCellPadding = _cellPadding * self.ratio.width / CGRectGetWidth(self.bounds);
    
    // Padding은 인접한 면에 셀이 있는 경우에만 적용한다.
    //
    CGRect rect;
    for( Cell *cell in _cellList )
    {
        // Get rect
        //
        rect = cell.frame;
        
        
        // Side에 인접한 정보를 얻는다.
        //
        cell.side = [self checkCollageSide:cell];
        
        
        // Top
        //
        if( !(cell.side & CollageSide_Top) ) {
            rect.origin.y += ratioCellPadding;
            rect.size.height -= ratioCellPadding;
        }
        
        
        // Bottom
        //
        if( !(cell.side & CollageSide_Bottom) )
        {
            rect.size.height -= ratioCellPadding;
        }
        
        
        // Left
        //
        if( !(cell.side & CollageSide_Left) ) {
            rect.origin.x += ratioCellPadding;
            rect.size.width -= ratioCellPadding;
        }
        
        
        // Right
        //
        if( !(cell.side & CollageSide_Right) )
        {
            rect.size.width -= ratioCellPadding;
        }
        
        
        // Frame에 설정
        //
        cell.frame = rect;
    }
}


// Cell corner radius 설정하기
//
- (void)setCellCornerRadius:(float)cellCornerRadius
{
    _cellCornerRadius = cellCornerRadius;
    
    for( Cell *cell in _cellList )
        cell.cornerRadius = cellCornerRadius;
}


// Collage side에 cell이 인접한 부분을 반환한다.
//
- (CollageSide)checkCollageSide:(Cell *)cell
{
    CollageSide side = CollageSide_None;
    
    // Left
    //
    if( CGRectGetMinX(cell.frame) <= 0.f )
        side |= CollageSide_Left;
    
    // Right
    //
    if( CGRectGetMaxX(cell.frame) >= CGRectGetWidth(_mainContainer.bounds) )
        side |= CollageSide_Right;
    
    // Top
    //
    if( CGRectGetMinY(cell.frame) <= 0.f )
        side |= CollageSide_Top;
    
    // Bottom
    //
    if( CGRectGetMaxY(cell.frame) >= CGRectGetHeight(_mainContainer.bounds) )
        side |= CollageSide_Bottom;
    
    
    return side;
}


#pragma mark - Gesture listener


// 셀간 이동을 감지하기 위한 Listener 함수
//
- (void)panGestureListener:(UIPanGestureRecognizer *)panGesture
{
    // Gesture 단계에 따라서 처리한다.
    //
    switch (panGesture.state)
    {
            // 시작하는 단계
            //
        case UIGestureRecognizerStateBegan:
        {
            // Self내에서 좌표를 얻는다.
            //
            CGPoint point = [panGesture locationInView:_mainContainer];
            
            
            // Hit되는 Cell을 찾는다.
            //
            _movingCell = [self hitCell:point];
            if( _movingCell )
            {
                // 화면에 손가락을 따라다니는 이미지를 보여준다.
                //
                _dummyCell = [[Cell alloc] initWithFrame:_movingCell.frame];
                [_dummyCell copyCell:_movingCell];
                [_mainContainer addSubview:_dummyCell];
                
                _dummyCell.alpha = 0.8f;
                _dummyCell.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                
                
                // Delegate를 호출한다.
                //
                if( [self.delegate respondsToSelector:@selector(collage:willMoveCell:)] )
                    [self.delegate collage:self willMoveCell:_dummyCell];
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if( !_movingCell )
                return;
            
            // Self내에서 좌표를 얻는다.
            //
            CGPoint point = [panGesture locationInView:_mainContainer];
            
            
            // 손가락을 중심으로 따라다니게 한다.
            //
            _dummyCell.center = point;
            
            
            // Hit되는 cell을 찾는다.
            //
            Cell *hitCell = [self hitCell:point];
            if( hitCell && hitCell != _movingCell )
            {
                NSUInteger index1, index2;
                
                //NSLog(@"%@, %@, %@", _swapCell, _movingCell, hitCell);
                
                // Swap 된 cell이 있으면 원래 위치로 돌려 놓는다.
                //
                if( _swapCell && _swapCell != hitCell )
                {
                    index1 = [_cellList indexOfObject:_swapCell];
                    index2 = [_cellList indexOfObject:_movingCell];
                    [_cellList replaceObjectAtIndex:index1 withObject:_movingCell];
                    [_cellList replaceObjectAtIndex:index2 withObject:_swapCell];
                }
                
                
                // Hit Cell과 swap 한다.
                //
                index1 = [_cellList indexOfObject:hitCell];
                index2 = [_cellList indexOfObject:_movingCell];
                [_cellList replaceObjectAtIndex:index1 withObject:_movingCell];
                [_cellList replaceObjectAtIndex:index2 withObject:hitCell];
                
                
                // Layout을 적용한다.
                //
                [self applyCurrentLayout:YES];
                
                
                // Swap cell을 설정한다.
                //
                _swapCell = _swapCell == hitCell ? nil : hitCell;
            }
            
            
            // Delegate를 호출한다.
            //
            if( [self.delegate respondsToSelector:@selector(collage:movingCell:)] )
                [self.delegate collage:self movingCell:_dummyCell];
        }
            break;
            
        default:
        {
            if( !_movingCell )
                return;
            
            // Delegate를 통해서 셀이 삭제되어야 하는지 여부를 물어본다.
            //
            if( [self.delegate respondsToSelector:@selector(collage:didMoveCell:)] &&
               [self.delegate collage:self didMoveCell:_dummyCell] )
            {
                // 셀을 삭제한다.
                //
                [self deleteCells:@[_movingCell]];
                _movingCell = nil;
            }
            
            
            [UIView animateWithDuration:0.3f
                                  delay:0.f
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 
                                 // Dummy cell 처리 여부
                                 //
                                 
                                 // 삭제되지 않았으면 원래 위치로 돌아간다.
                                 //
                                 if( _movingCell )
                                 {
                                     _dummyCell.transform = CGAffineTransformIdentity;
                                     _dummyCell.frame = _movingCell.frame;
                                 }
                                 // 삭제 된 경우 스케일 0으로 사라진다.
                                 //
                                 else
                                 {
                                     _dummyCell.transform = CGAffineTransformMakeScale(0.f, 0.f);
                                 }
                                 _dummyCell.alpha = 0.f;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 // 삭제 한다.
                                 //
                                 [_dummyCell removeFromSuperview];
                                 _dummyCell = nil;
                                 _swapCell = nil;
                             }];
        }
            break;
    }
}


// 셀 선택을 확인하기 위한 제스쳐 등록
//
- (void)tapGestureListener:(UITapGestureRecognizer *)tapGesture
{
    // Hit 되는 cell을 찾는다.
    //
    Cell *hitCell = [self hitCell:[tapGesture locationInView:_mainContainer]];
    
    
    // Delegate로 전달한다.
    //
    if( hitCell && [self.delegate respondsToSelector:@selector(collage:selectedCell:)] )
    {
        [self.delegate collage:self selectedCell:hitCell];
    }
}


// 해당 좌표에 hit되는 cell을 반환한다.
//
- (Cell *)hitCell:(CGPoint)point
{
    // Hit되는 Cell을 찾는다.
    //
    for( Cell *cell in _cellList )
    {
        // 영역안에 point가 포함되는지 확인한다.
        //
        if( CGRectContainsPoint(cell.frame, point) )
            return cell;
    }
    
    // 찾지 못함
    //
    return nil;
}


#pragma mark - Insert/Delete


// 사진 넣기
//  - Photos(UIImage *)를 Array로 받는다.
- (void)insertPhotos:(NSArray<UIImage *> *)photos andPaths:(NSArray<NSString *> *)paths andPhotoInfos:(NSArray<CellPhotoInfo *> *)infos
{
    // 반드시 사진 갯수와 photo 갯수는 일치해야 한다.
    //
    NSAssert(photos.count == paths.count, @"사진 갯수와 사진 경로 갯수를 동일하게 설정하세요");
    
    
    // 셀을 생성하고,
    //
    NSMutableArray *cells = [NSMutableArray array];
    for( int i = 0 ; i < photos.count ; i++ )
    {
        Cell *cell = [[Cell alloc] init];
        [cell setPhoto:photos[i] andPath:paths[i]];
        cell.photoInfo = infos[i];
        [cells addObject:cell];
    }
    
    
    // 추가한다.
    //
    [self insertCells:cells];
}


// 사진 빼기
//  - Photos(UIImage *)를 Array로 받는다.
- (void)deletePhotos:(NSArray<UIImage *> *)photos
{
    // Photo로 Cell을 찾고,
    //
    NSMutableArray *cells = [NSMutableArray array];
    for( Cell *cell in _cellList )
    {
        if( [photos containsObject:cell.photo] )
            [cells addObject:cell];
    }
    
    // 삭제한다.
    //
    [self deleteCells:cells];
}


// Cell 추가
//  - Cells(Cell *)을 Array로 받는다.
- (void)insertCells:(NSArray<Cell *> *)cells
{
    // Cell들을 추가한다.
    //
    [_cellList addObjectsFromArray:cells];
    for( Cell *cell in cells )
    {
        [_mainContainer addSubview:cell];
        cell.collage = self;
    }
    
    
    // 현재 Layout을 적용한다.
    //
    [self applyCurrentLayout:YES];
}


// Cell 삭제
//  - Cells(Cell *)을 Array로 받는다.
- (void)deleteCells:(NSArray<Cell *> *)cells
{
    // Cell들을 삭제한다.
    //
    [_cellList removeObjectsInArray:cells];
    for( Cell *cell in cells )
    {
        cell.collage = nil;
        [cell removeFromSuperview];
    }
    
    
    // 현재 Layout을 적용한다.
    //
    [self applyCurrentLayout:YES];
}


#pragma mark - Shuffle


// Shuffle
//
- (void)shuffle
{
    // _cellList의 순서만 변경하고 layout을 적용하면 shuffle이 된다.
    //
    NSMutableArray *suffleCellList = [[NSMutableArray alloc] initWithCapacity:_cellList.count];
    while (_cellList.count > 0)
    {
        // Cell에서 랜덤으로 빼서 suffleCellList로 옮긴다.
        //
        int index = arc4random() % _cellList.count;
        [suffleCellList addObject:_cellList[index]];
        
        [_cellList removeObjectAtIndex:index];
    }
    
    
    // 셀 리스트를 섞인 것으로 대체한다.
    //
    _cellList = suffleCellList;
    
    
    // Layout을 적용한다.
    //
    [self applyCurrentLayout:YES];
}


#pragma mark - Representation


// Represenation
//  현재의 상태를 JSON형태로 받는다.
- (NSString *)representation
{
    // 3개의 속성을 설정할 수 있는 dictionary를 생성한다.
    //
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    representation[CollageDataKey_ImageEditPixel] = [NSString stringWithFormat:@"%d,%d", IMAGE_EDIT_MAX, IMAGE_EDIT_MAX];
    
    // Layout
    //
    representation[CollageDataKey_Layout] = @(self.layout);
    
    
    // Cell list
    //  각 셀별로 representation 을 받아서 array로 설정한다.
    NSMutableArray *cellsRepList = [NSMutableArray arrayWithCapacity:_cellList.count];
    for( Cell *cell in _cellList )
        [cellsRepList addObject:[cell representation]];
    representation[CollageDataKey_CellList] = cellsRepList;
    
    
    // Ratio
    //
    representation[CollageDataKey_Ratio] = NSStringFromCGSize(_ratio);
    
    
    // BG Color
    //
    CGFloat r,g,b;
    [_mainContainer.backgroundColor getRed:&r
                                     green:&g
                                      blue:&b
                                     alpha:nil];
    representation[CollageDataKey_BGColor] = @[@((int)(r * 255)),
                                               @((int)(g * 255)),
                                               @((int)(b * 255))];
    
    
    // Corner radius
    //
    representation[CollageDataKey_CellCornerRadius] = @(_cellCornerRadius);
    
    
    // Cell padding
    //
    representation[CollageDataKey_CellPadding] = @(_cellPadding);
  

    representation[CollageDataKey_Inch] = self.inch;
    representation[CollageDataKey_OSInfo] = @"ios";
    
    
    // NSDictionary -> JSON으로 변환
    //
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:representation
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    
    // UTF8로 인코딩
    //
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// daypark
- (int)cellCount {
    return (int)_cellList.count;
}

- (NSString *)fileList {
    NSString *filelist = @"";
    for (Cell *cell in _cellList) {
        filelist = [NSString stringWithFormat:@"%@%@\n", filelist, cell.photoPath];
    }
    return filelist;
}

- (NSMutableArray *)filenameList {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (Cell *cell in _cellList) {
        [array addObject:cell.photoPath];
    }
    return array;
}
/*
CGContextRef context = UIGraphicsGetCurrentContext();
//CGContextSetRGBFillColor(context, 0, 0, 0, 1.0f);
//CGContextFillRect(context, _mainContainer.bounds);
*/
- (UIImage *)getThumbImage {
    for (Cell *cell in _cellList) {
        [cell hideWarningView];
    }
    
    if (_guideImage != nil) {
        [_mainContainer bringSubviewToFront:_guideImage];
    }
    
    UIGraphicsBeginImageContextWithOptions(_mainContainer.bounds.size, NO, 0);
    [_mainContainer.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setInchAndRatio:(NSString *)inch {
    // set inch
    _inch = [inch stringByReplacingOccurrencesOfString:@"x" withString:@","];
    
    // set ratio
    NSArray *tempArray = [inch componentsSeparatedByString:@"x"];
    CGSize inch_size = CGSizeMake([tempArray[0] floatValue], [tempArray[1] floatValue]);
    
    int ratio_w = 0;
    int ratio_h = 0;
    if (inch_size.width > inch_size.height) {
        ratio_w = 1000.f;
        ratio_h = (int)((inch_size.height * 1000.f) / inch_size.width);
    }
    else {
        ratio_w = (int)((inch_size.width * 1000.f) / inch_size.height);
        ratio_h = 1000.f;
    }
    _ratio = CGSizeMake(ratio_w, ratio_h);
    
    NSLog(@"%@: %.1fx%.1f", _inch, _ratio.width, _ratio.height);
}

- (void)setGuideInfo:(UIImage *)guideImage {
    _guideImage = [[UIImageView alloc] initWithFrame:_mainContainer.bounds];
    _guideImage.image=guideImage;
    _guideImage.clipsToBounds = NO;
    _guideImage.layer.zPosition = 1; // 항상 맨위에
    
    [_mainContainer addSubview:_guideImage];
}

@end
