# Quick Start Guide

This guide will help you get started with building the GnuPG ASUSTOR package.

## Prerequisites

You need:
- A Linux environment (Ubuntu 20.04+ recommended)
- Internet connection to download sources
- About 500MB free disk space
- Build tools (see below)

## Option 1: Automated Build with GitHub Actions (Recommended)

1. Fork this repository
2. Push to the `main` or `master` branch
3. GitHub Actions will automatically build the package
4. Download the built `.apk` file from the Actions artifacts

## Option 2: Local Build

### Option 2a: Build with Docker (Recommended for Consistency)

Build inside a Docker container to ensure a consistent environment:

```bash
# Clone the repository
git clone https://github.com/krzysbaranski/gnupg-asustor.git
cd gnupg-asustor

# Build using Docker
docker run --rm -v $(pwd):/workspace -w /workspace ubuntu:22.04 bash -c "
  apt-get update && \
  apt-get install -y build-essential wget bzip2 make gettext texinfo \
    libgnutls28-dev libbz2-dev zlib1g-dev libncurses5-dev \
    libsqlite3-dev libldap2-dev libreadline-dev libusb-1.0-0-dev && \
  chmod +x build.sh && \
  ./build.sh
"
```

### Option 2b: Build Directly on Host

### Install Dependencies

On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential wget bzip2 make gettext texinfo \
  libgnutls28-dev libbz2-dev zlib1g-dev libncurses5-dev \
  libsqlite3-dev libldap2-dev libreadline-dev libusb-1.0-0-dev
```

### Build the Package

```bash
# Clone the repository
git clone https://github.com/krzysbaranski/gnupg-asustor.git
cd gnupg-asustor

# Run the build script
chmod +x build.sh
./build.sh
```

This will:
1. Download GnuPG and all dependencies
2. Compile everything
3. Install files into the `apkg/` directory

### Package the ASUSTOR APK

Using Docker:
```bash
docker run --rm \
  -v $(pwd)/apkg:/source \
  -v $(pwd)/dist:/dest \
  ghcr.io/asustor-contrib/apkg-tools:latest
```

The `.apk` file will be created in the `dist/` directory.

## Installing on ASUSTOR NAS

1. Download the `.apk` file
2. Log into your ASUSTOR NAS web interface
3. Open App Central
4. Click the gear icon and select "Install Manually"
5. Upload the `.apk` file
6. Follow the installation wizard

## Using GnuPG

After installation, connect to your NAS via SSH and run:

```bash
# Check installation
gpg --version

# Generate a new key
gpg --gen-key

# List keys
gpg --list-keys

# Encrypt a file
gpg --encrypt --recipient your@email.com file.txt

# Decrypt a file
gpg --decrypt file.txt.gpg
```

## Troubleshooting

### Build fails with "command not found"
- Make sure all dependencies are installed
- Check that you're using a compatible Linux distribution

### Build runs out of space
- Free up at least 500MB of disk space
- The build process creates temporary files in the `build/` directory

### Package installation fails on ASUSTOR
- Check that your NAS OS version is 4.0.0 or higher
- Verify the `.apk` file is not corrupted (check file size)

## Getting Help

- Check the [README.md](README.md) for detailed documentation
- Open an issue on GitHub for bugs or questions
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

## Next Steps

Once GnuPG is installed:
- Read the [GnuPG documentation](https://gnupg.org/documentation/)
- Learn about [OpenPGP best practices](https://www.gnupg.org/gph/en/manual.html)
- Consider setting up automated backups of your keys
