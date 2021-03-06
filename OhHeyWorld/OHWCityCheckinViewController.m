//
//  OHWCityCheckinViewController.m
//  OhHeyWorld
//
//  Created by Eric Roland on 10/18/12.
//  Copyright (c) 2012 Oh Hey World, Inc. All rights reserved.
//

#import "OHWCityCheckinViewController.h"
#define appDelegate (OHWAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface OHWCityCheckinViewController ()

@end

@implementation OHWCityCheckinViewController
@synthesize cityLabel = _cityLabel;
@synthesize textView = _textView;
@synthesize checkinButton = _checkinButton;
@synthesize location = _location;
@synthesize user = _user;
@synthesize mapView = _mapView;

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
  NSLog(@"%@", error);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
  UserLocation *userLocation = [objects objectAtIndex:0];
  userLocation.user = _user;
  userLocation.userId = _user.externalId;
  userLocation.locationId = _location.externalId;
  userLocation.location = _location;
  
  NSLog(@"%@", objectLoader.response.bodyAsString);
  //NSLog(@"%@", userLocation.customMessage);
  
  if (userLocation.externalId != nil) {
    [appDelegate saveContext];
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"externalId == 0"];
  NSMutableArray* userLocations = [CoreDataHelper searchObjectsInContext:@"UserLocation" :predicate :nil :NO :[appDelegate managedObjectContext]];
  UserLocation *zeroUserLocation = [userLocations objectAtIndex:0];
  if (zeroUserLocation != nil) {
    [ModelHelper deleteObject:zeroUserLocation];
  }
  [appDelegate setUserLocation:userLocation];
  OHWCheckedinViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckedinView"];
  [self.navigationController pushViewController:controller animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
  _location = [appDelegate location];
  _user = [appDelegate loggedInUser];
  NSString *locationText = [[NSArray arrayWithObjects:_location.city, _location.state, _location.countryCode , nil] componentsJoinedByString:@", "];
  _cityLabel.text = locationText;
  _textView.placeholder = @"Add message (optional)";

  float latitude = [_location.latitude floatValue];
  float longitude = [_location.longitude floatValue];
  CLLocationCoordinate2D center = {latitude, longitude};
  MKCoordinateRegion region;
  MKCoordinateSpan span;
  span.latitudeDelta = .025;
  span.longitudeDelta = .025;
  region.center = center;
  region.span = span;
  [_mapView setRegion:region animated:TRUE];
  [_mapView regionThatFits:region];
  [_mapView setCenterCoordinate:_mapView.region.center animated:NO];
  
  MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
  [point setCoordinate:(center)];
  [point setTitle:_location.address];
  [_mapView addAnnotation:point];
}

- (MKAnnotationView *) mapView:(MKMapView *)currentMapView viewForAnnotation:(id <MKAnnotation>) annotation {
  if (annotation == currentMapView.userLocation) {
    return nil; //default to blue dot
  }
  MKPinAnnotationView *dropPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
  dropPin.pinColor = MKPinAnnotationColorGreen;
  dropPin.animatesDrop = YES;
  dropPin.canShowCallout = YES;
  return dropPin;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Checked In";
  //CGRect frame = CGRectMake(40, self.view.bounds.size.height - 290, 240, self.view.bounds.size.height - 300);
  //_mapView = [[MKMapView alloc] initWithFrame:frame];
  _mapView.delegate = self;
  _mapView.showsUserLocation = YES;
  
  _textView.delegate = self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  
  return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
