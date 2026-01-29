# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.3.2   | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue in PURL.jl, please report it responsibly.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities by emailing the maintainers directly or using GitHub's private vulnerability reporting feature:

1. Go to the [Security tab](https://github.com/s-celles/PURL.jl/security) of the repository
2. Click "Report a vulnerability"
3. Fill out the vulnerability report form

### What to Include

Please include the following information in your report:

- **Description**: A clear description of the vulnerability
- **Impact**: What an attacker could achieve by exploiting this vulnerability
- **Reproduction Steps**: Step-by-step instructions to reproduce the issue
- **Affected Versions**: Which versions of PURL.jl are affected
- **Proof of Concept**: Code or commands that demonstrate the vulnerability (if applicable)
- **Suggested Fix**: Your recommendations for fixing the issue (if any)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
- **Initial Assessment**: We will provide an initial assessment within 7 days
- **Regular Updates**: We will keep you informed of our progress
- **Resolution**: We aim to resolve critical vulnerabilities within 30 days
- **Credit**: We will credit you in the security advisory (unless you prefer to remain anonymous)

## Security Considerations for PURL.jl

### Input Validation

PURL.jl performs validation on all input strings:

- **Scheme validation**: Only `pkg:` scheme is accepted
- **Type validation**: Must start with a letter, contain only allowed characters
- **Percent-encoding**: Properly decodes percent-encoded characters
- **Subpath sanitization**: Removes `..` path traversal attempts

### Known Limitations

- PURL.jl is a parsing library and does not make network requests
- PURL.jl does not execute any code from parsed PURL strings
- Type-specific validation is implemented for Julia, PyPI, and npm types only

### Safe Usage Guidelines

1. **Validate before use**: Always validate PURLs from untrusted sources
2. **Use tryparse for untrusted input**: Returns `nothing` instead of throwing on invalid input
3. **Don't interpolate into commands**: Never use PURL components directly in shell commands without proper escaping

```julia
# Safe: Use tryparse for untrusted input
result = tryparse(PackageURL, untrusted_input)
if result === nothing
    # Handle invalid input
end

# Unsafe: Don't do this with untrusted input
# run(`some-command $(purl.name)`)  # Potential command injection
```

## Security Updates

Security updates will be released as patch versions (e.g., 0.1.1, 0.1.2) and announced through:

- GitHub Security Advisories
- Release notes in CHANGELOG.md
- Julia General Registry update

## Dependencies

PURL.jl is a pure Julia package with no external dependencies, minimizing the attack surface from third-party code.

## Contact

For security-related questions that are not vulnerabilities, please open a regular GitHub issue.
