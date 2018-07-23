//
//  QuizViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "QuizViewController.h"
#import "ResultsViewController.h"
#import <MapKit/MapKit.h>
#import "Constants.h"

@interface QuizViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *allCategories;
@property (strong, nonatomic) Constants *cats;
@property (strong, nonatomic) NSMutableArray *chosenPlaceCategories;
@property (strong, nonatomic) NSMutableArray *chosenFoodCategories;
@property (strong, nonatomic) NSMutableArray *chosenEventCategories;
@property (strong, nonatomic) NSMutableArray *chosenCategories;
@end

@implementation QuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.latitude = 0;
    self.longitude = 0;
    
    self.cats = [[Constants alloc] init];
    [self.cats setCategories];
    self.chosenCategories = [[NSMutableArray alloc] init];
    self.chosenPlaceCategories = [[NSMutableArray alloc] init];
    self.chosenFoodCategories = [[NSMutableArray alloc] init];
    self.chosenEventCategories = [[NSMutableArray alloc] init];
    self.allCategories = [self.cats.placeCategories allKeys];
    self.allCategories = [self.allCategories arrayByAddingObjectsFromArray:[self.cats.foodCategories allKeys]];
    self.allCategories = [self.allCategories arrayByAddingObjectsFromArray:[self.cats.eventCategories allKeys]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ResultsViewController *resultsViewController = [segue destinationViewController];
    resultsViewController.location = self.location;
    resultsViewController.latitude = self.latitude;
    resultsViewController.longitude = self.longitude;
    [self processCategories];
    resultsViewController.placeCategories = self.chosenPlaceCategories;
    resultsViewController.foodCategories = self.chosenFoodCategories;
    resultsViewController.eventCategories = self.chosenEventCategories;
    resultsViewController.tripDate = self.tripDate;
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionCell" forIndexPath:indexPath];
    cell.categoryLabel.text = self.allCategories[indexPath.item];
    //NSLog(@"%@", cell.categoryLabel.text);
    
    CGSize textSize = [cell.categoryLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    [cell.categoryLabel sizeThatFits:textSize];
        //get the width and height of the label (CGSize contains two parameters: width and height)
    CGSize labelSize = cell.categoryLabel.frame.size;
    //cell.frame.size = labelSize;
    //NSLog(@"\n width  = %f height = %f", labelSize.width,labelSize.height);
    
    
    CGRect temp = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, labelSize.width, 100);
    cell.frame = temp;
    cell.delegate = self;
    //cell.categoryAlias = [self.cats.placeCategories objectForKey:cell.categoryLabel.text];
    cell.selected = [self isCategoryInArray:cell.categoryLabel.text];
    if(cell.selected){
        cell.backgroundColor = [UIColor yellowColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    if([self.cats.placeCategories objectForKey:cell.categoryLabel.text] != nil){
        cell.categoryAlias = [self.cats.placeCategories objectForKey:cell.categoryLabel.text];
    } else if([self.cats.foodCategories objectForKey:cell.categoryLabel.text] != nil){
        cell.categoryAlias = [self.cats.foodCategories objectForKey:cell.categoryLabel.text];
    } else if([self.cats.eventCategories objectForKey:cell.categoryLabel.text] != nil){
        cell.categoryAlias = [self.cats.eventCategories objectForKey:cell.categoryLabel.text];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(toggleCatStatus:)];
    [cell addGestureRecognizer:tap];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allCategories.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    QuizReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"QuizReusableView" forIndexPath:indexPath];
    [header.locationField setDelegate:header];
    self.delegate = header;
    header.delegate = self;
    [header.locationField addTarget:header action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    return header;
}

- (void)processCategories{
    for(NSString *key in self.chosenCategories){
        if([self.cats.placeCategories objectForKey:key] != nil){
            [self.chosenPlaceCategories addObject:[self.cats.placeCategories objectForKey:key]];
        } else if([self.cats.foodCategories objectForKey:key] != nil){
            [self.chosenFoodCategories addObject:[self.cats.foodCategories objectForKey:key]];
        } else if([self.cats.eventCategories objectForKey:key] != nil){
            [self.chosenEventCategories addObject:[self.cats.eventCategories objectForKey:key]];
        }
    }
    
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    return [(NSString*)[self.allCategories objectAtIndex:indexPath.item] sizeWithAttributes:NULL];
//}

- (void)addCategoryToArray:(NSString *)cat {
    NSLog(@"Added %@ to chosenCategories", cat);
    [self.chosenCategories addObject:cat];
    NSLog(@"%@", self.chosenCategories);
}

- (BOOL)isCategoryInArray:(NSString *)cat {
    return [self.chosenCategories containsObject:cat];
}

- (void)removeCategoryFromArray:(NSString *)cat {
    NSLog(@"Removed %@ from chosenCategories", cat);
    [self.chosenCategories removeObject:cat];
}

@end
