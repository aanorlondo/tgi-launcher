import gradio as gr
from huggingface_hub import InferenceClient


def load_config():
    """
    Load the configuration from config.json.
    Returns:
        dict: Configuration dictionary.
    """
    try:
        import os, json

        config_file_path = os.path.join(os.path.dirname(__file__), "config.json")
        with open(os.path.join(config_file_path)) as f:
            config = json.load(f)
            if "client" not in config:
                raise ValueError(
                    f"Invalid config.json file. 'client' key not found in {config_file_path}."
                )
            return config.get("client")
    except FileNotFoundError:
        print(
            f"config.json file not not found at '{config_file_path}'. Please create it."
        )
        exit(1)
    except ValueError as e:
        print(e)
        exit(1)


def load_session():
    """
    Load the session from session.json.
    Returns:
        dict: Session dictionary.
    """
    try:
        import os, json

        session_file_path = os.path.join(os.path.dirname(__file__), "session.json")
        with open(os.path.join(session_file_path)) as f:
            session = json.load(f)
            if "model" not in session:
                raise ValueError(
                    f"Invalid session.json file. 'model' key not found in {session_file_path}."
                )
            return session
    except FileNotFoundError:
        print(
            f"session.json file not found at '{session_file_path}'. Please create it."
        )
        exit(1)
    except ValueError as e:
        print(e)
        exit(1)


# Setup config
config = load_config()
session = load_session()
MODEL = session.get("model")
TITLE = config.get("title")
HARDWARE = config.get("hardware")
MODEL_DESCRIPTION = config.get("model").replace("__MODEL_NAME_PLACEHOLDER__", MODEL)
MAX_TOKENS = config.get("max_tokens")
SYSTEM_PROMPT = config.get("system_prompt")
EXAMPLES = config.get("examples", [])


# Start client
client = InferenceClient(base_url="http://127.0.0.1:8080")


# Define the inference function
def inference(message, history):
    partial_message = ""
    output = client.chat.completions.create(
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": message},
        ],
        stream=True,
        max_tokens=MAX_TOKENS,
    )
    for chunk in output:
        partial_message += chunk.choices[0].delta.content
        yield partial_message


def description() -> str:
    return f"{HARDWARE}<br>{MODEL_DESCRIPTION}"


# Run the UI app
gr.ChatInterface(
    inference,
    type="messages",
    description=description(),
    title=TITLE,
    examples=EXAMPLES,
).queue().launch(
    share=False,
)
