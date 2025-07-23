;; --------------------------------------------------
;; Contract: d3-vault
;; Description: Distributes deposited STX evenly among registered users
;; Author: [Your Name]
;; --------------------------------------------------

(define-constant ERR_NOT_ADMIN (err u100))
(define-constant ERR_ALREADY_REGISTERED (err u101))
(define-constant ERR_NO_REWARDS (err u102))
(define-constant ERR_NOT_REGISTERED (err u103))
(define-constant ERR_ALREADY_CLAIMED (err u104))

(define-constant admin tx-sender) ;; locked at deploy

(define-data-var recipients (list 100 principal) (list))
(define-map rewards-map principal uint) ;; user -> reward
(define-data-var reward-pool uint u0)
(define-map claimed-map principal bool) ;; track claims

;; === Register as a recipient ===
(define-public (register-recipient)
  (let ((current (var-get recipients)))
    (if (is-some (index-of current tx-sender))
        ERR_ALREADY_REGISTERED
        (match (as-max-len? (append current tx-sender) u100)
          updated-list (begin
            (var-set recipients updated-list)
            (ok true))
          (err u999))
    )
  )
)

;; === Deposit STX to the reward pool ===
(define-public (deposit-rewards (amount uint))
  (begin
    (asserts! (is-eq tx-sender admin) ERR_NOT_ADMIN)
    (asserts! (> amount u0) ERR_NO_REWARDS)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok true)
  )
)

;; === Distribute rewards evenly to all registered users ===
(define-public (distribute)
  (let ((recipient-list (var-get recipients))
        (count (len (var-get recipients)))
        (total (var-get reward-pool)))
    (if (is-eq count u0)
        (err u999)
        (let ((share (/ total count)))
          (begin
            (map set-user-reward recipient-list)
            (var-set reward-pool u0)
            (ok share)
          )
        )
    )
  )
)

;; Helper function for setting user rewards
(define-private (set-user-reward (user principal))
  (let ((share (/ (var-get reward-pool) (len (var-get recipients)))))
    (begin
      (map-set rewards-map user share)
      (map-set claimed-map user false)
      true
    )
  )
)

;; === Claim your reward ===
(define-public (claim-reward)
  (let ((reward (unwrap! (map-get? rewards-map tx-sender) ERR_NOT_REGISTERED)))
    (begin
      (asserts! (is-eq (default-to true (map-get? claimed-map tx-sender)) false) ERR_ALREADY_CLAIMED)
      (try! (stx-transfer? reward (as-contract tx-sender) tx-sender))
      (map-set claimed-map tx-sender true)
      (ok reward)))
)

;; === Reset recipient list (admin only) ===
(define-public (reset-cycle)
  (begin
    (asserts! (is-eq tx-sender admin) ERR_NOT_ADMIN)
    (var-set recipients (list))
    (ok true)
  )
)

;; === View reward assigned to an address ===
(define-read-only (get-reward (user principal))
  (ok (map-get? rewards-map user))
)

;; === View all recipients ===
(define-read-only (get-recipients)
  (ok (var-get recipients))
)