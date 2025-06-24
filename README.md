# XcodeFolderSync

## Installation
To build the project and copy the compiled executable to the current directory:
```bash
make build
```

To install the executable to `/usr/local/bin/`:
```bash
make install
```

## Usage
```
USAGE: xcode-folder-sync --project <project> --sync-path <sync-path> --target <target> ...

OPTIONS:
  -p, --project <project> The path of the project’s `.xcodeproj` file.
  -s, --sync-path <sync-path>
                          The path of the folder to sync with the Xcode group,
                          relative to the project file.
  -t, --target <target>   The name of the target to add the files to. Specify
                          multiple times to add the files to more than one
                          target.
  -h, --help              Show help information.
```