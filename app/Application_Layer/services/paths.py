import os
# Get the base path of the current file
base_path = os.path.dirname(os.path.abspath(__file__))
uploads_path = os.path.join(base_path, "uploads")
outputs_path = os.path.join(base_path, "outputs")

def getPaths():
    return base_path,uploads_path,outputs_path