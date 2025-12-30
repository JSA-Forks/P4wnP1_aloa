# P4wnP1 A.L.O.A. Installation Guide (2025 Updated)

**Note:** The original pre-built images for this project are years old and no longer work. You must install P4wnP1 on top of a fresh operating system.

## Phase 1: Create the Base SD Card

Since you cannot download a ready-made image, you will create your own using the **Raspberry Pi Imager**.

1.  **Download:** [Raspberry Pi Imager](https://www.raspberrypi.com/software/) for Windows.
2.  **Choose OS:**
    *   Click "CHOOSE OS".
    *   Select **Raspberry Pi OS (other)** -> **Raspberry Pi OS Lite (64-bit)** (or 32-bit if using an older Pi Zero 1).
    *   *Alternative:* You can also use **Kali Linux** (under "Other general-purpose OS" -> "Kali Linux").
3.  **Choose Storage:** Select your SD card.
4.  **Configure Settings (The Gear Icon):**
    *   **Hostname:** `p4wnp1`
    *   **Enable SSH:** Use password authentication.
    *   **Set username/password:** e.g., `pi` / `raspberry` (or whatever you prefer).
    *   **Configure Wireless LAN:** Enter your WiFi credentials so the Pi connects to your network on first boot.
5.  **Write:** Click "WRITE" and wait for it to finish.

## Phase 2: Copy the Installer

Once the Pi is booted and connected to your WiFi:

1.  **Find the IP address** of your Pi (check your router or use a network scanner).
2.  **Open Windows PowerShell** and navigate to this folder (where you see this file):
    ```powershell
    cd C:\Github\P4wnP1_aloa
    ```
3.  **Copy ONLY the Fix Script:**
    Run this command in PowerShell to send the script to your Pi:
    ```powershell
    scp fix_pi_install.sh pi@<YOUR_PI_IP>:~/
    ```
    *(Replace `<YOUR_PI_IP>` with the actual address, e.g., `192.168.1.50`)*

    **Note:** You do **NOT** need to copy the whole P4wnP1_aloa folder. The script will automatically download the rest of the files directly onto the Pi when you run it in the next step.

## Phase 3: Run the Installation

1.  **SSH into the Pi:**
    ```powershell
    ssh pi@<YOUR_PI_IP>
    ```
2.  **Run the Script:**
    ```bash
    chmod +x fix_pi_install.sh
    sudo ./fix_pi_install.sh
    ```
3.  **Wait:** The script will:
    *   **Automatically download the P4wnP1 A.L.O.A. repository** from GitHub.
    *   Install all necessary packages.
    *   Compile the code and set up the services.
    
    This process may take 10-20 minutes on a Pi Zero.
4.  **Reboot:**
    ```bash
    sudo reboot
    ```

## Phase 4: Connection

After rebooting, P4wnP1 should take over. The default behavior (if using the default config) is often to spawn a WiFi Access Point or enable USB Ethernet.

-   **USB:** Connect the Pi's **USB Data Port** (the inner one) to your PC. It should appear as a network adapter.
    -   Address: `172.16.0.1`
-   **WiFi:** Check for a WiFi network named `P4wnP1`.
    -   Password: `MaMe82-P4wnP1`
    -   Address: `172.24.0.1`

You can now use the **Client** tools you set up on Windows:
```powershell
./P4wnP1_cli.exe --host 172.16.0.1 info
```
