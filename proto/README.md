# gRPC Protocol Documentation

This directory contains Protocol Buffer definitions for Chitinwall's client-server communication.

## Files

- `chitinwall.proto` - Main service definition
- `events.proto` - Event schema definitions
- `policies.proto` - Policy configuration schema

## Building

Proto files are automatically compiled during `cargo build` via build.rs in each crate.
