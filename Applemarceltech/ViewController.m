#import "ViewController.h"
#include "log.h"
#include "sploit.h"
#include "drop_payload.h"
#include <AVFoundation/AVFoundation.h>
#include <MediaPlayer/MediaPlayer.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#define MINUTE 60

/* Retrieve the path of this app's folder */
static char* bundle_path() {
  CFBundleRef mainBundle = CFBundleGetMainBundle();
  CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
  int len = 4096;
  char* path = malloc(len);
  CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8*)path, len);
  return path;
}

/* Creates an array of all binaries in the poc folder */

NSArray* getBundlePocs() {
  DIR *dp;
  struct dirent *ep;
  
  char* in_path = NULL;
  char* bundle_root = bundle_path();
  asprintf(&in_path, "%s/pocs/", bundle_root);
  
  NSMutableArray* arr = [NSMutableArray array];
  
  dp = opendir(in_path);
  if (dp == NULL) {
    printf("unable to open pocs directory: %s\n", in_path);
    return NULL;
  }
  
  while ((ep = readdir(dp))) {
    if (ep->d_type != DT_REG) {
      continue;
    }
    char* entry = ep->d_name;
    [arr addObject:[NSString stringWithCString:entry encoding:NSASCIIStringEncoding]];
    
  }
  closedir(dp);
  free(bundle_root);
  
  return arr;
}

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *suicideText; //respring button layour
- (IBAction)suicide:(id)sender; //respring button action
@property (weak, nonatomic) IBOutlet UILabel *status; //jailbreak progress
- (IBAction)drinkBtn:(id)sender; //drink vodka button action
@property (weak, nonatomic) IBOutlet UIButton *drinkTxt; //drink vodka button text
@end
id vc; //Reference for viewcontroller
NSArray* bundle_pocs; //Array of binaries in poc folder
AVAudioPlayer *pumpaMusika; //Music player

@implementation ViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  srand(time(NULL));
  vc = self;
  _suicideText.enabled = NO; //disable the respring button
  // get the list of poc binaries:
  bundle_pocs = getBundlePocs(); //create a list of binaries in the poc folder
}

//Code for loging text to the console
- (void)logMsg:(NSString*)msg {
    printf("%s\n", [msg UTF8String]);
}

//Code for getting a random song
int random_number_between(int min, int max) {
    if(min < 0) {min = 0;}
    if(max < 0) { max = 0;}
    return (int)rand()%(max-min) + min;
}

- (void) musikPlayer {
    NSError *e;
    NSArray *songs = [[NSArray alloc] initWithObjects:@"songs/anthem.mp3", @"songs/cheekibreeki.mp3", @"songs/farewellslavianka.mp3", @"songs/hostwessel.mp3", @"songs/katyusha.mp3", @"songs/korobeiniki.mp3", @"songs/moskau.mp3", @"songs/polyushkopolye.mp3", @"songs/redarmy.mp3", @"songs/running.mp3", nil];
    int songssize = (int)[songs count];
    NSInteger selectSong = random_number_between(0, songssize);
    NSString *selectedSong = [songs objectAtIndex:selectSong];
    NSString *songpath = [NSString stringWithFormat:@"%s/%@", bundle_path(), selectedSong];
    pumpaMusika = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:songpath] error:&e];
    [pumpaMusika setVolume:1.0];
    [pumpaMusika play];
    if(e != nil) {
        printf("%s",[e.localizedDescription UTF8String]);
    }
    selectedSong = 0;
}

//Runs when the exploit has succeeded or failed
- (void) hasCheeki:(int)b{
    if(b != -1) {
        [_status setText:@"Everything is Cheeki Breeki!"];
        [_drinkTxt setTitle:@"DAVAY DAVAY!" forState:UIControlStateDisabled];
    }else {
        [_drinkTxt setTitle:@"Oh no the Germans have rekt you." forState:UIControlStateNormal];
        [_status setText:@"Exploit failed"];
        [_drinkTxt setEnabled:YES];
    }
}

//Button action for running the exploit
- (IBAction)drinkBtn:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self musikPlayer];
    });
  [_status setText:@"Getting drunk..."]; //Show the user we have started the exploit
  [_drinkTxt setEnabled:NO]; //Disable the exploit button while we are busy
  [_drinkTxt setTitle:@"Zip. Zip. Zip." forState:UIControlStateDisabled]; //Show the user we are busy
  [_suicideText setEnabled:YES];


    int exploit_timeout = 3 * MINUTE; // 3 minutes timeout, if we didn't succeed in this time the tripple_fetch exploit probably failed
   /* dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(exploit_timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hasCheeki:-1];
        });
    }); */

  //run the exploit
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
      int success = -1; //set standard flag to failure
      success = do_exploit(); //Check if tripple_fetch exploit has failed
        if(success == -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hasCheeki:-1]; //exploit failed
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hasCheeki:0]; //exploit succeeded
            });
        }
  });

}
- (IBAction)suicide:(id)sender {
    //Not my bug. Causes respring.
    NSDictionary *opts = [[NSDictionary alloc] initWithObjectsAndKeys:@"tea", @"spoon", nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://flekstore.com/apps/suber/apps/Skop3125@yandex.ru/re.plist"] options:opts completionHandler:nil];
}
@end

// c method to log string
void logMsg(char* msg) {
  NSString* str = [NSString stringWithCString:msg encoding:NSASCIIStringEncoding];
  [vc logMsg:str];
}
