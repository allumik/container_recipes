# This image is to run AMD GPU accelerated pytorch
# Use the official ROCm PyTorch image as the base
FROM rocm/pytorch:rocm7.0.2_ubuntu24.04_py3.12_pytorch_release_2.8.0

# Install a specific version of uv using pip from the base image.
RUN pip install --no-cache-dir uv==0.9.0

# Create and activate a virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Copy your local requirements.txt into the container
COPY requirements.txt .

# Install the python dependencies from requirements.txt into the venv using uv
RUN uv pip install --no-cache -r requirements.txt

# Set the default command to launch a bash shell when the container starts.
# The venv will be active because of the ENV PATH setting above.
CMD ["bash"]
