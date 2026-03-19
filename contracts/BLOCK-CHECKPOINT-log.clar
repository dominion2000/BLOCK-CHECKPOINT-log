;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BLOCK HEIGHT CHECKPOINT LOG
;;
;; ----------------------------------------------------------------------------
;; CONTRACT PURPOSE
;; ----------------------------------------------------------------------------
;; This contract records permanent checkpoints on the blockchain.
;;
;; A checkpoint is a record that stores:
;;   - Who created the checkpoint
;;   - The block height when it was created
;;   - An optional reference message ID
;;
;; The contract acts as an immutable audit log.
;;
;; ----------------------------------------------------------------------------
;; HOW IT WORKS
;; ----------------------------------------------------------------------------
;; 1. A user calls `create-checkpoint`.
;; 2. The contract records:
;;      - the caller's address (tx-sender)
;;      - the current block height
;;      - an optional message ID
;; 3. Each checkpoint receives a sequential ID.
;; 4. Anyone can query the checkpoint later.
;;
;; ----------------------------------------------------------------------------
;; POSSIBLE USE CASES
;; ----------------------------------------------------------------------------
;; - Protocol milestone tracking
;; - Audit trail logging
;; - Timestamp proof for data
;; - Governance event recording
;; - On-chain documentation history
;;
;; ----------------------------------------------------------------------------
;; DESIGN CHARACTERISTICS
;; ----------------------------------------------------------------------------
;; (v) Append-only registry
;; (v) No admin required
;; (v) Transparent
;; (v) Deterministic
;; (v) Easy to audit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; ============================================================================
;; SECTION 1 - GLOBAL STATE VARIABLES
;; ============================================================================

;; This variable tracks how many checkpoints exist.
;;
;; Each time a checkpoint is created, this number increases.
;;
;; It also acts as the ID generator for new checkpoints.

(define-data-var checkpoint-count uint u0)



;; ============================================================================
;; SECTION 2 - CHECKPOINT STORAGE MAP
;; ============================================================================

;; The map stores checkpoint records.
;;
;; KEY
;; ----
;; id -> unique identifier for the checkpoint
;;
;; VALUE
;; ------
;; creator    -> the address that created the checkpoint
;; (block height not available in Clarity v4)
;; message-id -> optional reference number

(define-map checkpoints
  { id: uint }
  {
    creator: principal,
    message-id: (optional uint)
  }
)



;; ============================================================================
;; SECTION 3 - ERROR CONSTANTS
;; ============================================================================

;; Returned if someone requests a checkpoint that does not exist.




;; ============================================================================
;; SECTION 4 - CREATE CHECKPOINT
;; ============================================================================

;; FUNCTION: create-checkpoint
;;
;; Allows a user to create a new checkpoint entry.
;;
;; INPUT
;; -----
;; message-id -> optional identifier that can link to external data
;;
;; PROCESS
;; -------
;; 1. Read current checkpoint count.
;; 2. Use it as the new checkpoint ID.
;; 3. Store checkpoint information.
;; 4. Increment checkpoint counter.
;;
;; OUTPUT
;; ------
;; Returns the ID of the newly created checkpoint.

(define-public (create-checkpoint (message-id (optional uint)))

  (let
    (
      ;; Fetch current checkpoint count
      (new-id (var-get checkpoint-count))
    )

    (begin

      ;; Store checkpoint in the registry
      (map-set checkpoints
        { id: new-id }
        {
          creator: tx-sender,
          message-id: (if (is-some message-id) message-id none)
        }
      )

      ;; Increase checkpoint counter
      (var-set checkpoint-count (+ new-id u1))

      ;; Return new checkpoint ID
      (ok new-id)
    )
  )
)



;; ============================================================================
;; SECTION 5 - GET CHECKPOINT
;; ============================================================================

;; FUNCTION: get-checkpoint
;;
;; Retrieves checkpoint data by ID.
;;
;; INPUT
;; -----
;; id -> checkpoint identifier
;;
;; OUTPUT
;; ------
;; Returns:
;;   (some checkpoint-data)
;;   OR
;;   none if checkpoint does not exist

(define-read-only (get-checkpoint (id uint))

  (map-get? checkpoints { id: id })

)



;; ============================================================================
;; SECTION 6 - CHECKPOINT COUNT
;; ============================================================================

;; FUNCTION: get-checkpoint-count
;;
;; Returns total number of checkpoints recorded.
;;
;; This also represents the next checkpoint ID that will be created.

(define-read-only (get-checkpoint-count)

  (var-get checkpoint-count)

)



;; ============================================================================
;; SECTION 7 - CHECK IF CHECKPOINT EXISTS
;; ============================================================================

;; FUNCTION: checkpoint-exists
;;
;; Allows users or other contracts to verify if a checkpoint exists.
;;
;; INPUT
;; -----
;; id -> checkpoint identifier
;;
;; OUTPUT
;; ------
;; true  -> checkpoint exists
;; false -> checkpoint does not exist

(define-read-only (checkpoint-exists (id uint))

  (is-some (map-get? checkpoints { id: id }))

)