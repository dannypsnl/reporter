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
  constructor of @code{Report}
}

@defproc[(label [target srcloc?]
                [msg string?]
                [#:color color color? #f])
          Label?]{
  constructor of label, @racket[target] points out 
}

@defstruct*[color ()]{
  It could be @code{color:red} or @code{color:blue}
}
@defstruct*[color:red ()]{}
@defstruct*[color:blue ()]{}
