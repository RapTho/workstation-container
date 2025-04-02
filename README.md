# workstation-container

A container with all required CLI tools to use as a workstation on Kubernetes clusters

## Generate a key pair

```
ssh-keygen -t ed25519 -b 2048 -N '' -f files/id_ed25519
```

## Build the container iamge

```
podman build --platform linux/amd64,linux/arm64 -t workspace:1.0 .
```

## Start the container

privileged mode for podman is required

```
podman run --privileged -d -p 1022:1022 --name workstation workstation:1.0
```
