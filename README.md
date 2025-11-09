# GnuPG for ASUSTOR NAS

This repository contains everything needed to build an ASUSTOR APK package for GnuPG (GNU Privacy Guard).

## About

GnuPG is a complete and free implementation of the OpenPGP standard as defined by RFC4880 (also known as PGP). GnuPG allows you to encrypt and sign your data and communications.

This package provides GnuPG binaries compiled for ASUSTOR NAS devices, enabling secure encryption and digital signatures directly on your NAS.

## Features

- Complete OpenPGP implementation
- S/MIME and Secure Shell support
- Command-line tools for encryption and signing
- Key management utilities

## Building

## Building

### Automated Build (GitHub Actions)

The package is automatically built using GitHub Actions on every push to the main branch. The workflow:

1. Installs required build dependencies
2. Downloads and compiles GnuPG and its dependencies from source
3. Reorganizes files into ASUSTOR package structure (bin/, lib/, libexec/ at root)
4. Validates package contents against config.json
5. Packages everything into an ASUSTOR APK file
6. Uploads the package as a build artifact

You can download the built APK from the Actions tab after a successful build.

### Manual Build

For detailed build instructions including Docker-based builds, see [QUICKSTART.md](QUICKSTART.md).

Quick summary:
```bash
git clone https://github.com/krzysbaranski/gnupg-asustor.git
cd gnupg-asustor
chmod +x build.sh
./build.sh
```

The build process:
1. `build.sh` compiles GnuPG and dependencies into a staging directory
2. `package.sh` (called by build.sh) reorganizes files into the ASUSTOR package structure
3. Files are placed in `apkg/bin/`, `apkg/lib/`, and `apkg/libexec/` directories
4. `validate-package.sh` checks that all files in config.json exist and warns about unexpected files

## Installation

1. Download the `.apk` file from the [Releases](../../releases) page or build artifacts
2. Log in to your ASUSTOR NAS web interface
3. Go to App Central
4. Click "Install Manually" (the gear icon)
5. Upload the `.apk` file
6. Follow the installation prompts

## Usage

After installation, GnuPG utilities will be available in `/usr/local/gnupg/bin/` and symlinked to `/usr/local/bin/`.

Common commands:
```bash
# Generate a key pair
gpg --gen-key

# List keys
gpg --list-keys

# Encrypt a file
gpg -e -r recipient@example.com file.txt

# Decrypt a file
gpg -d file.txt.gpg

# Sign a file
gpg -s file.txt

# Verify a signature
gpg --verify file.txt.gpg
```

For more information, see the [GnuPG documentation](https://gnupg.org/documentation/).

## Package Contents

This package includes:
- GnuPG
- libgpg-error
- libgcrypt
- libassuan
- libksba
- npth

## Development

### Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions workflow
├── apkg/
│   └── CONTROL/
│       ├── config.json        # Package metadata (static file list)
│       ├── description.txt    # Package description
│       ├── changelog.txt      # Version history
│       ├── icon.png           # Package icon
│       ├── pre-install.sh     # Pre-installation script
│       ├── post-install.sh    # Post-installation script
│       ├── pre-uninstall.sh   # Pre-uninstallation script
│       └── post-uninstall.sh  # Post-uninstallation script
├── build.sh                   # Build script for GnuPG
├── package.sh                 # Package preparation script
├── validate-package.sh        # Package validation script
├── .gitignore                 # Git ignore patterns
└── README.md                  # This file
```

### Modifying the Build

To update GnuPG or dependency versions, edit the version variables at the top of `build.sh`:

```bash
GNUPG_VERSION="2.4.5"
LIBGPG_ERROR_VERSION="1.49"
LIBGCRYPT_VERSION="1.10.3"
# ... etc
```

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

## References

- [ASUSTOR App Central Developer Guide](https://downloadgb.asustor.com/developer/App_Central_Developer_Guide_4.2.5_20231030.pdf)
- [GnuPG Official Website](https://gnupg.org/)
- [GnuPG Documentation](https://gnupg.org/documentation/)

## License

This packaging is released under GPL-3.0 license, consistent with GnuPG's license.

GnuPG itself is:
- Copyright (C) Free Software Foundation, Inc.
- Licensed under GPL-3.0-or-later

## Support

For issues related to:
- **This package**: Open an issue in this repository
- **GnuPG itself**: See [GnuPG support resources](https://gnupg.org/documentation/guides.html)
- **ASUSTOR NAS**: Contact [ASUSTOR support](https://www.asustor.com/support)
