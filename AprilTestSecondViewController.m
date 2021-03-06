//
//  AprilTestSecondViewController.m
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestSecondViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestSimRun.h"
#import "AprilTestVariable.h"
#import "FebTestIntervention.h"
#import "FebTestWaterDisplay.h"
#import "AprilTestEfficiencyView.h"
#import "AprilTestNormalizedVariable.h"

@interface AprilTestSecondViewController ()

@end

@implementation AprilTestSecondViewController
@synthesize studyNum = _studyNum;
@synthesize url = _url;
@synthesize dataWindow = _dataWindow;
@synthesize mapWindow = _mapWindow;
@synthesize titleWindow = _titleWindow;
@synthesize thresholdValue = _thresholdValue;
@synthesize hoursAfterStorm = _hoursAfterStorm;
@synthesize thresholdValueLabel = _thresholdValueLabel;
@synthesize hoursAfterStormLabel = _hoursAfterStormLabel;
@synthesize loadingIndicator = _loadingIndicator;

NSMutableArray * trialRuns;
NSMutableArray * trialRunsNormalized;
NSMutableArray * waterDisplays;
NSMutableArray * efficiency;
NSMutableArray *lastKnownConcernProfile;
NSMutableArray *bgCols;
UILabel *redThreshold;
int trialNum = 0;

@synthesize currentConcernRanking = _currentConcernRanking;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    _studyNum = tabControl.studyNum;
    _url = tabControl.url;
    trialRuns = [[NSMutableArray alloc] init];
    trialRunsNormalized = [[NSMutableArray alloc] init];
    waterDisplays = [[NSMutableArray alloc] init];
    efficiency = [[NSMutableArray alloc] init];
    _mapWindow.delegate = self;
    _dataWindow.delegate = self;
    _titleWindow.delegate = self;
    bgCols = [[NSMutableArray alloc] init];
    float translateThreshValue = _thresholdValue.value/_thresholdValue.maximumValue * _thresholdValue.frame.size.width;
    redThreshold = [[UILabel alloc] initWithFrame: CGRectMake(_thresholdValue.frame.origin.x + translateThreshValue + 2, _thresholdValue.frame.origin.y + _thresholdValue.frame.size.height/2, _thresholdValue.frame.size.width - 4 - translateThreshValue , _thresholdValue.frame.size.height/2)];
    [redThreshold setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:redThreshold];
    [self.view sendSubviewToBack:redThreshold];
    UIImageView *gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradientScale.png"]];
    [gradient setFrame: CGRectMake(_thresholdValue.frame.origin.x + 2, _thresholdValue.frame.origin.y + _thresholdValue.frame.size.height/2, _thresholdValue.frame.size.width - 4, _thresholdValue.frame.size.height/2)];
    [self.view addSubview: gradient];
    [self.view sendSubviewToBack:gradient];
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = @"Map and Score";
    valueLabel.frame =CGRectMake(20, 55, 0, 0);
    valueLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [valueLabel sizeToFit ];
    valueLabel.textColor = [UIColor blackColor];
    [self.view addSubview:valueLabel];
//    [self loadNextSimulationRun];
//    [self drawTitles];
//    lastKnownConcernProfile= [[NSMutableArray alloc] initWithObjects:@"", nil];
//    
}

- (void) viewWillAppear:(BOOL)animated{
    //[trialRuns removeAllObjects];
    //[waterDisplays removeAllObjects];
    //[efficiency removeAllObjects];
    for (UIView *view in [_titleWindow subviews]){
        [view removeFromSuperview];
    }
    for( UIView *view in [_dataWindow subviews]){
        [view removeFromSuperview];
    }
    for (UIView *view in [_mapWindow subviews]){
        [view removeFromSuperview];
    }
//    int prevTrialNum = trialNum;
//    trialNum = 0;
    for (int i =0; i < trialNum; i++){
        [self drawTrial:i];
    }
    [self drawTitles];
    [_dataWindow setContentOffset:CGPointMake(0, 0)];
    [_mapWindow setContentOffset:CGPointMake(0,0 )];
    [_dataWindow flashScrollIndicators];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pullNextRun:(id)sender {
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self loadNextSimulationRun];
    [_loadingIndicator stopAnimating];
}

