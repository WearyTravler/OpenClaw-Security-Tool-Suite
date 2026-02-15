#!/bin/bash

# Chitinwall Project Structure Setup Script
# This script creates the complete folder structure for the Chitinwall security tool

set -e  # Exit on error

echo "🦞 Setting up Chitinwall project structure..."
echo ""

# Get the repo root (assumes script is run from repo root or can find .git)
REPO_ROOT="${1:-.}"
cd "$REPO_ROOT"

echo "Creating directory structure in: $(pwd)"
echo ""

# Create all directories
mkdir -p .github/workflows
mkdir -p .github/ISSUE_TEMPLATE

mkdir -p proto

mkdir -p crates/agent/src/gateway
mkdir -p crates/agent/src/monitor
mkdir -p crates/agent/src/scanner
mkdir -p crates/agent/src/enforcement
mkdir -p crates/agent/src/grpc
mkdir -p crates/agent/src/cli
mkdir -p crates/agent/src/telemetry
mkdir -p crates/agent/tests/integration
mkdir -p crates/agent/tests/fixtures/test_skills

mkdir -p crates/server/src/grpc
mkdir -p crates/server/src/analysis
mkdir -p crates/server/src/policy
mkdir -p crates/server/src/dashboard
mkdir -p crates/server/src/storage
mkdir -p crates/server/src/remediation
mkdir -p crates/server/tests/integration
mkdir -p crates/server/tests/fixtures

mkdir -p crates/shared/src/types
mkdir -p crates/shared/src/parser
mkdir -p crates/shared/src/patterns
mkdir -p crates/shared/src/ioc
mkdir -p crates/shared/src/crypto
mkdir -p crates/shared/src/utils
mkdir -p crates/shared/tests/unit

mkdir -p dashboard-ui/public/assets
mkdir -p dashboard-ui/src/components/Dashboard
mkdir -p dashboard-ui/src/components/Alerts
mkdir -p dashboard-ui/src/components/Network
mkdir -p dashboard-ui/src/components/Skills
mkdir -p dashboard-ui/src/components/common
mkdir -p dashboard-ui/src/api
mkdir -p dashboard-ui/src/hooks
mkdir -p dashboard-ui/src/styles
mkdir -p dashboard-ui/src/types

mkdir -p data
mkdir -p policies
mkdir -p scripts

mkdir -p tests/samples/benign/weather
mkdir -p tests/samples/benign/calculator
mkdir -p tests/samples/benign/timer
mkdir -p tests/samples/malicious/clawhavoc-prereq
mkdir -p tests/samples/malicious/base64-payload
mkdir -p tests/samples/malicious/path-hijack
mkdir -p tests/samples/malicious/env-poison
mkdir -p tests/samples/malicious/prompt-injection
mkdir -p tests/samples/malicious/soul-poison
mkdir -p tests/samples/malicious/memory-poison
mkdir -p tests/samples/malicious/install-hook
mkdir -p tests/samples/malicious/typosquat
mkdir -p tests/samples/malicious/reverse-shell
mkdir -p tests/samples/malicious/credential-exfil
mkdir -p tests/samples/malicious/supply-chain
mkdir -p tests/integration/e2e
mkdir -p tests/integration/fixtures

mkdir -p docs/architecture
mkdir -p docs/deployment
mkdir -p docs/detection
mkdir -p docs/policy
mkdir -p docs/remediation
mkdir -p docs/api
mkdir -p docs/contributing

mkdir -p examples/policies
mkdir -p examples/custom-patterns
mkdir -p examples/playbooks

mkdir -p certs

echo "✅ Directory structure created"
echo ""
echo "Creating placeholder files..."
echo ""

# GitHub workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - run: cargo test --all
EOF

cat > .github/workflows/security-audit.yml << 'EOF'
name: Security Audit

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  push:
    branches: [ main ]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/audit-check@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
EOF

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior.

**Expected behavior**
What you expected to happen.

**Environment:**
 - OS: [e.g. Ubuntu 22.04, Windows 11]
 - Chitinwall version: [e.g. 0.1.0]
 - OpenClaw version: [e.g. 1.2.3]
EOF

cat > .github/ISSUE_TEMPLATE/detection_pattern.md << 'EOF'
---
name: Detection Pattern
about: Submit a new detection pattern
title: '[PATTERN] '
labels: enhancement, detection
assignees: ''
---

**Attack Vector**
Describe the attack this pattern detects.

**Pattern**
```toml
# Paste your pattern TOML here
```

**Test Cases**
- [ ] Malicious sample that triggers pattern
- [ ] Benign sample that should NOT trigger
EOF

