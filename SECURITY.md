# Security Policy

Language: [中文](./SECURITY-zh.md) [English](./SECURITY.md)

## Supported Versions

| Version | Supported |
| ------- | --------- |
| latest  | OK        |
| other   | No        |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub/Gitee issues.**

Instead, please report them via one of the following methods:

- **Email**: [sauthm_2015@qq.com](mailto:sauthm_2015@qq.com) (preferred)
- **QQ Group**: 183241333 (private message a maintainer)

Please include:

- Description of the vulnerability
- Steps to reproduce
- Affected components (kernel, API, loader, etc.)
- Potential impact

## What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 7 days
- **Fix timeline**: Depends on severity; critical issues prioritized

## Scope

Security issues in the following areas are within scope:

- Kernel privilege escalation
- API boundary violations
- Bootloader / IVT / LDR security
- `.com` / `.vexe` execution sandbox escape
- Memory corruption leading to arbitrary code execution

Out of scope:

- Issues in third-party tools used for building
- Denial of service via physical access
- Social engineering