- (void)loadNextSimulationRun{

    _url = @"http://192.168.1.42";
    _studyNum = 1;
    NSString * urlPlusFile = [NSString stringWithFormat:@"%@/%@", _url, @"simOutput.php"];
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFile ] ];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    //NSLog(@"%@", request);
    NSString *content;
    while( !content){
        NSURLResponse *response;
        NSError *err;
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnData bytes]) content = [NSString stringWithUTF8String:[returnData bytes]];
         //NSLog(@"responseData: %@", content);
    }
    NSString *urlPlusFileN = [NSString stringWithFormat:@"%@/%@", _url, @"simOutputN.php"];
    NSString *myRequestStringN = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestDataN = [ NSData dataWithBytes: [ myRequestStringN UTF8String ] length: [ myRequestStringN length ] ];
    NSMutableURLRequest *requestN = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFileN ] ];
    [ requestN setHTTPMethod: @"POST" ];
    [ requestN setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ requestN setHTTPBody: myRequestDataN ];
    //NSLog(@"%@", request);
    NSString *contentN;
    while( !contentN){
        NSURLResponse *responseN;
        NSError *err;
        NSData *returnDataN = [ NSURLConnection sendSynchronousRequest: requestN returningResponse:&responseN error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnDataN bytes]) contentN = [NSString stringWithUTF8String:[returnDataN bytes]];
       // NSLog(@"responseData: %@", contentN);
    }
    
    if(content != NULL && content.length > 100){
        AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:content withTrialNum:trialNum];
        AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: contentN withTrialNum:trialNum];
        [trialRunsNormalized addObject:simRunNormal];
        [trialRuns addObject: simRun];
        [self drawTrial: trialNum];
        trialNum++;
    }
    
}

