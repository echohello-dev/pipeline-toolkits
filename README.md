# Pipeline Toolkits

This repository contains a collection of tools for working with cloud services, packaged into a Docker container for use in runner jobs.

## Getting Started

### Prerequisites

* Docker
* GitHub account with a generated GitHub token

### Building the Docker Image

To build the Docker image, you need to set the `NAME` environment variable. You can do this in the terminal session where you're running the `make` command:

```sh
make build NAME=cloud
```

### Publishing the Docker Image

To publish the Docker image to GitHub's container registry, you need to set the `GITHUB_TOKEN` and `NAME` environment variables. You can do this in the terminal session where you're running the `make` command:

```sh
make publish GITHUB_TOKEN=your_github_token NAME=cloud
```

This will log in to GitHub's container registry using the provided GitHub token, build the Docker image, and push it to the registry.