# Proto files
cat > proto/chitinwall.proto << 'EOF'
syntax = "proto3";

package chitinwall;

service ChitinwallService {
  rpc ReportEvent(Event) returns (EventResponse);
  rpc QueryPolicy(PolicyRequest) returns (PolicyResponse);
  rpc ReportSkill(SkillReport) returns (SkillResponse);
}

message Event {
  string endpoint_id = 1;
  string event_type = 2;
  int64 timestamp = 3;
  bytes payload = 4;
}

message EventResponse {
  bool accepted = 1;
  string message = 2;
}

message PolicyRequest {
  string endpoint_id = 1;
  string skill_name = 2;
}

message PolicyResponse {
  bool allowed = 1;
  repeated string blocked_actions = 2;
}

message SkillReport {
  string endpoint_id = 1;
  string skill_name = 2;
  string skill_hash = 3;
  bytes skill_content = 4;
}

message SkillResponse {
  bool safe = 1;
  repeated string threats = 2;
  string action = 3;  // "allow", "quarantine", "block"
}
EOF

cat > proto/README.md << 'EOF'
# gRPC Protocol Documentation

This directory contains Protocol Buffer definitions for Chitinwall's client-server communication.

## Files

- `chitinwall.proto` - Main service definition
- `events.proto` - Event schema definitions
- `policies.proto` - Policy configuration schema

## Building

Proto files are automatically compiled during `cargo build` via build.rs in each crate.
EOF

# Workspace Cargo.toml
cat > Cargo.toml << 'EOF'
[workspace]
members = [
    "crates/agent",
    "crates/server",
    "crates/shared",
]
resolver = "2"

[workspace.package]
version = "0.1.0"
edition = "2021"
license = "MIT"
repository = "https://github.com/WearyTravler/Chitinwall"

[workspace.dependencies]
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
toml = "0.8"
anyhow = "1.0"
thiserror = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"
tonic = "0.11"
prost = "0.12"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
strip = true
EOF

# Agent Cargo.toml
cat > crates/agent/Cargo.toml << 'EOF'
[package]
name = "chitinwall-agent"
version.workspace = true
edition.workspace = true
license.workspace = true

[[bin]]
name = "chitinwall-agent"
path = "src/main.rs"

[dependencies]
chitinwall-shared = { path = "../shared" }
tokio.workspace = true
serde.workspace = true
serde_json.workspace = true
toml.workspace = true
anyhow.workspace = true
thiserror.workspace = true
tracing.workspace = true
tracing-subscriber.workspace = true
tonic.workspace = true
prost.workspace = true
notify = "6.1"  # Filesystem watching
tokio-tungstenite = "0.21"  # WebSocket
clap = { version = "4.4", features = ["derive"] }
sha2 = "0.10"

[dev-dependencies]
tempfile = "3.8"
EOF

# Server Cargo.toml
cat > crates/server/Cargo.toml << 'EOF'
[package]
name = "chitinwall-server"
version.workspace = true
edition.workspace = true
license.workspace = true

[[bin]]
name = "chitinwall-server"
path = "src/main.rs"

[dependencies]
chitinwall-shared = { path = "../shared" }
tokio.workspace = true
serde.workspace = true
serde_json.workspace = true
toml.workspace = true
anyhow.workspace = true
thiserror.workspace = true
tracing.workspace = true
tracing-subscriber.workspace = true
tonic.workspace = true
prost.workspace = true
axum = "0.7"  # Dashboard HTTP server
tower-http = "0.5"
sqlx = { version = "0.7", features = ["sqlite", "runtime-tokio"] }
regex = "1.10"
sha2 = "0.10"

[dev-dependencies]
tempfile = "3.8"
EOF

# Shared Cargo.toml
cat > crates/shared/Cargo.toml << 'EOF'
[package]
name = "chitinwall-shared"
version.workspace = true
edition.workspace = true
license.workspace = true

[dependencies]
serde.workspace = true
serde_json.workspace = true
toml.workspace = true
anyhow.workspace = true
thiserror.workspace = true
regex = "1.10"
sha2 = "0.10"
prost.workspace = true

[dev-dependencies]
tempfile = "3.8"
EOF

# Agent main.rs
cat > crates/agent/src/main.rs << 'EOF'
use clap::{Parser, Subcommand};
use tracing::info;

