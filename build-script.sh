#!/bin/bash
set -e  # Agar koi command fail ho to script turant ruk jayega

# Directory info
BUILD_DIR=/srv/builds
WORKDIR=/srv

echo "[+] Starting Fedora CoreOS Build Process"

# Step 1: Initialize CoreOS Assembler if needed
if [ ! -d "${WORKDIR}/src/config" ]; then
    echo "[*] Running coreos-assembler init"
    podman run --privileged --rm \
        -e COSA_NO_KVM=1 \
        -v "${WORKDIR}":/srv:z \
        quay.io/coreos-assembler/coreos-assembler:latest init https://github.com/coreos/fedora-coreos-config
else
    echo "[*] Config already initialized"
fi

# Step 2: Run the build process
echo "[*] Running coreos-assembler build"
podman run --privileged --rm \
    -e COSA_NO_KVM=1 \
    -v "${WORKDIR}":/srv:z \
    quay.io/coreos-assembler/coreos-assembler:latest build

# Step 3: Build QEMU Image Extension
echo "[*] Running coreos-assembler buildextend-qemu"
podman run --privileged --rm \
    -e COSA_NO_KVM=1 \
    -v "${WORKDIR}":/srv:z \
    quay.io/coreos-assembler/coreos-assembler:latest buildextend-qemu

echo "[+] Build Completed Successfully!"
