# jq for ASUSTOR NAS

This repository contains everything needed to build an ASUSTOR APK package for jq, a lightweight and flexible command-line JSON processor.

## About

jq is like sed for JSON data - you can use it to slice, filter, map and transform structured data with the same ease that sed, awk, grep and friends let you play with text.

This package provides jq binaries compiled from source for ASUSTOR NAS devices, enabling powerful JSON processing directly on your NAS.

## Features

- Lightweight and portable
- Powerful JSON processing capabilities
- Filter, map, and transform JSON data
- Zero runtime dependencies (oniguruma is statically linked)
- Perfect for working with APIs and JSON configuration files

## Building

### Automated Build (GitHub Actions)

The package is automatically built using GitHub Actions on every push to the main branch. The workflow:

1. Installs required build dependencies
2. Downloads and compiles jq and oniguruma from source
3. Reorganizes files into ASUSTOR package structure (bin/ at root)
4. Validates package contents against config.json
5. Packages everything into an ASUSTOR APK file
6. Uploads the package as a build artifact

You can download the built APK from the Actions tab after a successful build.

### Manual Build

Quick summary:
```bash
git clone https://github.com/krzysbaranski/gnupg-asustor.git -b copilot/install-jq-cli-tool jq-asustor
cd jq-asustor
chmod +x build.sh
./build.sh
```

The build process:
1. `build.sh` compiles jq and oniguruma into a staging directory
2. `package.sh` (called by build.sh) reorganizes files into the ASUSTOR package structure
3. Files are placed in `apkg/bin/` directory
4. `validate-package.sh` checks that all files in config.json exist and warns about unexpected files

## Installation

1. Download the `.apk` file from the build artifacts
2. Log in to your ASUSTOR NAS web interface
3. Go to App Central
4. Click "Install Manually" (the gear icon)
5. Upload the `.apk` file
6. Follow the installation prompts

## Usage

After installation, jq will be available in `/usr/local/jq/bin/` and symlinked to `/usr/local/bin/`.

Common commands:
```bash
# Pretty print JSON
echo '{"name":"John","age":30}' | jq .

# Extract a field
echo '{"name":"John","age":30}' | jq '.name'

# Filter array elements
echo '[{"name":"John","age":30},{"name":"Jane","age":25}]' | jq '.[] | select(.age > 26)'

# Transform data
echo '{"first":"John","last":"Doe"}' | jq '{fullname: (.first + " " + .last)}'

# Read from file
jq '.items[] | .name' data.json

# Multiple filters
jq '.users[] | select(.active == true) | {name: .name, email: .email}' users.json
```

For more information, see the [jq Manual](https://jqlang.github.io/jq/manual/).

## Package Contents

This package includes:
- jq 1.7.1
- oniguruma 6.9.9 (statically linked)

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
├── build.sh                   # Build script for jq
├── package.sh                 # Package preparation script
├── validate-package.sh        # Package validation script
├── .gitignore                 # Git ignore patterns
└── README.md                  # This file
```

### Modifying the Build

To update jq or oniguruma versions, edit the version variables at the top of `build.sh`:

```bash
JQ_VERSION="1.7.1"
ONIGURUMA_VERSION="6.9.9"
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
- [jq Official Website](https://jqlang.github.io/jq/)
- [jq Manual](https://jqlang.github.io/jq/manual/)
- [jq GitHub Repository](https://github.com/jqlang/jq)

## License

This packaging is released under MIT license, consistent with jq's license.

jq itself is:
- Copyright (C) 2012 Stephen Dolan
- Licensed under MIT License

## Support

For issues related to:
- **This package**: Open an issue in this repository
- **jq itself**: See [jq GitHub Issues](https://github.com/jqlang/jq/issues)
- **ASUSTOR NAS**: Contact [ASUSTOR support](https://www.asustor.com/support)
