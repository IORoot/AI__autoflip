#!/bin/bash

if test $config = "development"; then
        config=mediapipe/examples/desktop/autoflip/autoflip_graph_development.pbtxt;
elif test $config = "default"; then
        config=mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt;
fi;

bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip  --calculator_graph_config_file=${config} --input_side_packets= input_video_path=/video/${input_video},output_video_path=/video/${output_video},aspect_ratio=${aspect_ratio},key_frame_crop_viz_frames_path=/video/${points_output},salient_point_viz_frames_path=/video/${frames_output}