-(void) drawTrial: (int) trial{
    NSLog (@"Drawing trial number: %d", trial);
    AprilTestSimRun *simRun = [trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal = [trialRunsNormalized objectAtIndex:trial];
    FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(20, 175 * (trial) +5, 125, 145))];
    interventionView.view = _mapWindow;
    [interventionView updateView];
    UILabel *trialLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 175*(trial+1)-27, 0, 0)];
    trialLabel.text = [NSString stringWithFormat:  @"Trial %d", trial + 1];
    trialLabel.font = [UIFont systemFontOfSize:14.0];
    [trialLabel sizeToFit];
    trialLabel.textColor = [UIColor blackColor];
    [_mapWindow addSubview:trialLabel];
    [_mapWindow setContentSize: CGSizeMake(_mapWindow.contentSize.width, (simRun.trialNum+1)*200)];
    
    //int scoreBar=0;
    float priorityTotal= 0;
    float scoreTotal = 0;
    
    for(int i = 0; i < _currentConcernRanking.count; i++){
        //NSLog(@"%@", [_currentConcernRanking objectAtIndex:i] );
        priorityTotal += [(AprilTestVariable *)[_currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }
    
    int width = 0;
    
    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    int visibleIndex = 1;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        if(simRun.trialNum ==0 && visibleIndex %2 == 0 && currentVar.widthOfVisualization > 0){
            UILabel *bgCol = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, currentVar.widthOfVisualization - 10, _dataWindow.contentSize.height + 100)];
            bgCol.backgroundColor = [UIColor colorWithRed:.8 green:.9 blue:1.0 alpha:.5];
            [_dataWindow addSubview:bgCol];
            [bgCols addObject:bgCol];
        }
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"Installation Cost: $%d", simRun.publicInstallCost]    withConcernPosition:width+25 andyValue: (simRun.trialNum) * 175 ];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%d", simRun.publicDamages] withConcernPosition:width +25 andyValue: (simRun.trialNum * 175) +30];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%d", simRun.publicMaintenanceCost] withConcernPosition:width + 25 andyValue: (simRun.trialNum * 175) +60];
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicInstallCost);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicDamages);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicMaintenanceCost);
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"Installation Cost: $%d", simRun.privateInstallCost] withConcernPosition:width +25 andyValue: (simRun.trialNum * 175)] ;
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%d", simRun.privateDamages] withConcernPosition:width + 25 andyValue: (simRun.trialNum*175) +30];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%d", simRun.privateMaintenanceCost] withConcernPosition:width + 25 andyValue: (simRun.trialNum * 175) +60];
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateInstallCost);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateDamages);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateMaintenanceCost);
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.impactNeighbors] withConcernPosition:width +50 andyValue: (simRun.trialNum ) * 175];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (simRunNormal.impactNeighbors);
        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 50 andyValue: (simRun.trialNum )* 175];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe);
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.infiltration] withConcernPosition:width + 50 andyValue: (simRun.trialNum)* 175 ];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.infiltration);
        } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            FebTestWaterDisplay * wd;
            //NSLog(@"%d, %d", waterDisplays.count, i);
            if(waterDisplays.count <= trial){
                //NSLog(@"Drawing water display for first time");
                wd = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (simRun.trialNum)*175, 125, 145) andContent:simRun.standingWater];
                wd.view = _dataWindow;
                [waterDisplays addObject:wd];
            } else {
                //NSLog(@"Repositioning water display");
                wd = [waterDisplays objectAtIndex:trial];
                wd.frame = CGRectMake(width + 10, (simRun.trialNum)*175, 125, 145);
            }
            wd.thresholdValue = _thresholdValue.value;
            [wd updateView: _hoursAfterStorm.value];
            
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            AprilTestEfficiencyView *ev;
            if( efficiency.count <= trial){
                //NSLog(@"Drawing efficiency display for first time");
            ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(width, (simRun.trialNum )*175 + 15, 130, 150) withContent: simRun.efficiency];
                ev.trialNum = i;
                ev.view = _dataWindow;
                [efficiency addObject:ev];
            } else {
                //NSLog(@"Repositioning efficiency display");
                ev = [efficiency objectAtIndex:trial];
                ev.frame = CGRectMake(width, (simRun.trialNum )*175 + 15, 130, 150);
            }
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency;
            //NSLog(@"%@", NSStringFromCGRect(ev.frame));
            
            
            [ev updateViewForHour: _hoursAfterStorm.value];
            
        }
        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }
    
    [_dataWindow setContentSize:CGSizeMake(width+=100, (simRun.trialNum+1)*200)];
    for(UILabel * bgCol in bgCols){
        if(_dataWindow.contentSize.height > _dataWindow.frame.size.height){
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.contentSize.height + 100)];
        }else {
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.frame.size.height + 100)];
        }
    }
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 175*(trial+1) - 27, 0, 0)];
    scoreLabel.text = [NSString stringWithFormat:  @"Score %.2f", scoreTotal];
    scoreLabel.font = [UIFont systemFontOfSize:14.0];
    [scoreLabel sizeToFit];
    scoreLabel.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel];
    
    
    [_dataWindow flashScrollIndicators];          
    
}

-(void) drawTextBasedVar: (NSString *) outputValue withConcernPosition: (int) concernPos andyValue: (int) yValue{
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = outputValue;
    valueLabel.frame =CGRectMake(concernPos, yValue+15, 0, 0);
    [valueLabel sizeToFit ];
    valueLabel.font = [UIFont systemFontOfSize:14.0];
    valueLabel.textColor = [UIColor blackColor];
    [[self dataWindow] addSubview:valueLabel];
    
}

