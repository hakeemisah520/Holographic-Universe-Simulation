;; Data Analysis Contract

;; Data Variables
(define-data-var analysis-counter uint u0)
(define-map analyses uint {
    simulation-id: uint,
    analyst: principal,
    results: (string-utf8 1000),
    created-at: uint
})

;; Public Functions
(define-public (submit-analysis (simulation-id uint) (results (string-utf8 1000)))
    (let ((analysis-id (+ (var-get analysis-counter) u1)))
        (map-set analyses analysis-id {
            simulation-id: simulation-id,
            analyst: tx-sender,
            results: results,
            created-at: block-height
        })
        (var-set analysis-counter analysis-id)
        (ok analysis-id)
    )
)

;; Read-only Functions
(define-read-only (get-analysis (analysis-id uint))
    (map-get? analyses analysis-id)
)

(define-read-only (get-analyses-for-simulation (simulation-id uint))
    (fold check-and-add-analysis
        (map-to-list analyses)
        (list)
        simulation-id)
)

(define-private (check-and-add-analysis (entry {id: uint, value: {simulation-id: uint, analyst: principal, results: (string-utf8 1000), created-at: uint}}) (acc (list 100 {id: uint, value: {simulation-id: uint, analyst: principal, results: (string-utf8 1000), created-at: uint}})) (target-sim-id uint))
    (if (is-eq (get simulation-id (get value entry)) target-sim-id)
        (unwrap-panic (as-max-len? (append acc entry) u100))
        acc
    )
)

(define-read-only (get-analysis-count)
    (var-get analysis-counter)
)

