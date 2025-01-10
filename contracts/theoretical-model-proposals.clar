;; Theoretical Model Proposals Contract

;; Data Variables
(define-data-var proposal-counter uint u0)
(define-map proposals uint {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    status: (string-ascii 20),
    votes: uint,
    created-at: uint
})

;; Public Functions
(define-public (submit-proposal (title (string-ascii 100)) (description (string-utf8 1000)))
    (let ((proposal-id (+ (var-get proposal-counter) u1)))
        (map-set proposals proposal-id {
            proposer: tx-sender,
            title: title,
            description: description,
            status: "submitted",
            votes: u0,
            created-at: block-height
        })
        (var-set proposal-counter proposal-id)
        (ok proposal-id)
    )
)

(define-public (vote-on-proposal (proposal-id uint))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) (err u404))))
        (map-set proposals proposal-id (merge proposal {
            votes: (+ (get votes proposal) u1)
        }))
        (ok true)
    )
)

(define-public (update-proposal-status (proposal-id uint) (new-status (string-ascii 20)))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) (err u404))))
        (asserts! (is-eq tx-sender (get proposer proposal)) (err u403))
        (map-set proposals proposal-id (merge proposal {
            status: new-status
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-proposal-count)
    (var-get proposal-counter)
)