-(void) drawTitles{
    int width = 0;

    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    int visibleIndex = 1;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){

        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        UILabel * currentVarLabel = [[UILabel alloc] init];
                if (visibleIndex % 2 == 0) currentVarLabel.backgroundColor = [UIColor colorWithRed:.8 green:.9 blue:1.0 alpha:.5];
        currentVarLabel.frame = CGRectMake(width, 2, currentVar.widthOfVisualization - 10, 40);
        currentVarLabel.font = [UIFont boldSystemFontOfSize:16.0];
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            currentVarLabel.text = @"  Public Cost";
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            currentVarLabel.text =@"  Private Cost";
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            currentVarLabel.text =@"  Runoff to Neighbors";
        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            currentVarLabel.text=@"  Neighbors Runoff to Me";
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            currentVarLabel.text =@"  Intervention Capacity";
        } else if ([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            currentVarLabel.text = @"  Puddle Depth Over Time";
        } else if( [currentVar.name compare:@"groundwaterInfiltration"] == NSOrderedSame){
            currentVarLabel.text = @"  % Rainwater Infiltrated";
        } else {
            currentVarLabel = NULL;
        }
        if(currentVar.widthOfVisualization != 0) visibleIndex++;
        
        if(currentVarLabel != NULL){
        [_titleWindow addSubview:currentVarLabel];
        }
        width+= currentVar.widthOfVisualization;
    }
    
    [_dataWindow setContentSize: CGSizeMake(width + 10, _dataWindow.contentSize.height)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([scrollView isEqual:_dataWindow]) {
        CGPoint offset = _mapWindow.contentOffset;
        offset.y = _dataWindow.contentOffset.y;
        CGPoint titleOffset = _titleWindow.contentOffset;
        titleOffset.x = _dataWindow.contentOffset.x;
        [_titleWindow setContentOffset:titleOffset];
        [_mapWindow setContentOffset:offset];
    } else {
        CGPoint offset = _dataWindow.contentOffset;
        offset.y = _mapWindow.contentOffset.y;
        [_dataWindow setContentOffset:offset];
    }
}
- (IBAction)sliderChanged:(id)sender {
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    float threshVal = _thresholdValue.value * 0.0393701;
    [_thresholdValue setEnabled:FALSE];
    [_hoursAfterStorm setEnabled:FALSE];
    [_mapWindow setScrollEnabled:FALSE];
    [_dataWindow setScrollEnabled:FALSE];
    [_titleWindow setScrollEnabled:FALSE];
    _thresholdValueLabel.text = [NSString stringWithFormat:@"%.1F\"", threshVal ];
    float translateThreshValue = _thresholdValue.value/_thresholdValue.maximumValue * _thresholdValue.frame.size.width;
    [redThreshold setFrame: CGRectMake(_thresholdValue.frame.origin.x + translateThreshValue + 2, _thresholdValue.frame.origin.y + _thresholdValue.frame.size.height/2, _thresholdValue.frame.size.width - 4 - translateThreshValue , _thresholdValue.frame.size.height/2)];
    [_thresholdValueLabel sizeToFit];
    for(int i = 0; i < waterDisplays.count; i++){
        FebTestWaterDisplay * temp = (FebTestWaterDisplay *) [waterDisplays objectAtIndex:i];
        temp.thresholdValue = _thresholdValue.value;
    }
    
    int hoursAfterStorm = floorf(_hoursAfterStorm.value);
    if (hoursAfterStorm % 2 != 0) hoursAfterStorm--;
    _hoursAfterStorm.value = hoursAfterStorm;
    _hoursAfterStormLabel.text = [NSString stringWithFormat:@"%d hours", hoursAfterStorm];
    [_hoursAfterStormLabel sizeToFit];
    for(int i = 0; i < waterDisplays.count; i++){
        FebTestWaterDisplay * temp = (FebTestWaterDisplay *) [waterDisplays objectAtIndex:i];
        AprilTestEfficiencyView * temp2 = (AprilTestEfficiencyView *)[efficiency objectAtIndex:i];
        [temp2 updateViewForHour:hoursAfterStorm];
        [temp updateView:hoursAfterStorm];
    }
    [_thresholdValue setEnabled:TRUE];
    [_hoursAfterStorm setEnabled:TRUE];
    [_mapWindow setScrollEnabled:TRUE];
    [_dataWindow setScrollEnabled:TRUE];
    [_titleWindow setScrollEnabled:TRUE];
    [_loadingIndicator stopAnimating];
}


@end