#[derive(Parser)]
#[command(name = "chitinwall-agent")]
#[command(about = "Chitinwall endpoint security agent")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Start the agent daemon
    Start,
    /// Scan a skill locally
    Scan { path: String },
    /// Audit all installed skills
    Audit,
    /// Check SOUL.md/MEMORY.md integrity
    Integrity,
    /// Show agent status
    Status,
    /// Emergency lockdown
    Lockdown,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();
    
    let cli = Cli::parse();
    
    match cli.command {
        Commands::Start => {
            info!("Starting Chitinwall agent...");
            // TODO: Implement agent daemon
        }
        Commands::Scan { path } => {
            info!("Scanning skill at: {}", path);
            // TODO: Implement local scan
        }
        Commands::Audit => {
            info!("Auditing all skills...");
            // TODO: Implement audit
        }
        Commands::Integrity => {
            info!("Checking integrity...");
            // TODO: Implement integrity check
        }
        Commands::Status => {
            info!("Agent status:");
            // TODO: Implement status
        }
        Commands::Lockdown => {
            info!("🚨 Emergency lockdown activated!");
            // TODO: Implement lockdown
        }
    }
    
    Ok(())
}
EOF

# Server main.rs
cat > crates/server/src/main.rs << 'EOF'
use tracing::info;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt::init();
    
    info!("Starting Chitinwall server...");
    info!("gRPC listening on :50051");
    info!("Dashboard available at https://localhost:8443");
    
    // TODO: Start gRPC server
    // TODO: Start dashboard server
    
    tokio::signal::ctrl_c().await?;
    info!("Shutting down...");
    
    Ok(())
}
EOF

# Shared lib.rs
cat > crates/shared/src/lib.rs << 'EOF'
//! Shared library for Chitinwall agent and server
//! 
//! Contains common types, parsers, pattern matching, and utilities.

pub mod types;
pub mod parser;
pub mod patterns;
pub mod ioc;
pub mod crypto;
pub mod utils;
EOF

# Create module files
touch crates/agent/src/lib.rs
touch crates/agent/src/config.rs
touch crates/agent/src/gateway/mod.rs
touch crates/agent/src/monitor/mod.rs
touch crates/agent/src/scanner/mod.rs
touch crates/agent/src/enforcement/mod.rs
touch crates/agent/src/grpc/mod.rs
touch crates/agent/src/cli/mod.rs
touch crates/agent/src/telemetry/mod.rs

touch crates/server/src/lib.rs
touch crates/server/src/config.rs
touch crates/server/src/grpc/mod.rs
touch crates/server/src/analysis/mod.rs
touch crates/server/src/policy/mod.rs
touch crates/server/src/dashboard/mod.rs
touch crates/server/src/storage/mod.rs
touch crates/server/src/remediation/mod.rs

touch crates/shared/src/types/mod.rs
touch crates/shared/src/parser/mod.rs
touch crates/shared/src/patterns/mod.rs
touch crates/shared/src/ioc/mod.rs
touch crates/shared/src/crypto/mod.rs
touch crates/shared/src/utils/mod.rs

# Data files
cat > data/iocs.toml << 'EOF'
# Known-bad Indicators of Compromise
# Update this file with new threat intelligence

[publishers]
# Blocked ClawHub publisher accounts
blocked = [
    "malicious-user-123",
    "clawhavoc-campaign",
]

[c2_servers]
# Known C2 infrastructure
domains = [
    "evil-c2.example.com",
]
ips = [
    "198.51.100.1",
]

[skill_hashes]
# SHA-256 hashes of known malicious skills
blocked = [
    "abc123...",
]
EOF

cat > data/patterns.toml << 'EOF'
# Detection Pattern Library

[[patterns]]
name = "base64-payload"
description = "Base64-encoded payload followed by shell execution"
regex = 'echo\s+[A-Za-z0-9+/=]{50,}\s*\|\s*base64\s+-d\s*\|\s*(?:bash|sh)'
severity = "critical"
category = "command-injection"

[[patterns]]
name = "reverse-shell"
description = "Reverse shell connection syntax"
regex = 'bash\s+-i\s*>&\s*/dev/tcp/[\d.]+/\d+'
severity = "critical"
category = "command-injection"

[[patterns]]
name = "credential-exfil"
description = "Credential file exfiltration"
regex = 'curl.*-d.*(?:\.env|\.aws|\.ssh|id_rsa)'
severity = "critical"
category = "exfiltration"

[[patterns]]
name = "prompt-injection-bypass"
description = "Prompt injection safety bypass"
regex = '(?i)(?:ignore|disregard|forget).*(?:previous|above|prior).*(?:instructions|rules|constraints)'
severity = "high"
category = "prompt-injection"
EOF

cat > data/sensitive_paths.toml << 'EOF'
# Protected file paths - agent blocks reads to these

