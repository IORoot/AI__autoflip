#!/bin/bash

# ╭───────────────────────────────────────────────────────────────────────────╮
# │         Process the video so that it reframes to new aspect ratio         │
# ╰───────────────────────────────────────────────────────────────────────────╯


# ╭──────────────────────────────────────────────────────────╮
# │                        VARIABLES                         │
# ╰──────────────────────────────────────────────────────────╯
ASPECT_RATIO="9:16"
INPUT_FILE="input.mp4"
OUTPUT_FILE="output.mp4"
CONFIG_FILE="mediapipe/examples/desktop/autoflip/autoflip_graph.pbtxt"


# ╭──────────────────────────────────────────────────────────╮
# │                          Usage.                          │
# ╰──────────────────────────────────────────────────────────╯

usage()
{
    if [ "$#" -lt 2 ]; then
 printf "ℹ️ Usage:\n $0 -i <INPUT_FILE> [-o <OUTPUT_FILE>] [-a ASPECT_RATIO]\n\n" >&2 

        printf "Summary:\n"
        printf "Change the aspect-ratio of a video.\n\n"

        printf "Flags:\n"

        printf " -i | --input <INPUT_FILE>\n"
        printf "\tThe name of an input file.\n\n"

        printf " -o | --output <OUTPUT_FILE>\n"
        printf "\tDefault is %s\n" "${OUTPUT_FILE}"
        printf "\tThe name of the output file.\n\n"

        printf " -a | --aspect <9:16>\n"
        printf "\tWidth of the output video. Default: 9:16.\n\n"

        printf " -c | --config <CONFIG_FILE>\n"
        printf "\tWidth of the output video. Default: 9:16.\n\n"

        exit 1
    fi
}



# ╭──────────────────────────────────────────────────────────╮
# │         Take the arguments from the command line         │
# ╰──────────────────────────────────────────────────────────╯
function arguments()
{
    POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
    case $1 in


        -i|--input)
            INPUT_FILE=$(realpath $2)
            shift
            shift
            ;;


        -o|--output)
            OUTPUT_FILE="$2"
            shift 
            shift
            ;;

        -a|--aspect)
            ASPECT_RATIO="$2"
            shift 
            shift
            ;;

        -c|--config)
            CONFIG_FILE="$2"
            shift 
            shift
            ;;


        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;


        *)
            POSITIONAL_ARGS+=("$1") # save positional arg back onto variable
            shift                   # remove argument and shift past it.
            ;;
    esac
    done

}


# ╭──────────────────────────────────────────────────────────╮
# │                                                          │
# │                      Main Function                       │
# │                                                          │
# ╰──────────────────────────────────────────────────────────╯
function main()
{
    
    bazel-bin/mediapipe/examples/desktop/autoflip/run_autoflip  --calculator_graph_config_file=${CONFIG_FILE} --input_side_packets= input_video_path=${INPUT_FILE},output_video_path=${OUTPUT_FILE},aspect_ratio=${ASPECT_RATIO}

}

usage $@
arguments $@
main $@