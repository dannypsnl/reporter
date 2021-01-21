#lang racket

(require reporter
         c/ast
         c/parse)

(define (src->srcloc s)
  (match-let ([(src start-offset start-line start-col end-offset end-line end-col path) s])
    (srcloc path start-line start-col start-offset (- end-offset start-offset))))

(struct env (cur parent) #:transparent)
(define (make-env)
  (env (make-hash) (cur-env)))
(define cur-env (make-parameter (env (make-hash) #f)))
 
(define (bind src id typ)
  (let* ([cur-binding (env-cur (cur-env))]
         [prev (hash-ref cur-binding id #f)]
         [loc (src->srcloc src)])
    (if prev
        (raise (report
                #:error-code "E0001"
                #:message "redefinition"
                #:target loc
                #:labels (list (label (src->srcloc (type-src prev)) "previous definition" #:color (color:blue))
                               (label loc "current definition" #:color (color:red)))
                #:hint "redeclare same identifier in same scope was invalid"))
        (hash-set! cur-binding id (type:primitive src (type:primitive-name typ))))))
(define (lookup src id)
  (let ([parent? (env-parent (cur-env))]
        [cur-binding (env-cur (cur-env))]
        [loc (src->srcloc src)])
    (hash-ref cur-binding id
              (if parent?
                  (parameterize ([cur-env parent?])
                    (lookup id))
                  (raise (report
                          #:error-code "E0002"
                          #:message "undefined variable"
                          #:target loc
                          #:labels (list (label loc (format "undefined: `~a`" id) #:color (color:red)))
                          #:hint (format "variable `~a` not found" id)))))))

(define (ty-eq!! loc exp-ty actual-ty)
  (let ([e (type:primitive-name exp-ty)]
        [a (type:primitive-name actual-ty)]
        [e-loc (src->srcloc (type-src exp-ty))]
        [a-loc (src->srcloc (type-src actual-ty))])
    (unless (equal? e a)
      (raise (report
              #:error-code "E0000"
              #:message "type mismatched"
              #:target loc
              #:labels (list (label e-loc (format "expect: ~a" e) #:color (color:blue))
                             (label a-loc (format "got: ~a" a) #:color (color:red)))
              #:hint (format "expected: `~a` but got: `~a`" e a))))))

(define (check-decl decl)
  (define loc (src->srcloc (decl-src decl)))
  (match decl
    [(decl:function _ storage-class inline? return-type declarator preamble body)
     (check-stmt body return-type)]
    [(decl:vars _ storage-class type declarators)
     (for ([d declarators])
       (match-let ([(decl:declarator _ id _ init-expr) d])
         (ty-eq!! loc type (infer (init:expr-expr init-expr)))
         (bind (id-src id) (id:var-name id) type)))]
    [else (error 'unimplement-decl)]))
(define (check-stmt stmt f-ret-type)
  (if (decl? stmt)
      (check-decl stmt)
      (let ([loc (src->srcloc (stmt-src stmt))])
        (match stmt
          [(stmt:block _ stmt*)
           (for ([stmt stmt*])
             (collect-report
              (check-stmt stmt f-ret-type)))]
          [(stmt:return _ expr?)
           (ty-eq!! loc f-ret-type (infer expr?))]
          [else (error 'unimplement)]))))
(define (infer expr)
  (define src (expr-src expr))
  (type:primitive
   src
   (cond
     [(expr:float? expr) 'float]
     [(expr:int? expr) 'int]
     [(expr:char? expr) 'char]
     [(expr:ref? expr) (lookup (id-src (expr:ref-id expr)) (id:var-name (expr:ref-id expr)))]
     [else (error 'unimplement-expr "~a" expr)])))

(define test-target-file (build-path 'same "buggy.c"))
;; buggy-program : (Listof decl)
(define buggy-program (parse-program (open-input-file test-target-file)
                                     #:source test-target-file))

(for ([decl buggy-program])
  (check-decl decl))

(for ([report (current-report-collection)])
  (displayln report))
