;; Renewable Project NFT Contract

(define-non-fungible-token renewable-project uint)

(define-map project-info
  { project-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    capacity: uint,
    project-type: (string-ascii 50),
    commission-date: uint
  }
)

(define-data-var project-id-nonce uint u0)

(define-constant AUTHORIZED_PROJECT_MANAGERS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-read-only (is-authorized-project-manager (address principal))
  (is-some (index-of AUTHORIZED_PROJECT_MANAGERS address))
)

(define-public (register-renewable-project
  (name (string-ascii 100))
  (location (string-ascii 100))
  (capacity uint)
  (project-type (string-ascii 50))
)
  (let
    ((new-project-id (+ (var-get project-id-nonce) u1)))
    (asserts! (is-authorized-project-manager tx-sender) (err u403))
    (try! (nft-mint? renewable-project new-project-id tx-sender))
    (map-set project-info
      { project-id: new-project-id }
      {
        name: name,
        location: location,
        capacity: capacity,
        project-type: project-type,
        commission-date: block-height
      }
    )
    (var-set project-id-nonce new-project-id)
    (ok new-project-id)
  )
)

(define-read-only (get-project-info (project-id uint))
  (map-get? project-info { project-id: project-id })
)

(define-public (transfer-project (project-id uint) (recipient principal))
  (nft-transfer? renewable-project project-id tx-sender recipient)
)