[[paths]]
pattern = "**/.env"
description = "Environment files with secrets"
action = "block"

[[paths]]
pattern = "**/.aws/credentials"
description = "AWS credentials"
action = "block"

[[paths]]
pattern = "**/.ssh/id_*"
description = "SSH private keys"
action = "block"

[[paths]]
pattern = "**/openclaw/.env"
description = "OpenClaw configuration"
action = "block"
EOF

# Policy files
cat > policies/default.toml << 'EOF'
# Default Chitinwall Security Policy

[general]
policy_name = "default"
version = "1.0"

[skill_sources]
# Allow bundled skills and verified publishers
allow_bundled = true
allow_clawhub_verified = true
allow_github_repos = [
    "openclaw/skills-official",
]

[enforcement]
# Block unknown skills by default
quarantine_unknown = true
# Require manual approval for non-bundled skills
manual_approval_required = true

[monitoring]
# Enable all monitoring features
gateway_tap = true
filesystem_watch = true
process_monitor = true
network_monitor = true
EOF

cat > policies/strict.toml << 'EOF'
# Strict Lockdown Policy

[general]
policy_name = "strict"
version = "1.0"

[skill_sources]
allow_bundled = true
allow_clawhub_verified = false
allow_github_repos = []

[enforcement]
quarantine_unknown = true
manual_approval_required = true
block_non_bundled = true  # Completely block non-bundled skills

[monitoring]
gateway_tap = true
filesystem_watch = true
process_monitor = true
network_monitor = true
EOF

# Scripts
cat > scripts/gen-certs.sh << 'EOF'
#!/bin/bash
# Generate mTLS certificates for Chitinwall

set -e

CERT_DIR="certs"
mkdir -p "$CERT_DIR"

echo "Generating CA certificate..."
openssl req -x509 -newkey rsa:4096 -days 365 -nodes \
    -keyout "$CERT_DIR/ca-key.pem" \
    -out "$CERT_DIR/ca.pem" \
    -subj "/CN=Chitinwall CA"

echo "Generating server certificate..."
openssl req -newkey rsa:4096 -nodes \
    -keyout "$CERT_DIR/server-key.pem" \
    -out "$CERT_DIR/server-req.pem" \
    -subj "/CN=chitinwall-server"

openssl x509 -req -in "$CERT_DIR/server-req.pem" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca-key.pem" \
    -CAcreateserial -days 365 \
    -out "$CERT_DIR/server.pem"

echo "✅ Certificates generated in $CERT_DIR/"
EOF

chmod +x scripts/gen-certs.sh

cat > scripts/setup-lab.sh << 'EOF'
#!/bin/bash
# Set up a Chitinwall test lab environment

echo "🧪 Setting up Chitinwall test lab..."
echo "This script helps provision a local test environment"
echo ""
echo "TODO: Implement lab setup"
EOF

chmod +x scripts/setup-lab.sh

# Dashboard package.json
cat > dashboard-ui/package.json << 'EOF'
{
  "name": "chitinwall-dashboard",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.3.3",
    "vite": "^5.0.8"
  }
}
EOF

cat > dashboard-ui/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

cat > dashboard-ui/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': 'http://localhost:8443'
    }
  }
})
EOF

cat > dashboard-ui/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Chitinwall Dashboard</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat > dashboard-ui/src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './styles/main.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > dashboard-ui/src/App.tsx << 'EOF'
import React from 'react'

function App() {
  return (
    <div className="app">
      <h1>🦞 Chitinwall Dashboard</h1>
      <p>Security monitoring for OpenClaw agents</p>
    </div>
  )
}

export default App
EOF

cat > dashboard-ui/src/styles/main.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  background: #1a1a1a;
  color: #fff;
}

.app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
EOF

# Documentation
cat > docs/architecture/overview.md << 'EOF'
# Chitinwall Architecture Overview

Chitinwall uses a two-component architecture:

1. **Agent** (WSL2) - Lightweight endpoint monitoring
2. **Server** (Linux) - Heavy analysis and coordination

See individual component docs for details.
EOF

cat > docs/deployment/server-setup.md << 'EOF'
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
EOF

# README files
cat > crates/agent/README.md << 'EOF'
# Chitinwall Agent

WSL2-based endpoint security agent for OpenClaw monitoring.

## Features

- Gateway WebSocket monitoring
- Filesystem watching
- Local skill scanning
- Real-time enforcement

See main project README for usage.
EOF

cat > crates/server/README.md << 'EOF'
# Chitinwall Server

Central analysis and coordination server.

## Features

- Static/binary/semantic analysis
- Policy enforcement
- Cross-endpoint correlation
- Web dashboard

