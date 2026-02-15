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
