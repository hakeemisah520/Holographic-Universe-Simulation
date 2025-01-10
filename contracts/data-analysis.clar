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
    (filter (lambda (analysis)
        (is-eq (get simulation-id analysis) simulation-id)
    ) (map-to-list analyses))
)

(define-read-only (get-analysis-count)
    (var-get analysis-counter)
)