See main project README for usage.
EOF

cat > crates/shared/README.md << 'EOF'
# Chitinwall Shared Library

Common code shared between agent and server.

## Modules

- `types` - Data structures
- `parser` - Skill parsers
- `patterns` - Detection patterns
- `ioc` - Indicator matching
- `crypto` - Hashing/TLS
- `utils` - Utilities
EOF

cat > tests/README.md << 'EOF'
# Chitinwall Test Suite

## Structure

- `samples/benign/` - Clean test skills
- `samples/malicious/` - Defanged malicious skills
- `integration/` - Integration tests

## Running Tests

```bash
cargo test --all
```
EOF

cat > dashboard-ui/README.md << 'EOF'
# Chitinwall Dashboard

React-based web dashboard for real-time monitoring.

## Development

```bash
npm install
npm run dev
```

## Building

```bash
npm run build
```
EOF

# Example files
cat > examples/policies/finance-org.toml << 'EOF'
# Example: Finance organization policy

[general]
policy_name = "finance-org"
version = "1.0"

[skill_sources]
allow_bundled = true
allow_clawhub_verified = true
# Only allow from verified corp GitHub
allow_github_repos = [
    "myfinancecorp/openclaw-skills",
]

[enforcement]
quarantine_unknown = true
manual_approval_required = true
EOF

cat > examples/playbooks/credential-rotation.md << 'EOF'
# Credential Rotation Playbook

## When to Use

Execute this playbook when credential exfiltration is detected.

## Steps

1. **Immediate Actions**
   - Revoke compromised API keys
   - Rotate OpenClaw gateway token
   - Reset Anthropic API key

2. **Investigation**
   - Review agent logs for exfiltration timing
   - Check network logs for upload destinations
   - Identify compromised skill

3. **Remediation**
   - Quarantine malicious skill across all endpoints
   - Update detection patterns
   - Notify affected users

4. **Prevention**
   - Update sensitive_paths.toml
   - Review skill approval process
EOF

# Security policy
cat > SECURITY.md << 'EOF'
# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in Chitinwall, please report it privately:

- **Email:** security@[your-domain]
- **Response time:** Within 48 hours

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Security Best Practices

1. Keep IoC database updated
2. Use strict policies in production
3. Enable mTLS for agent-server communication
4. Review quarantined skills before releasing
EOF

# Contributing guide
cat > CONTRIBUTING.md << 'EOF'
# Contributing to Chitinwall

Thank you for your interest in contributing!

## Areas Where Help is Needed

- Detection patterns for new attack vectors
- IoC feeds (C2 infrastructure, malicious publishers)
- Test skills (defanged malicious samples)
- Dashboard UI improvements
- Documentation

## Development Setup

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Run tests: `cargo test --all`
6. Submit a pull request

## Detection Pattern Guidelines

When submitting new detection patterns:

1. Include regex pattern
2. Provide test cases (malicious + benign)
3. Document the attack vector
4. Specify severity level

See `data/patterns.toml` for examples.

## Code Style

- Run `cargo fmt` before committing
- Follow Rust API guidelines
- Add tests for new features
EOF

# Changelog
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Initial project structure
- Agent framework with CLI
- Server framework with gRPC
- Detection pattern library
- Dashboard UI skeleton
- Test skill corpus

### In Progress
- Gateway WebSocket tap
- Static analysis engine
- Policy enforcement
- Cross-endpoint correlation

### Planned
- LLM semantic analysis
- Behavioral profiling
- Remediation playbooks
- Windows telemetry bridge
EOF

cat > certs/README.md << 'EOF'
# TLS Certificates

This directory contains mTLS certificates generated by `scripts/gen-certs.sh`.

## Files

- `ca.pem` - Certificate Authority
- `ca-key.pem` - CA private key
- `server.pem` - Server certificate
- `server-key.pem` - Server private key

## Security

**Do not commit these files to version control.**

Generate new certificates for each deployment environment.
EOF

echo "✅ Placeholder files created"
echo ""
echo "🦞 Chitinwall structure setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review the generated structure"
echo "  2. Run: cargo build"
echo "  3. Generate certificates: ./scripts/gen-certs.sh"
echo "  4. Start implementing core modules"
echo ""
echo "Key directories:"
echo "  - crates/agent/     → Endpoint agent"
echo "  - crates/server/    → Analysis server"
echo "  - crates/shared/    → Common library"
echo "  - dashboard-ui/     → Web dashboard"
echo "  - data/             → Detection patterns & IoCs"
echo "  - tests/samples/    → Test skill corpus"
echo ""
