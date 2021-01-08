#lang scribble/manual
@require[@for-label[reporter
                    racket/base]]

@title{reporter}
@author[(author+email "racket.tw" "racket@racket.tw")]

@defmodule[reporter]

@defstruct*[Report ()]{
  The report structure, all fields were private to avoid any hack based on this. @racket[report] constructs this structure, directly print it would get report to stdout.
}

@defproc[(report [#:target target srcloc?]
                 [#:message msg string?]
                 [#:labels label* (listof Label)]
                 [#:error-code err-code string? #f]
                 [#:hint hint string? #f])
         Report?]{
  constructor of @code{Report}.

  Usage:
  @racketblock[
    (report #:target loc
            #:message "type mismatched"
            #:labels (list (label expect-type-loc (format "expected ~a" expect-type) #:color (color:blue))
                           (label actual-expr-loc (format "actual ~a" actual-type) #:color (color:red)))
            #:error-code "E0001")]

  Recommend using @racket[(raise Report?)] and catch it in any place you want to collect them.
}

@defproc[(label [target srcloc?]
                [msg string?]
                [#:color color color? #f])
          Label?]{
  @racket[target] points out where the hint are going to, @racket[msg] is the hint message, @racket[color] is the color of hint message.
}

@defstruct*[color ()]{
  It could be @code{color:red} or @code{color:blue}
}
@defstruct*[color:red ()]{}
@defstruct*[color:blue ()]{}
