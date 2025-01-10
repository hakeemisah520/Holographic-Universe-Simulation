;; Simulation Management Contract

;; Data Variables
(define-data-var simulation-counter uint u0)
(define-map simulations uint {
    creator: principal,
    name: (string-ascii 100),
    parameters: (list 10 int),
    status: (string-ascii 20),
    created-at: uint,
    updated-at: uint
})

;; Public Functions
(define-public (create-simulation (name (string-ascii 100)) (parameters (list 10 int)))
    (let ((simulation-id (+ (var-get simulation-counter) u1)))
        (map-set simulations simulation-id {
            creator: tx-sender,
            name: name,
            parameters: parameters,
            status: "created",
            created-at: block-height,
            updated-at: block-height
        })
        (var-set simulation-counter simulation-id)
        (ok simulation-id)
    )
)

(define-public (update-simulation (simulation-id uint) (new-parameters (list 10 int)))
    (let ((simulation (unwrap! (map-get? simulations simulation-id) (err u404))))
        (asserts! (is-eq (get creator simulation) tx-sender) (err u403))
        (map-set simulations simulation-id (merge simulation {
            parameters: new-parameters,
            updated-at: block-height
        }))
        (ok true)
    )
)

(define-public (start-simulation (simulation-id uint))
    (let ((simulation (unwrap! (map-get? simulations simulation-id) (err u404))))
        (asserts! (is-eq (get creator simulation) tx-sender) (err u403))
        (map-set simulations simulation-id (merge simulation {
            status: "running",
            updated-at: block-height
        }))
        (ok true)
    )
)

(define-public (stop-simulation (simulation-id uint))
    (let ((simulation (unwrap! (map-get? simulations simulation-id) (err u404))))
        (asserts! (is-eq (get creator simulation) tx-sender) (err u403))
        (map-set simulations simulation-id (merge simulation {
            status: "stopped",
            updated-at: block-height
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-simulation (simulation-id uint))
    (map-get? simulations simulation-id)
)

(define-read-only (get-simulation-count)
    (var-get simulation-counter)
)

