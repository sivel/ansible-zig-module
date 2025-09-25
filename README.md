# Ansible Zig Module Demo

This repository demonstrates how to write Ansible modules using the [Zig programming language](https://ziglang.org/). 

## Overview

This demo includes a simple "helloworld" module that:
- Parses JSON arguments from Ansible
- Returns JSON responses in Ansible's expected format
- Handles errors gracefully with proper exit codes
- Provides a reusable architecture for building more complex modules

## Requirements

- Zig 0.15.1 or later
- Ansible (any recent version)

## Building

```bash
zig build
```

This creates an optimized binary at `zig-out/bin/helloworld`.

## Usage

### Basic Example

```bash
$ ansible localhost -m helloworld -M zig-out/bin -a name=sivel
localhost | SUCCESS => {
    "changed": false,
    "msg": "Hello, sivel!"
}
```

### Without a name parameter

```bash
$ ansible localhost -m helloworld -M zig-out/bin
localhost | SUCCESS => {
    "changed": false,
    "msg": "Hello, World!"
}
```

## Architecture

The module is split into two main files:

### `src/main.zig`
Contains module-specific logic:
- `ModuleArgs` struct defining the module's parameters
- Main function that uses the generic parsing infrastructure
- Module business logic

### `src/root.zig`
Contains reusable Ansible module infrastructure:
- Generic `parseArgs()` function for any module type
- JSON response formatting (`Response` struct)
- Error handling (`failJson`, `exitJson`)
- Output functions (`bufferedPrint`)

## License

This project is licensed under the GNU General Public License v3.0 or later. See [LICENSE](LICENSE) for details.

## Contributing

This is a demonstration project. Feel free to fork and adapt for your own Ansible modules!