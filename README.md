# workstation-container

A container with all required CLI tools to use as a workstation on Kubernetes clusters

## Generate a key pair

```
ssh-keygen -t ed25519 -b 2048 -N '' -f files/id_ed25519
```

## Build the container iamge

Build for both ARM and x86 CPU architectures

```
podman build --jobs 2 --platform linux/amd64,linux/arm64 --manifest workstation:1.0 .
```

Push the manifest to your container registry

```
export CR=quay.io
export UN=rthollibm
podman manifest push workstation:1.0 docker://${CR}/${UN}/workstation:1.0
```

## Start the container locally

privileged mode for podman is required

```
podman run --privileged -d -p 1022:1022 --name workstation workstation:1.0
```

## Deploy the container to OpenShift

change into the files folder and apply the k8s-manifest.yaml file

```
cd files
oc apply -f k8s-manifest.yaml
```

Bind the `anyuid` security context constraint to the new service account

```
oc adm policy add-scc-to-user anyuid -z oc-cli-sa
```
