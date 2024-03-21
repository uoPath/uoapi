ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim as base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copy the source code into the container.
COPY . .

# install the uoapi package into the container
RUN pip install -e .

# Make the output directory a volume so that the files can be accessed from the host.
VOLUME /app/output

# Switch to the non-privileged user to run the application.
USER appuser

LABEL org.opencontainers.image.source https://github.com/uoPath/uoapi

# Run the read.sh script
ENTRYPOINT ["/bin/bash", "read.bash"]