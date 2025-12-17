# This image is to run AMD GPU accelerated pytorch
# Use the official ROCm PyTorch image as the base
FROM rocm/pytorch:rocm7.1_ubuntu24.04_py3.12_pytorch_release_2.9.1
# FROM rocm/tensorflow:rocm7.1.1-py3.12-tf2.18-dev

# 1. Fetch uv binary directly (No pip required)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# 2. Create the virtual environment using uv
# This bypasses 'python -m venv' and avoids the broken ensurepip/venv modules
ENV VIRTUAL_ENV=/opt/venv
RUN uv venv $VIRTUAL_ENV --system-site-packages

# 3. add venv to path
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# uv pip install works even without pip installed in the venv
RUN uv pip install --no-cache euporie

COPY requirements.txt .
RUN uv pip install --no-cache -r requirements.txt

# Set the default command to launch a bash shell when the container starts.
# The venv will be active because of the ENV PATH setting above.
CMD ["bash"]
