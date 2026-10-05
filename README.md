# LitePHP

LitePHP is a lightweight, portable Windows launcher for running multiple PHP versions with an optional MySQL server.

Project website: [litewamp.localphp.net](https://litewamp.localphp.net/)

It uses PHP's built-in development server, requires no Apache installation, does not register Windows services, and resolves every runtime path relative to `LitePHP.bat`. The complete local environment can therefore be moved to another directory or drive without changing the launcher.

> LitePHP is intended for local development only. PHP's built-in server and the default MySQL configuration must not be exposed to untrusted networks or used as a production stack.

## Features

- Discovers every PHP version stored directly under `PHP\`.
- Provides a visual manager for extensions and the main `php.ini` options, independently for every PHP version.
- Automatically normalizes the portable Windows extension directory to exactly `extension_dir = "ext"` before validating and saving each PHP configuration.
- Discovers every MySQL version stored directly under `MySQL\`.
- Supports spaces in runtime and project paths.
- Lets the user choose the PHP version, project document root, HTTP port, and optional MySQL version.
- Uses port `80` by default, making the project available at `http://localhost/` without an explicit port.
- Stores the selected environment in a generated `LitePHP.ini` file.
- Shows a configuration summary on later launches and lets the user reuse or replace it.
- Initializes a separate MySQL data directory for each MySQL version.
- Keeps PHP request logs visible in the LitePHP terminal.
- Starts MySQL without opening an additional terminal window.
- Stops PHP and performs a controlled MySQL shutdown when the user presses `Q`.
- Detects occupied HTTP and MySQL ports before starting services.

## Repository contents

The Git repository intentionally contains the launcher and documentation, but not third-party PHP/MySQL distributions or machine-generated database files.

This keeps the repository small and prevents local configuration, database contents, generated certificates, hostnames, logs, and vendor debug symbols from being published.

After cloning, add the desired official Windows ZIP distributions locally as described below.

## Requirements

- Windows 10 or Windows 11.
- `cmd.exe` and standard Windows command-line utilities.
- Windows PowerShell 5.1 with Windows Forms, included with supported Windows 10 and Windows 11 installations.
- At least one Windows PHP ZIP distribution containing `php.exe`.
- Optionally, a MySQL Community Server Windows ZIP distribution containing `bin\mysqld.exe` and `bin\mysqladmin.exe`.
- The Microsoft Visual C++ Redistributable required by the selected PHP and MySQL builds.
- An available TCP port for PHP and, when enabled, port `3306` for MySQL.

Official downloads:

- [PHP for Windows](https://windows.php.net/)
- [MySQL Community Server](https://dev.mysql.com/downloads/mysql/)

For PHP CLI development, an x64 Non Thread Safe build is generally sufficient. Always choose a build compatible with the Windows architecture and installed Visual C++ runtime.

For MySQL, download the standard Windows ZIP archive, not the larger debug binaries and test-suite archive.

## Installation

### 1. Clone or download LitePHP

```powershell
git clone https://github.com/borindesign/LitePHP.git
cd LitePHP
```

The directory can be placed anywhere, for example:

```text
C:\Tools\LitePHP
D:\Development\LitePHP
E:\Portable\LitePHP
```

No path is hard-coded in the launcher.

### 2. Add PHP versions

Extract each PHP ZIP archive into a separate direct child of `PHP\`:

```text
LitePHP\
└── PHP\
    ├── php-8.2.30\
    │   ├── php.exe
    │   ├── php.ini
    │   └── ext\
    └── php-8.4.19\
        ├── php.exe
        ├── php.ini
        └── ext\
```

The directory name is used as the menu label. The displayed runtime version is read from `php.exe -n -v`, so an incorrect folder name does not change the detected version.

If the distribution does not contain `php.ini`, copy one of the supplied templates:

```powershell
Copy-Item php.ini-development php.ini
```

For a portable configuration, use a relative extension directory:

```ini
extension_dir = "ext"
```

Enable only the extensions required by the project. Typical MySQL applications use:

```ini
extension=mysqli
extension=pdo_mysql
```

Do not copy absolute `extension_dir` values from another computer, and do not enable Unix `.so` extensions in a Windows PHP configuration.

### 3. Add MySQL versions

Extract each MySQL Windows ZIP archive into a separate direct child of `MySQL\`:

```text
LitePHP\
└── MySQL\
    ├── mysql-8.0.46\
    │   └── bin\
    │       ├── mysqld.exe
    │       └── mysqladmin.exe
    └── mysql-8.4.x\
        └── bin\
            ├── mysqld.exe
            └── mysqladmin.exe
```

LitePHP creates these items when needed:

```text
mysql-version\
├── data\
├── logs\
│   ├── mysql-error.log
│   └── mysql.pid
└── litephp.ini
```

Do not share one `data\` directory between different MySQL versions. Storage formats and upgrade rules can differ between releases.

## First run

### Custom launcher icon

The original project icon is stored in `assets/LitePHP.svg`. `assets/LitePHP.ico` contains the Windows icon in multiple resolutions. A Batch file cannot embed its own icon; use the `LitePHP.lnk` shortcut to launch the manager with the custom icon.

Create or refresh the shortcut in the package directory with Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\LitePHP.CreateShortcut.ps1
```

Run this command again after moving or copying the package to another path. The shortcut contains local paths and is excluded from Git. The visual PHP configuration manager uses the same icon.

### Upgrading from LiteWAMP

The launcher migrates an existing `LiteWAMP.ini` to `LitePHP.ini` when the new file is absent, preserving the selected PHP version, project root, ports, and MySQL settings. MySQL's per-version `litewamp.ini` is migrated to `litephp.ini` in the same way. If both names exist, the LitePHP file takes precedence and the old file is retained.

The PHP manager recognizes the original `.litewamp.bak` backup when a `.litephp.bak` backup is absent. On the next successful save it copies the original backup to the new name, preserving its contents. Old managed block markers are converted to LitePHP when saving, including after restoring a legacy backup.

The existing local checkout may remain at `C:\SANDBOX\LiteWAMP`; branding does not require renaming its directory or changing the saved `project_dir`. The public website remains at `litewamp.localphp.net` until its domain is migrated separately. GitHub links use `https://github.com/borindesign/LitePHP`.

### Starting the launcher

Double-click `LitePHP.bat` or run it from a terminal:

```powershell
.\LitePHP.bat
```

When `LitePHP.ini` does not exist, the launcher asks for:

1. PHP version.
2. Project document root.
3. HTTP port.
4. MySQL version, or no database.

Press Enter at the HTTP port prompt to select port `80`.

After the wizard is completed, the selected configuration is saved to `LitePHP.ini` next to the launcher.

## Reusing or replacing a configuration

When `LitePHP.ini` already exists, LitePHP displays a complete summary and offers:

```text
[U] Use this configuration
[E] Configure PHP extensions and options
[N] Create a new configuration and replace the saved one
[Q] Quit
```

Choosing `N` removes the previous generated configuration and starts the setup wizard again.

If a configured runtime or project directory no longer exists, the configuration is considered invalid and LitePHP starts a new setup automatically.

## Managing PHP extensions and options

Choose `E` from the saved-configuration menu to open the visual PHP configuration manager. Select a PHP version at the top of the window, then use the two tabs:

- **Extensions** discovers the available `ext\php_*.dll` files, reads `extension=` and `zend_extension=` directives, and provides search, checkboxes, and a shortcut for selecting common extensions.
- **Main options** manages frequently used settings with checkboxes or validated text fields: `allow_url_fopen`, `display_errors`, `log_errors`, `short_open_tag`, `expose_php`, `max_execution_time`, `max_input_time`, `post_max_size`, `upload_max_filesize`, `max_file_uploads`, `max_input_vars`, and `memory_limit`.

Every version keeps its own independent values in its own `php.ini`. Changing the selected version reloads both tabs. If there are unsaved changes, the manager asks whether to save, discard, or cancel the version change. The same protection is applied when closing the window.

The manager validates integer values and the `K`, `M`, and `G` size suffixes before saving. It also requires `post_max_size` to be greater than `upload_max_filesize` and warns when `memory_limit` is lower than `post_max_size`. The `short_open_tag` option remains available for compatibility but is marked as deprecated starting with PHP 8.5.

Changes are first written to a temporary configuration. Before validation, the manager ensures that exactly one active `extension_dir = "ext"` directive is present; commented, missing, duplicated, absolute, or otherwise incompatible values are normalized for portable Windows use. The manager then starts the matching `php.exe`, checks the loaded modules, and reads back the effective option values. Only a successful validation replaces the real `php.ini`. If validation fails, the current file is left unchanged and the PHP startup error is displayed; missing DLL dependencies therefore do not silently produce a broken saved configuration.

The first successful change creates one original backup beside the configuration:

```text
PHP\php-version\php.ini.litephp.bak
```

Use **Restore backup** to return to that original configuration. When `php.ini` is missing, the manager can create it from `php.ini-development`, falling back to `php.ini-production` when necessary.

Existing directives are updated in place while comments, encoding, line endings, and unrelated settings are preserved. Missing extension directives are placed between `BEGIN LitePHP managed extensions` and `END LitePHP managed extensions`; missing main options use the separate `BEGIN LitePHP managed settings` and `END LitePHP managed settings` block. Changes take effect the next time that PHP version starts and do not alter an already running PHP process.

## Generated configuration

An example `LitePHP.ini` file looks like this:

```ini
format_version=1
php_version=php-8.4.19
project_dir=D:\Projects\example-app
http_port=80
mysql_enabled=1
mysql_version=mysql-8.0.46
mysql_port=3306
auto_shutdown=1
```

This file is machine-specific and is intentionally excluded from Git.

## Starting the environment

When the selected configuration starts, LitePHP:

1. Verifies that the HTTP port is available.
2. Initializes the selected MySQL data directory when necessary.
3. Starts MySQL in the background without a second terminal window.
4. Waits until MySQL responds.
5. Starts the PHP development server.
6. Displays PHP request logs in the main terminal.

When port `80` is selected, open `http://localhost/`. For another port, such as `8080`, open `http://localhost:8080/`.

## Stopping LitePHP safely

While the environment is running, the terminal displays:

```text
[Q] Stop LitePHP
```

Press `Q` to perform the controlled shutdown sequence:

1. Terminate the PHP development server.
2. Send `mysqladmin shutdown` to the MySQL instance started by LitePHP.
3. Confirm that both services have stopped.
4. Return to the main menu.

Do not close the terminal with the window close button while the environment is running. A Batch process cannot reliably execute cleanup code after its console is forcibly closed, and MySQL might remain active or be terminated without a controlled shutdown.

## MySQL initialization and credentials

When a selected MySQL version has no initialized `data\mysql` directory, LitePHP runs MySQL with `--initialize-insecure`.

This creates a local `root` account without an initial password. The generated server configuration binds MySQL to the local computer only.

This behavior is convenient for an isolated development environment but is not secure for production or an untrusted workstation.

If the root password is changed, automatic shutdown through the generated client configuration will no longer work unless valid credentials are made available to `mysqladmin`. Avoid storing reusable production credentials in this directory.

## Logs

### PHP

PHP request logs remain visible in the main LitePHP terminal while the server runs.

```text
127.0.0.1:53120 Accepted
127.0.0.1:53120 [200]: GET /
127.0.0.1:53120 Closing
```

### MySQL

MySQL writes its server log to:

```text
MySQL\mysql-version\logs\mysql-error.log
```

Use this file when MySQL does not initialize, start, or stop correctly.

## Adding or removing versions

To add a version:

1. Stop LitePHP by pressing `Q`.
2. Extract the runtime into a new direct child of `PHP\` or `MySQL\`.
3. Start LitePHP again.
4. Choose `N` when asked whether to reuse the saved configuration.

To remove a version:

1. Stop LitePHP.
2. Back up any required MySQL databases.
3. Remove the version directory.
4. Start LitePHP and create a new configuration.

## Moving the environment

The LitePHP directory can be copied or moved because runtime paths are resolved from the location of `LitePHP.bat`.

Before copying an environment that contains MySQL data:

1. Press `Q` and wait for the `MySQL stopped` confirmation.
2. Verify that no `mysqld.exe` process is running.
3. Copy the complete LitePHP directory.

For migration between MySQL versions, prefer a logical export and import using `mysqldump` rather than copying one version's physical data directory into another version.

## Project structure

```text
LitePHP\
├── LitePHP.bat           # Main interactive launcher
├── LitePHP.PhpConfig.ps1 # Visual PHP configuration manager
├── LitePHP.CreateShortcut.ps1 # Creates or refreshes the custom icon shortcut
├── LitePHP.lnk           # Generated locally; excluded from Git
├── LitePHP.ini           # Generated locally; excluded from Git
├── assets\               # Original SVG and multi-resolution Windows ICO
├── PHP\               # Locally installed PHP ZIP distributions
└── MySQL\             # Locally installed MySQL ZIP distributions
```

## Troubleshooting

### The PHP version menu shows startup warnings

LitePHP detects versions with `php.exe -n -v`, which does not load `php.ini`. Warnings shown when the server starts usually indicate invalid entries in the selected `php.ini`.

Check that:

- `extension_dir = "ext"` is relative;
- every enabled extension has a corresponding Windows DLL;
- no Linux `.so` paths are enabled;
- required third-party DLL dependencies are installed.

### Port 80 is already occupied

IIS, another web server, a development tool, or another LitePHP instance may already be listening on port `80`. Stop the conflicting service or create a new configuration using another port such as `8080`.

### MySQL does not start

Check `MySQL\mysql-version\logs\mysql-error.log`. Also verify that port `3306` is free and that the selected ZIP contains `mysqld.exe` and `mysqladmin.exe`.

### A previous MySQL instance is still running

Do not start another server against the same data directory. Stop the existing process cleanly with its matching `mysqladmin.exe`, then restart LitePHP.

### The Batch file reports a missing label

`LitePHP.bat` must use Windows CRLF line endings. The included `.gitattributes` file enforces CRLF when the repository is checked out through Git.

### Paths containing special characters

Spaces are supported. Avoid exclamation marks (`!`) in the LitePHP path or project document root because the launcher uses delayed environment-variable expansion.

## Repository hygiene

The following local items are excluded from source control:

- PHP and MySQL vendor distributions;
- `LitePHP.ini`;
- legacy `LiteWAMP.ini` and the generated `LitePHP.lnk` shortcut;
- MySQL data directories;
- generated certificates and private keys;
- PID and log files;
- debug symbol files.

Before publishing changes, verify that `git status` contains only launcher source, documentation, and intentional project metadata.

## Production use

LitePHP is not a production web server, process supervisor, security boundary, or database deployment system.

For production, use a supported web server and PHP process manager, protect database credentials, enable authentication, apply operating-system security updates, and follow the deployment guidance of the selected PHP and MySQL releases.
