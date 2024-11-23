# Document Verification Smart Contract

A robust and secure smart contract built in Clarity for managing, verifying, and tracking digital documents on the Stacks blockchain.

## Overview

This smart contract provides a decentralized solution for document verification with features including document registration, verification, access control, and version management. It enables secure document tracking while maintaining transparency and immutability.

## Features

### Core Functionality
- Document Registration & Management
  - Register new documents with unique identifiers
  - Update existing documents with version tracking
  - Store document metadata and content hashes
  - Track document submission timestamps

### Security & Verification
- Document Verification System
  - Verify document authenticity
  - Track verification status
  - Record verification authorities
  - Prevent duplicate verifications

### Access Control
- Permission Management
  - Granular access control (viewing/verification permissions)
  - Role-based authorization
  - Permission assignment and revocation
  - Owner-specific controls

### Version Control
- Document Versioning
  - Track document versions
  - Maintain modification history
  - Record timestamp for each update
  - Preserve previous versions

### Core Functions

#### Document Management
- `register-new-document`: Register a new document
- `modify-existing-document`: Update an existing document
- `perform-document-verification`: Verify a document
- `assign-document-permissions`: Grant access permissions
- `remove-document-permissions`: Revoke access permissions

#### Read-Only Functions
- `get-document-details`: Retrieve document information
- `get-user-permissions`: Check user access rights
- `validate-document-hash`: Verify document hash

## Prerequisites

- Clarity CLI tools
- Stacks blockchain node
- Understanding of document verification processes
- Basic knowledge of cryptographic hashes

## Usage

### 1. Registering a Document

```clarity
(contract-call? .document-verification register-new-document
    document-hash-id
    document-content-hash
    document-metadata)
```

### 2. Verifying a Document

```clarity
(contract-call? .document-verification perform-document-verification
    document-hash-id)
```

### 3. Managing Permissions

```clarity
(contract-call? .document-verification assign-document-permissions
    document-hash-id
    authorized-user
    grant-viewing-permission
    grant-verification-permission)
```

## Security Considerations

- All document content is stored off-chain; only hashes are stored on-chain
- Access control checks are implemented for all sensitive operations
- Version control prevents unauthorized modifications
- Document ownership is immutably recorded
- Verification status cannot be altered once confirmed

## Error Codes

| Code | Description |
|------|-------------|
| u100 | Unauthorized Access |
| u101 | Duplicate Document |
| u102 | Document Missing |
| u103 | Invalid Document Status |
| u104 | Document Already Verified |

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request