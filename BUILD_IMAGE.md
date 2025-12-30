# How to Build a Custom P4wnP1 Image

If you prefer to have a ready-to-flash `.img` file instead of installing manually on the Pi, you can use the included `build_image.sh` script.

**System Requirements:**
-   **Operating System:** Linux (Ubuntu, Debian, Kali). This **CANNOT** be run directly on Windows or macOS.
-   **Root Privileges:** The script requires `sudo` to mount disk images.

## Instructions

1.  **Transfer Files to Linux:**
    Copy `build_image.sh` and `fix_pi_install.sh` to a folder on your Linux machine.

2.  **Install Dependencies:**
    ```bash
    sudo apt-get update
    sudo apt-get install -y kpartx qemu-user-static git curl xz-utils
    ```

3.  **Run the Builder:**
    ```bash
    chmod +x build_image.sh
    sudo ./build_image.sh
    ```

4.  **Wait:**
    The script will:
    -   Download the latest Raspberry Pi OS Lite.
    -   Mount it as a virtual drive.
    -   Running the P4wnP1 installer *inside* the image.
    -   Save the result as `P4wnP1_aloa_rpi0w_2025.1.img`.

5.  **Flash:**
    Transfer the resulting `.img` file back to your Windows PC and flash it using **Raspberry Pi Imager**.

## Why Linux Only?
The script relies on `loop` devices and `kpartx` to mount the `.img` file as a real filesystem. This functionality is native to Linux and difficult to replicate reliably on Windows.
