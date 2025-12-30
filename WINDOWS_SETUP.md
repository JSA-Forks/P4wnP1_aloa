# P4wnP1 A.L.O.A. on Windows

**Important:** P4wnP1 A.L.O.A. is a framework designed to run on a **Raspberry Pi Zero W**. You cannot "install" the full P4wnP1 service on Windows.

However, you **can** install and use the **Client** tools on Windows to control your P4wnP1 device remotely.

## Prerequisites

To build the client tools or develop on Windows, you need the following installed:

1.  **Go (Golang):** Required to compile the `P4wnP1_cli` tool.
    *   Download: [https://go.dev/dl/](https://go.dev/dl/)
2.  **Node.js & npm:** Required if you want to modify or build the Web Client.
    *   Download: [https://nodejs.org/](https://nodejs.org/)
3.  **Python:** Required for some helper scripts.
    *   Download: [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)

## Quick Check

Run the included PowerShell script to check your environment:

```powershell
./check_requirements.ps1
```

## How to Build the CLI Client

Once you have Go installed:

1.  Open a terminal in this directory.
2.  Run the build command:
    ```powershell
    go build -o P4wnP1_cli.exe ./cmd/P4wnP1_cli
    ```
3.  You can now use the client to connect to your Pi (assuming it's connected via USB/WiFi):
    ```powershell
    # Example: Connect to P4wnP1 at default USB IP
    ./P4wnP1_cli.exe --host 172.16.0.1 info
    ```

## Troubleshooting

-   **"command not found"**: Ensure you have verified the prerequisites are installed and added to your system PATH.
-   **"gcc: executable file not found"**: Some Go packages require CGO. You might need to install TDM-GCC or MinGW-w64. However, the P4wnP1 CLI should compile without CGO for basic usage.
