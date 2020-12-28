#lang scribble/manual
@require[@for-label[reporter
                    racket/base]]

@title{reporter}
@author[(author+email "racket.tw" "racket@racket.tw")]

@defmodule[reporter]

@defstruct*[Report ()]{
  all fields were private to avoid any hack based on this.
}

@defproc[(report [#:target target srcloc?]
                 [#:message msg string?]
                 [#:labels label* (listof Label)]
                 [#:error-code err-code string? #f]
                 [#:hint hint string? #f])
         Report?]{
  constructor of @code{Report}
}

@defproc[(report->text [report Report?]) text?]{
  convert report to text
}

@defproc[(print-text [text text?]) void?]{
  print text
}

@defproc[(label [target srcloc?]
                [msg string?]
                [#:color color color? #f])
          Label?]{
  constructor of label
}
