#lang scribble/manual
@require[@for-label[reporter
                    racket]]

@title{reporter}
@author[(author+email "Lîm Tsú-thuàn" "dannypsnl@gmail.com")]

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
         #:labels (list (label expect-type-loc (format "expected ~a" expect-type) #:color 'blue)
                        (label actual-expr-loc (format "actual ~a" actual-type) #:color 'red))
         #:error-code "E0001")]

 Recommend using @racket[(raise Report?)] and catch it in any place you want to collect them.
}

@defstruct*[Label ()]{
 The label structure, all fields were private to avoid any hack just like @racket[Report]. @racket[label] constructs this structure.
}
@defproc[(label [target srcloc?]
                [msg string?]
                [#:color color Color? #f])
         Label?]{
 @racket[target] points out where the hint are going to, @racket[msg] is the hint message, @racket[color] is the color of hint message.
}

@defform[(collect-report body ...)]{
 This form works like most normal block like @racket[when], with its wrapping one can collect a raised @racket[Report], find a suitable level put it can help one report more error at once.
}
@defparam[current-report-collection reports (listof Report?)]{
 This parameter stands for collecting report from @racket[collect-report], using it can get all reports current collected, with this one can simply print out all reports or do more operations on it.
}

@defidform[Color]{
 This is a @code{define-type} generated thing, basically are an union of symbols.
}
