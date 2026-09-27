# Installation Guide

Welcome to the **m-vis** installation guide. You can install `m-vis` via automated scripts, pre-built binaries, cargo, or from source.

---

## 1. Automated Install Scripts (Recommended)

### macOS / Linux
Run the following command in your terminal:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/SickleFire/m-vis/master/install.sh | sh
```
Or using `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/SickleFire/m-vis/master/install.sh | sh
```

### Windows (PowerShell)
Open PowerShell as Administrator (or standard user) and run:
```powershell
iex (iwr -useb https://raw.githubusercontent.com/SickleFire/m-vis/main/install.ps1)
```

---

## 2. Pre-built Binaries
You can download pre-compiled binaries for Linux, macOS, and Windows directly from the [GitHub Releases](https://github.com/SickleFire/m-vis/releases) page. Extract the binary and place it in a directory included in your system's `PATH`.

---

## 3. Installing via Cargo (Rust Package Manager)
If you have the Rust toolchain installed, you can install `m-vis` directly from crates.io (or git):
```bash
# From local source or git repo
cargo install --path .
```

---

## 4. Building from Source

To build `m-vis` from source, ensure you have Rust (stable) installed:

```bash
# Clone the repository
git clone https://github.com/SickleFire/m-vis.git
cd m-vis

# Build release binary
cargo build --release

# The compiled binary will be located at:
# target/release/mvis (Linux/macOS)
# target\release\mvis.exe (Windows)
```

---

## Post-Installation Notes

- **macOS**: `m-vis` requires the `com.apple.security.cs.debugger` code-signing entitlement to inspect other processes due to macOS Hardened Runtime restrictions. See the [macOS Security & Code Signing](#macos-security--code-signing) section in the README for details.
- **Windows**: Windows Defender or other AV utilities may occasionally flag unsigned binaries. See [Windows Antivirus False Positives](#windows-antivirus-false-positives--execution-warnings) for troubleshooting.
