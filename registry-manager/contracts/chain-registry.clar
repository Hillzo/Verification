;; Document Verification Smart Contract
;; Implements document verification with ownership, status tracking, and access control

;; Error codes
(define-constant ERROR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERROR-DUPLICATE-DOCUMENT (err u101))
(define-constant ERROR-DOCUMENT-MISSING (err u102))
(define-constant ERROR-INVALID-DOCUMENT-STATUS (err u103))
(define-constant ERROR-DOCUMENT-ALREADY-VERIFIED (err u104))

;; Constants for verification status
(define-constant STATUS-PENDING "PENDING")
(define-constant STATUS-VERIFIED "VERIFIED")

;; Data maps
(define-map document-records
    { document-hash-id: (buff 32) }
    {
        document-owner: principal,
        document-content-hash: (buff 32),
        submission-timestamp: uint,
        verification-status: (string-ascii 20),
        verification-authority: (optional principal),
        document-metadata: (string-utf8 256),
        document-version: uint,
        verification-complete: bool
    }
)

(define-map document-permissions
    { document-hash-id: (buff 32), authorized-user: principal }
    { document-viewing-permission: bool, document-verification-permission: bool }
)

;; Read-only functions
(define-read-only (get-document-details (document-hash-id (buff 32)))
    (match (map-get? document-records { document-hash-id: document-hash-id })
        found-doc (ok found-doc)
        (err ERROR-DOCUMENT-MISSING))
)

(define-read-only (get-user-permissions (document-hash-id (buff 32)) (authorized-user principal))
    (default-to 
        { document-viewing-permission: false, document-verification-permission: false }
        (map-get? document-permissions { document-hash-id: document-hash-id, authorized-user: authorized-user })
    )
)

(define-read-only (validate-document-hash 
    (document-hash-id (buff 32))
    (provided-hash (buff 32)))
    (match (map-get? document-records { document-hash-id: document-hash-id })
        found-doc (ok (is-eq (get document-content-hash found-doc) provided-hash))
        (err ERROR-DOCUMENT-MISSING))
)

;; Public functions
(define-public (register-new-document 
    (document-hash-id (buff 32))
    (document-content-hash (buff 32))
    (document-metadata (string-utf8 256)))
    (let
        ((document-submitter tx-sender))
        (asserts! (is-none (map-get? document-records { document-hash-id: document-hash-id }))
            ERROR-DUPLICATE-DOCUMENT)
        (ok (map-set document-records
            { document-hash-id: document-hash-id }
            {
                document-owner: document-submitter,
                document-content-hash: document-content-hash,
                submission-timestamp: block-height,
                verification-status: STATUS-PENDING,
                verification-authority: none,
                document-metadata: document-metadata,
                document-version: u1,
                verification-complete: false
            }
        ))
    )
)

(define-public (modify-existing-document
    (document-hash-id (buff 32))
    (updated-content-hash (buff 32))
    (updated-metadata (string-utf8 256)))
    (let
        ((document-submitter tx-sender)
         (existing-document (unwrap! (map-get? document-records { document-hash-id: document-hash-id })
            ERROR-DOCUMENT-MISSING)))
        (asserts! (is-eq (get document-owner existing-document) document-submitter)
            ERROR-UNAUTHORIZED-ACCESS)
        (ok (map-set document-records
            { document-hash-id: document-hash-id }
            (merge existing-document
                {
                    document-content-hash: updated-content-hash,
                    document-metadata: updated-metadata,
                    submission-timestamp: block-height,
                    document-version: (+ (get document-version existing-document) u1),
                    verification-complete: false
                }
            )
        ))
    )
)

(define-public (perform-document-verification
    (document-hash-id (buff 32)))
    (let
        ((verifying-authority tx-sender)
         (existing-document (unwrap! (map-get? document-records { document-hash-id: document-hash-id })
            ERROR-DOCUMENT-MISSING))
         (user-access-rights (get-user-permissions document-hash-id verifying-authority)))
        (asserts! (get document-verification-permission user-access-rights)
            ERROR-UNAUTHORIZED-ACCESS)
        (asserts! (not (get verification-complete existing-document))
            ERROR-DOCUMENT-ALREADY-VERIFIED)
        (ok (map-set document-records
            { document-hash-id: document-hash-id }
            (merge existing-document
                {
                    verification-status: STATUS-VERIFIED,
                    verification-authority: (some verifying-authority),
                    verification-complete: true
                }
            )
        ))
    )
)

(define-public (assign-document-permissions
    (document-hash-id (buff 32))
    (authorized-user principal)
    (grant-viewing-permission bool)
    (grant-verification-permission bool))
    (let
        ((document-owner tx-sender)
         (existing-document (unwrap! (map-get? document-records { document-hash-id: document-hash-id })
            ERROR-DOCUMENT-MISSING)))
        (asserts! (is-eq (get document-owner existing-document) document-owner)
            ERROR-UNAUTHORIZED-ACCESS)
        (ok (map-set document-permissions
            { document-hash-id: document-hash-id, authorized-user: authorized-user }
            { document-viewing-permission: grant-viewing-permission, 
              document-verification-permission: grant-verification-permission }
        ))
    )
)

(define-public (remove-document-permissions
    (document-hash-id (buff 32))
    (authorized-user principal))
    (let
        ((document-owner tx-sender)
         (existing-document (unwrap! (map-get? document-records { document-hash-id: document-hash-id })
            ERROR-DOCUMENT-MISSING)))
        (asserts! (is-eq (get document-owner existing-document) document-owner)
            ERROR-UNAUTHORIZED-ACCESS)
        (ok (map-delete document-permissions
            { document-hash-id: document-hash-id, authorized-user: authorized-user }
        ))
    )
)