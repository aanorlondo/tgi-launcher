#!/bin/bash

set -e

function pick_model() {
    local models=("$@") # Accept models as an array
    printf "Available models:\n" >/dev/tty
    for i in "${!models[@]}"; do
        printf "%d) %s\n" $((i + 1)) "${models[$i]}" >/dev/tty
    done

    while true; do
        read -p "Enter the number of the model you want to use: " choice </dev/tty
        if [[ $choice -ge 1 && $choice -le ${#models[@]} ]]; then
            echo "${models[$((choice - 1))]}" # Return the selected model
            return
        else
            printf "Invalid choice. Please select a valid number.\n" >/dev/tty
        fi
    done
}

# Extract the server configuration from config.json
current_dir_path="$(dirname "$(readlink -f "$0")")"
config_file="$current_dir_path/config.json"
if [[ -f "$config_file" ]]; then
    server_port=$(jq -r '.server.port // empty' "$config_file")
    container_name=$(jq -r '.server.container_name // empty' "$config_file")
    container_image=$(jq -r '.server.container_image // empty' "$config_file")
    # Read models as a JSON array and convert it to a Bash array
    mapfile -t models < <(jq -r '.server.models[]' "$config_file")

    if [[ -z "$server_port" ]]; then
        echo "Error: 'server_port' key is missing or null in $config_file"
        exit 1
    fi
    if [[ ${#models[@]} -eq 0 ]]; then
        echo "Error: 'models' key is missing or empty in $config_file"
        exit 1
    fi
    if [[ -z "$container_name" ]]; then
        echo "Error: 'container_name' key is missing or null in $config_file"
        exit 1
    fi
    if [[ -z "$container_image" ]]; then
        echo "Error: 'container_image' key is missing or null in $config_file"
        exit 1
    fi
else
    echo "Error: '$config_file' not found"
    exit 1
fi

# volume to download the model locally
volume="$current_dir_path/data"
if [[ ! -d $volume ]]; then
    mkdir -p $volume
fi

# Display a banner to introduce the script
echo "###############################################"
echo "#                                             #"
echo "#   NVIDIA Docker TGI Server Launcher Script  #"
echo "#                                             #"
echo "###############################################"
echo ""
echo "This script will run an NVIDIA Docker container with the TGI server."
echo "You will be prompted to select a model from the list of available models."
echo ""

# Pick a model from the list
model=$(pick_model "${models[@]}")
if [[ -z "$model" ]]; then
    echo "Error: no 'model' has been selected"
    exit 1
fi

# Write the selected model to the session.json file under the key "model"
echo "--- Writing selected model to 'session.json' (to be displayed in client)..."
session_file="$current_dir_path/session.json"
if [[ -f "$session_file" ]]; then
    jq --arg model "$model" '.model = $model' "$session_file" >"$session_file.tmp" && mv "$session_file.tmp" "$session_file"
else
    echo "{\"model\": \"$model\"}" >"$session_file"
fi

# Start container
echo "--- Removing any existing TGI server container..."
docker container rm $container_name || true
echo ""
echo "--- Starting TGI server with the following configuration:"
echo "Server Port: '$server_port'"
echo "Container Name: '$container_name'"
echo "Container Image: '$container_image'"
echo "Model: '$model'"
echo "Volume: '$volume'"
echo ""
echo "--- Starting TGI server..."
docker run --gpus all --shm-size 64g -p $server_port:80 -v $volume:/data \
    --net host \
    -e HF_HUB_DISABLE_PROGRESS_BARS:"true" \
    -e HF_HUB_ENABLE_HF_TRANSFER="false" \
    --name $container_name \
    $container_image \
    --model-id $model
