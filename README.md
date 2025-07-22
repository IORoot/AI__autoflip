![header](https://raw.githubusercontent.com/AI__autoflip/ioroot_v2/refs/heads/master/header.jpg)

# Custom Autoflip Container

This container is built to run in a github action.

It has a few extra packages installed to aid in auto-processing videos for social media.

## Extra packages:

- FFMPEG 5.1.6 Has been installed
- https://github.com/IORoot/ffmpeg__bash-scripts scripts are installed but always require a git pull to keep in sync with latest.
- SSH
- SSHPass
- rSync
- rClone (To copy files from Google Drive.)

## rClone

This requires a `~/.config/rclone/rclone.conf` file with the correct tokens to allow access to your google drive. DO NOT ADD INTO THE CONTAINER. Instead, add via a github secret through the github action.

Place the config into a secret variable called `RCLONE_CONF` and should look like this: (with XXXX,YYYY,ZZZZ with correct details. See rClone docs for generating this file)

```
[GDrive]
type = drive
scope = drive
token = {"access_token":"XXXXX,"token_type":"Bearer","refresh_token":"YYYYY","expiry":"2023-02-17T09:04:46.600879335Z"}
team_drive = 
root_folder_id = ZZZZZZZ
```


## Triggering

This github action is meant to be triggered via a HTTP request that should be something like the following:

```bash
curl                                                            \                                    
-X POST                                                         \                                   
-H "Accept: application/vnd.github+json"                        \                  
-H "Authorization: Bearer GITHUB_PAT_KEY"                       \                  
-H "X-GitHub-Api-Version: 2022-11-28"                           \                    
    https://api.github.com/repos/ioroot/AI__autoflip/dispatches \         
    -d '{"event_type":"gdrive_video_convert","client_payload":{ \         
            "GDRIVE_FOLDER":  "FOLDER/IN/GDRIVE/TO/USE",        \            
            "TEMPLATE":"ft_simple_1-1.sh"                       \
            }                                                   \
        }'           
```

This triggers the github actions `event_type` to the `repository_dispatch` trigger and passes the `client_payload` as environment variables to be used further down.
```
repository_dispatch:
    types: run_autoflip
```





## Autoflip Details
Google Autoflip: An Open Source Framework for Intelligent Video Reframing https://ai.googleblog.com/2020/02/autoflip-open-source-framework-for.html

Tool to crop video with machine learning based on MediaPipe v0.6.8.1 https://github.com/google/mediapipe/tree/de4fbc10e62001795741cb6d0200a17a94a29b0f

Build without GPU support. CPU Only.

## Prerequisites
In order to run this container you'll need docker installed.

- Windows
- OS X
- Linux

## Usage
Quick start
Rename the mp4 video to video.mp4 and put it in any folder for example /video/folder/path
```
    docker run -it -v /video/folder/path:/video lathi/autoflip:latest
```
If cropping succeeds you will get a result in the folder /video/folder/path in a file named video_crop.mp4 and crop ratio 9:16.

### Customise input and output files.
You can download test videos and put in folders for example /video/folder/path
```
docker run -it -v /video/folder/path:/video \
    -e input_video=life_at_google.mp4 \
    -e output_video=life_at_google_crop_9:16.mp4 \
    -e aspect_ratio=9:16 \
    lathi/autoflip:latest
```
You will get results to folder /video/folder/path

### Customise config file
You will use Google's development config file autoflip_graph_development.pbtxt. Input will be a video.mp4 file. In the result folder, you will get cropped video called video_crop.mp4, an existing video with a frame in input video that was cropped called frames.mp4. And you will get a video with points detected by the system called points.mp4

### Customise all filenames
```
docker run -it -v /video/folder/path:/video \
    -e input_video=life_at_google.mp4 \
    -e output_video=life_at_google_croped_1:1.mp4 \
    -e aspect_ratio=1:1 \
    -e config=development \
    -e frames_output=life_at_google_1:1_frames.mp4 \
    -e points_output=life_at_google_1:1_points.mp4 \
    lathi/autoflip:latest
```
### Use your custom config file
Get file from autoflip_graph_development.pbtxt. Modify it for example rename it to custom_development.pbtxt
```
docker run -it -v /video/folder/path:/video \
    -v /config/custom_development.pbtxt:/config.pbtxt \
    -e config=/config.pbtxt \
    lathi/autoflip:latest
```
Input will be video.mp4 file and you will get video_crop.mp4, frames.mp4, points.mp4

## Use a different folder for input and output videos
```
docker run -it -v /folder/to/input/videos:/video \
    -v /folder/to/output/videos:/video/output \
    -e input_video=life_at_google.mp4 \
    -e output_video=output/life_at_google_3:4.mp4 \
    -e aspect_ratio=3:4 \
    -e config=development \
    -e frames_output=output/life_at_google_3:4_frames.mp4 \
    -e point_output=output/life_at_google_3:4_points.mp4 \
    lathi/autoflip:latest
```
### Run AutoFlip with default commands
Or you can just call commands directly to run_autoflip like here Autoflip readme.
```
docker run -it -e GLOG_logtostderr=1 lathi/autoflip:latest \    
 bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip \
  --calculator_graph_config_file=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt \
  --input_side_packets=input_video_path=/absolute/path/to/the/local/video/file,output_video_path=/absolute/path/to/save/the/output/video/file,aspect_ratio=width:height
```
## Environment Variables

- GLOG_logtostderr - Google Logging Library log to stderr 0 or 1
- input_video - video name in volume your added [default: video.mp4]
- output_video - video name of the cropped video in volume [default: video_crop.mp4]
- aspect_ratio - aspect ratio width:height [default: 9:16]
- frames_output - name of the file with rectangle in input video that shows what parts will be cropped. Only if config=development or custom config file based on development config file [default: frames.mp4]
- points_output - name of file with rectangle on objects recognized by algorithm. Only if config=development or custom config file based on development config file [default: points.mp4]
- config - sets configuration file. Has two predefined values "default" and "development". "default" - is default config that return only cropped video with name from output_video. "development" - is config that return three videos: cropped video with name from output_video, video with frame in input video one cropped areas with name from frames_output, and video that points to recognized objects with name from points_output. Or can point to config file made by user that before was mounted to container for example ... -v /folder/with/custom/config/config.pbtxt:/config.pbtxt ... -e config=/config.pbtxt. [default: default]

## Volumes
- /video - Folder where all videos are processed. Sub-folder can point to different locations on host machine for example ... -v /output/path:/video/output ...

## Useful File Locations
- /mediapipe/bazel-bin/media/examples/desktop/autoflip/run_autoflip - main application it is possible to run command just from this place

- /mediapipe/Dockerfile - Dockerfile that build this container

- /mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt - default config file path

- /mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt - development config file with additional options

## Troubleshooting
If video cropped successfully application will print "Success!" to console in any other way if cropping started but not ended with this word cropping crashed. You can try extend swap of yours system or split video to less duration parts.

Additionally all input and output files should have same extension for example .mp4

## Built With
Docker 18.09.7
Ubuntu 18.04
MediaPipe v0.6.8.1
