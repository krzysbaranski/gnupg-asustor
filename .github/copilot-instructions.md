# GitHub Copilot Instructions for gnupg-asustor

## Project Overview
This repository creates an APK (APKG) package of GnuPG (GNU Privacy Guard) for Asustor NAS devices. GnuPG is a free and open-source encryption tool that implements the OpenPGP standard for encrypting, decrypting, signing, and verifying data.

## Build Requirements

### Asustor APK Package Structure
Follow the Asustor App Central Developer Guide (v4.2.5) when creating the APK package:

- **Directory Structure:**
  - `bin/` - Executables and binary files for GnuPG
  - `CONTROL/` - Control and metadata files:
    - `config.json` - App configuration with package metadata
    - `icon.png` - Application icon
    - `license.txt` - GnuPG license (GNU GPL)
    - `description.txt` - App description
    - `changelog.txt` - Version history
    - `pre-install.sh`, `post-install.sh` - Installation scripts
    - `pre-uninstall.sh`, `post-uninstall.sh` - Uninstallation scripts
    - `start-stop.sh` - Service management scripts (if needed)
  - `etc/` - Configuration files for GnuPG
  - `lib/` - Required libraries and dependencies

### Package Metadata Requirements
- Specify supported CPU architectures (e.g., x86_64, ARM)
- Include minimum ADM (Asustor Data Master) firmware version
- Provide developer name and contact information
- Version numbers should follow semantic versioning

### Build Tools
- Use official ASUSTOR APKG utilities or `apkg-tools.py` to create the package
- Consider using GitHub Actions with `asustor-contrib/ga-package-asustor-app` for CI/CD
- Test the package on actual Asustor NAS devices before release

## Code Style and Standards

### Shell Scripts
- Use `#!/bin/bash` or `#!/bin/sh` as appropriate
- Follow POSIX compliance for maximum compatibility
- Add error handling with `set -e` to exit on errors
- Validate user input and handle edge cases
- Include clear comments for complex operations

### Configuration Files
- Use JSON format for `config.json` with proper validation
- Keep configuration files well-documented
- Use absolute paths where required by Asustor
- Ensure all paths are Asustor NAS compatible

## Security Practices

### GnuPG-Specific Security
- Never include or generate private keys in the package
- Do not log sensitive information (keys, passphrases, encrypted data)
- Ensure proper file permissions for GnuPG directories:
  - `~/.gnupg/` should be `700` (owner only)
  - Private keys should be `600` (owner read/write only)
- Use secure random number generation
- Follow GnuPG best practices for key management

### General Security
- Validate all external input in installation scripts
- Sanitize file paths to prevent directory traversal
- Use HTTPS for any external downloads
- Verify checksums/signatures of downloaded components
- Avoid hardcoded credentials or secrets

## Installation and Uninstallation

### Installation Scripts
- Check for existing GnuPG installations to prevent conflicts
- Verify system requirements and dependencies
- Create necessary directories with proper permissions
- Provide clear error messages if installation fails
- Handle upgrade scenarios gracefully

### Uninstallation Scripts
- Remove only files installed by this package
- Preserve user data and keys by default
- Provide option to completely remove all data
- Clean up temporary files and directories
- Restore system to pre-installation state

## Testing and Validation

### Pre-Release Testing
- Test installation on supported Asustor NAS models
- Verify all GnuPG commands work correctly:
  - Key generation (`gpg --gen-key`)
  - Encryption (`gpg --encrypt`)
  - Decryption (`gpg --decrypt`)
  - Signing (`gpg --sign`)
  - Verification (`gpg --verify`)
- Test upgrade scenarios from previous versions
- Validate uninstallation removes package cleanly
- Check package integrity with APKG tools

### Compatibility Testing
- Test on different Asustor NAS architectures
- Verify compatibility with current ADM versions
- Check interaction with other installed packages
- Test with different file system configurations

## Documentation

### User Documentation
- Provide clear installation instructions
- Include basic GnuPG usage examples
- Document known limitations or issues
- Explain how to backup/restore GPG keys
- Include troubleshooting guide

### Developer Documentation
- Document build process step-by-step
- Explain package structure and file purposes
- List all dependencies and their versions
- Include instructions for testing changes
- Maintain changelog with version history

## Dependencies and Libraries

### GnuPG Dependencies
- List all required libraries (libgpg-error, libgcrypt, etc.)
- Specify minimum versions for dependencies
- Include dependencies in package or document how to obtain them
- Consider static linking for better compatibility

### Asustor Platform Dependencies
- Ensure compatibility with Asustor's Linux distribution
- Verify all dependencies are available or bundled
- Test with minimal Asustor installation

## Release Process

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update changelog before each release
- Tag releases in git repository
- Match package version with GnuPG version being packaged

### Quality Assurance
- Test package on multiple Asustor models
- Verify signature and checksums
- Review all installation/uninstallation scripts
- Check for security vulnerabilities
- Validate metadata and descriptions

## Asustor App Central Guidelines

### Content Requirements
- Provide accurate and complete app description
- Use clear, professional language
- Include screenshots if applicable
- Follow Asustor's content policies
- Respect intellectual property rights

### Submission Process
- Register at ASUSTOR Developer Corner
- Submit package for review
- Address any feedback from Asustor review team
- Update package as needed for approval

## Additional Notes

- Always refer to the official Asustor App Central Developer Guide for the most current requirements
- GnuPG is licensed under GNU GPL - ensure license compliance
- Consider localization for international users
- Monitor GnuPG security advisories and update package accordingly
- Provide support channels for users
