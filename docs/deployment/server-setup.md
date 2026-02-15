# Server Setup Guide

## Prerequisites

- Ubuntu 22.04+ 
- Rust toolchain
- 4GB RAM minimum

## Installation

```bash
cargo build --release --bin chitinwall-server
./scripts/gen-certs.sh server
```

See complete guide for production deployment.
