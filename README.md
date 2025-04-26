# TGI LAUNCHER

## Overview

The TGI Launcher is a tool designed to simplify the deployment and interaction with text-generation models using NVIDIA GPUs. It leverages Docker containers and Gradio for hosting and interacting with models locally.

## Features

- **Model Selection**: Dynamically select from a list of pre-configured models.
- **Docker Integration**: Automatically sets up and runs a Docker container for the selected model.
- **Gradio UI**: Provides a user-friendly interface for interacting with the text-generation model.
- **Session Management**: Saves the selected model in `session.json` for consistent client display.

## Prerequisites

- NVIDIA GPU with drivers installed.
- Docker and NVIDIA Container Toolkit.
- Python 3.x and `pip` for setting up the virtual environment.

## Setup Instructions

1. Clone the repository and navigate to the project directory:
   ```bash
   git clone <repository-url>
   cd tgi-with-nvidia
   ```

2. Install the required Python dependencies:
    ```
    bash venv_install.sh
    ```

3. Start the server:
    ```
    bash start_server.sh
    ```

4. Access the Gradio UI at `http://127.0.0.1:8080`

## Configuration

- Models: Add or modify models in `config.json` under the `server.models` key.
- Docker Image: Update the `server.container_image` key in `config.json` to use a different TGI image.
- Port: Change the `server.port` key in `config.json` to run the server on a different port.

## File Structure
- `config.json`: Configuration for server and client.
- `session.json`: Stores the currently selected model.
- `start_server.sh`: Script to launch the Docker container.
- `ui.py`: Gradio-based UI for interacting with the model.
- `venv_install.sh`: Script to set up the Python virtual environment.


## Example Usage
1. Run `start_server.sh` and select a model from the list.
2. Open the Gradio UI in your browser.
3. Enter a prompt and interact with the model.