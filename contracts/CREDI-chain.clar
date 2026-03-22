;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Digital Badge Registry
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; -------------------------
;; Ownership & Admins
;; -------------------------

(define-data-var contract-owner principal tx-sender)

(define-map admins
  { admin: principal }
  { enabled: bool }
)

;; -------------------------
;; Global Controls
;; -------------------------

(define-data-var paused bool false)

;; -------------------------
;; Badge Registry
;; -------------------------

;; Badge definition (created by admin)
(define-map badges
  { badge-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    creator: principal,
    active: bool
  }
)

;; User badge ownership
(define-map user-badges
  { user: principal, badge-id: uint }
  { awarded: bool }
)

;; Badge counter
(define-data-var badge-count uint u0)

;; -------------------------
;; Constants
;; -------------------------

(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-PAUSED (err u101))
(define-constant ERR-BADGE-NOT-FOUND (err u102))
(define-constant ERR-BADGE-EXISTS (err u103))
(define-constant ERR-ALREADY-AWARDED (err u104))
(define-constant ERR-NOT-AWARDED (err u105))

;; -------------------------
;; Internal Helpers
;; -------------------------

(define-private (is-owner (caller principal))
  (is-eq caller (var-get contract-owner))
)

(define-private (is-admin (caller principal))
  (or
    (is-owner caller)
    (default-to false
      (get enabled (map-get? admins { admin: caller }))
    )
  )
)

(define-private (not-paused)
  (not (var-get paused))
)

(define-private (get-badge (id uint))
  (map-get? badges { badge-id: id })
)

;; -------------------------
;; Read-Only Views
;; -------------------------

(define-read-only (get-badge-info (id uint))
  (get-badge id)
)

(define-read-only (has-badge (user principal) (id uint))
  (default-to false
    (get awarded
      (map-get? user-badges { user: user, badge-id: id })
    )
  )
)

(define-read-only (get-total-badges)
  (var-get badge-count)
)

(define-read-only (is-paused)
  (var-get paused)
)

;; -------------------------
;; Admin Actions
;; -------------------------

;; Create new badge
(define-public (create-badge
  (name (string-ascii 50))
  (description (string-ascii 200))
)
  (begin
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (not-paused) ERR-PAUSED)

    (let ((id (+ (var-get badge-count) u1)))

      (map-set badges
        { badge-id: id }
        {
          name: name,
          description: description,
          creator: tx-sender,
          active: true
        }
      )

      (var-set badge-count id)

      (ok id)
    )
  )
)

;; Disable badge
(define-public (disable-badge (id uint))
  (begin
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)

    (let ((badge (unwrap! (get-badge id) ERR-BADGE-NOT-FOUND)))

      (map-set badges
        { badge-id: id }
        (merge badge { active: false })
      )

      (ok true)
    )
  )
)

;; Award badge to user
(define-public (award-badge
  (user principal)
  (id uint)
)
  (begin
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)
    (asserts! (not-paused) ERR-PAUSED)

    (let ((badge (unwrap! (get-badge id) ERR-BADGE-NOT-FOUND)))

      (asserts! (get active badge) ERR-BADGE-NOT-FOUND)

      (asserts!
        (not (has-badge user id))
        ERR-ALREADY-AWARDED
      )

      (map-set user-badges
        { user: user, badge-id: id }
        { awarded: true }
      )

      (ok true)
    )
  )
)

;; Revoke badge
(define-public (revoke-badge
  (user principal)
  (id uint)
)
  (begin
    (asserts! (is-admin tx-sender) ERR-UNAUTHORIZED)

    (asserts!
      (has-badge user id)
      ERR-NOT-AWARDED
    )

    (map-delete user-badges
      { user: user, badge-id: id }
    )

    (ok true)
  )
)

;; -------------------------
;; Admin Management
;; -------------------------

(define-public (add-admin (admin principal))
  (begin
    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (map-set admins { admin: admin } { enabled: true })
    (ok true)
  )
)

(define-public (remove-admin (admin principal))
  (begin
    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (map-delete admins { admin: admin })
    (ok true)
  )
)

;; -------------------------
;; Emergency Controls
;; -------------------------

(define-public (pause)
  (begin
    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (var-set paused true)
    (ok true)
  )
)

(define-public (unpause)
  (begin
    (asserts! (is-owner tx-sender) ERR-UNAUTHORIZED)
    (var-set paused false)
    (ok true)
)
)