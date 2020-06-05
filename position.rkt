#lang typed/racket

(provide (struct-out Pos)
         Pos-from-srcloc)

(require/typed syntax/srcloc
  [source-location-line (-> srcloc Integer)]
  [source-location-column (-> srcloc Integer)])

(struct Pos
  ([line : Integer]
   [column : Integer])
  #:transparent)

(define (Pos-from-srcloc [loc : srcloc])
  : Pos
  (let ([line (source-location-line loc)]
        [column (source-location-column loc)])
    (Pos line column)))

(module+ test
  (require typed/rackunit))
(module+ test
  (check-equal? (Pos-from-srcloc (make-srcloc 'here 1 2 1 1))
                (Pos 1 2)))
