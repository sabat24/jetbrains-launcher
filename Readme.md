# PhpStorm Project Launcher

This repository contains scripts to launch PhpStorm with customized plugin configurations.

The main goal is to solve the problem described
on [YouTrack](https://youtrack.jetbrains.com/issue/IJPL-6073/Allow-to-enable-disable-plugins-per-project-by-creating-own-plugins-lists)

## Files

- `launcher.sh` - Main script that handles PhpStorm launching with plugin configurations
- `open-project.sh` - Helper script to quickly open the current directory in PhpStorm

## Setup Instructions

### for basic Usage

1. Clone this repository or download `launcher.sh` to your local machine

2. Copy `launcher.sh` into your project

3. Modify the tools installation location (if you use Toolbox) in `DEFAULT_IDE_PATH`
    - if you use just one instance of PhpStorm there default path should be fine

4. Open IDE, disable plugins which you do not want to use in current project, go to `~/.config/JetBrains/{IDE VERSION}`
   and copy `disabled_plugins.txt` into your project directory.

5. Make scripts executable:
   ```bash
   chmod +x launcher.sh
   ```

### for advanced Usage

1. Clone this repository or download scripts to your local machine

2. Copy `open-project.sh` into your project:
    - Modify the `LAUNCHER_PATH` variable to point to your `launcher.sh` location:
   ```bash
   LAUNCHER_PATH="/absolute/path/to/launcher.sh"
   ```
   For example: `LAUNCHER_PATH="$HOME/scripts/phpstorm/launcher.sh"`

3. (Optional) You can modify the tools installation location (if you use Toolbox) in `launcher.sh` by changing
   `DEFAULT_IDE_PATH` variable. This step here is optional, because you can pass the path also from `open-project.sh`
   script with `-i` argument.

4. Make both scripts executable:
   ```bash
   chmod +x launcher.sh
   chmod +x open-project.sh
   ```

5. (Optional) Add the scripts directory to your PATH to run them from anywhere:
   ```bash
   # Add this to your ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/script/directory"
   ```

6. Open IDE, disable plugins which you do not want to use in current project, go to `~/.config/JetBrains/{IDE VERSION}`
   and copy `disabled_plugins.txt` into your project directory.

7. (Optional) you can create a plugins profile in directory where you put `launcher.sh` script. Just create a file
   `disabled_plugins/profile_name_disabled_plugins.txt` where `profile_name` is your custom name. For example, it can be
   `symfony_disabled_plugins.txt`

Navigate to any project directory and run:

```bash
./open-project.sh                  # Open current directory with plugins from it
./open-project.sh profile_name     # Open current directory with specific plugins profile
```

This will open PhpStorm with the current directory as the project root. You can optionally specify a profile name to use
a specific plugin configuration. If you do not specify any profile launcher will search for plugins in current path.

## Usage

You can also use `launcher.sh` directly with additional options:

```bash
./launcher.sh [profile_name] [-p project_path] [-i ide_path] [-D dry-run]
```

Parameters:

- `profile_name`: (Optional) Name of the plugin profile to use
- `-p, --project`: Path to the project directory
- `-i, --ide-path`: Custom path to PhpStorm executable
- `-D, --dry-run`: Show commands that would be executed without making any changes

Examples:

```bash
# Show what would happen without making changes
./launcher.sh --dry-run                    # Preview default profile actions
./launcher.sh profile_name --dry-run       # Preview profile-specific actions
```

If you provide a profile_name then `disabled_plugins.txt` file from project directory (if file exists there) will be
ignored.

### Enable plugins per project

If you want to keep some plugins enabled only per project, you can create a file named `enable_plugins.txt` in the
project directory. File should contain a list of plugins which will be removed from `disabled_plugins.txt` at the end of
the process.

It can be useful if you want to keep some plugins enabled only for specific project.

## Paths Configurations

The scripts expect plugin configuration files in the following locations:

- Default configuration (in `launcher.sh` or `open-project.sh` directory): `disabled_plugins.txt`
- Profile-specific configurations (in `launcher.sh` directory): `disabled_plugins/profile_name_disabled_plugins.txt`
- `DEFAULT_IDE_PATH` - path to PhpStorm executable (for more details look
  at [command-line interface﻿](https://www.jetbrains.com/help/idea/working-with-the-ide-features-from-command-line.html))
- `IDE_CONFIGURATION_PATH` - path to configuration (place where IDE stores `disabled_plugins.txt` file) for specified
  version (for more details look
  at [directories used by the IDE﻿](https://www.jetbrains.com/help/phpstorm/directories-used-by-the-ide-to-store-settings-caches-plugins-and-logs.html#config-directory))
