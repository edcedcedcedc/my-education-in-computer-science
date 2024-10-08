#lang simply-scheme

(define (inc i)(+ i 1))

(define (cube x)
  (* x x x))

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))

(define (square x)
  (* x x))

(define (sum-cubes a b)
  (sum cube a inc b))

;(trace sum)
;(sum-cubes 1 10)


(define (identity x) x)

(define (sum-integers a b)
  (sum identity a inc b))

;(trace sum)
;(sum-integers 1 10)

; 1.31a

(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
         (product term (next a) next b))))

(define (factorial b)
  (product identity 1 inc b))

(define (wallis-product n)
  (*(/ (* 2 n)
     (-(* 2 n) 1))
    (/ (* 2 n)
     (+(* 2 n) 1))))
(define (pi-approximation n)
  (product wallis-product 1.0 inc n))

;(trace product)
;(pi-approximation 1000)



;1.32a
;show that sum and product are special cases of accumulation function
;(accumulate combiner null-value term a next b)
;
;accumulate takes as arguments the same term and
;range specifications as sum and product, together with
;a combiner procedure (of two arguments) that specifies how the current term is to be combined with the
;accumulation of the preceding terms and a null-value
;that specifies what base value to use when the terms
;run out. Write accumulate and show how sum and
;product can both be defined as simple calls to accumulate


;(define (product term a next b)
;  (if (> a b)
;      1
;      (* (term a)
;        (product term (next a) next b))))

(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
                (accumulate combiner null-value term (next a) next b))))


(define (product-accumulate a b)
  (accumulate * 1 identity a inc b))

;(product-accumulate 4 5)


;1.33(a,b)

;prime?
;understanding:
;Number is prime if can only be divided by 1 and itself
;
;Fermat primality test including Fermat's little theorem
;a^(p-1) = 1 (mod p) then p is prime
;when p is composite it is known as Fermat liar
;(pseudoprime) to base a
;when pick an a such that
;a^(p-1) != 1 (mod p) 
;a is known as Fermat witness for compositiness of n
;example
;p = 221
;1 < a < p-1
;a = 38
;a^(p-1)=38^220 = 1 (mod 221)
;either 221 is prime or 38 is Fermat liar
;a^(p-1)=24^220 = 81 != 1 (mod 221)
;so 221 is composite

;1.33a.p1

;(define (fermat-little-therem? a p)
;  (if (not (= (remainder (expt a (- p 1)) p) 1))
;      #f
;      #t))

(define (prime? a p)
  (define (fermat-little-theorem? next a p)
    (cond
      ((= a (- p 1))#t)
      ((not (= (remainder (expt a (- p 1)) p) 1))#f)
      (else
       (fermat-little-theorem? next (next a) p))))
  (fermat-little-theorem? inc a p))

;(trace prime?) 
;(prime? 1 31)
;(prime? 1 30)

;1.33a.p2
(define (filtered-accumulate predicate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (if(predicate a b)
                    (term a)
                     null-value)
                (filtered-accumulate predicate combiner null-value term (next a) next b))))

(define (sum-prime-squares-filtered  a b)
  (filtered-accumulate prime? + 0 square a inc b))
;(sum-prime-squares-filtered 1 10)


;1.33b
;goal/understanding:
;gcd euclid algorithm but replaced the difference with modulus                  
;
;strategy:
;a b, if a > b then a if b > a then b, greater remainder of smaller till it's not zero then greater is gcd 
;
;
;
;
(define (gcd a b)
  (cond
    ((= a 0) b)
    ((= b 0) a)
    ((and(> a b)(=(remainder a b)0)(=(remainder b a)b))b)
    ((> a b)(gcd (remainder a b)b))
    ((< a b)(gcd a(remainder b a)))))

(define (gcd-prime? a b)
  (if (and (< a b)(= (gcd a b) 1))
      #t
      #f))
  
 
(define (product-relative-prime-integers a b)
  (filtered-accumulate gcd-prime? * 1 identity a inc b))

(trace gcd-prime?)
;(product-relative-prime-integers 1 5)


;1.40
;herons method 
(define tolerance 0.00001)
(define dx 0.00001)
(define (average a b)
  (/(+ a b)2.0))

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))

(define (heron-update x S)
  (average x (/ S x)))

;(define (heron-sqrt x)
; (fixed-point (average-damp (lambda (y) (/ x y)))1.0))
;(define (average-damp f)
;  (lambda (x) (average  x (f x))))


(define (heron-sqrt S)
  (fixed-point (lambda (x) (heron-update x S)) 1.0))

;(heron-sqrt 2)

(define (deriv g)
  (lambda (x) (/ (- (g (+ x dx)) (g x)) dx)))

(define (newton-transform g)
  (lambda (x) (- x (/ (g x) ((deriv g) x)))))

(define (newton-method g guess)
  (fixed-point (newton-transform g) guess))

(define (newton-sqrt S)
  (newton-method (lambda (x)(-(square x)S)) 1.0))

;(newton-sqrt 2)


(define (cubic a b c)
  (lambda (x) (+ (expt x 3) (* a (expt x 2)) (* b x) c)))

;((deriv (cubic 2 2 3))1.0)

;((cubic 2 2 3)1.0)

;(newton-method (cubic 2 2 3) 1.0)


;1.41
;1call single with inc as a callback
;1-return the lambda where f is bound to inc
;2-apply the return lambda function to 2


(define (single f)
  (lambda (x)(f x)))

(define (single1 f x)
  ((lambda (x)(f x))x))


;((single inc)2)
;(single1 inc 2)

(define (double f)
  (lambda (x)(f(f x))))

;(trace double)

;(((double double) inc)5)

;(((double(double double))inc)5)

;1.43
;recursively call helper in returns a lambda,
;which applies the outer x i.e 5 to the other lamba
;in which f applies to x and pass it to the next scope

(define (repeated f n)
    (if (< n 1)
       (lambda (x) x)
       (lambda (x)(f ((repeated f (- n 1)) x)))))

;((repeated square 2)5)

(define (repeated1 f n v)
  (if (< n 1)
      v
      (f(repeated1 f (- n 1) v))))

;(repeated1 square 3 5)


;1.46 part 1
;understanding/goal:
;procedure iterative-improve
;domain > functions > arg1 = good-enough, arg2 = improve-guess
;range > functions > return procedure > arg1 = guess
;action: keeps improving the guess the guess until is good enough

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
    guess
    (sqrt-iter (improve guess x) x)))

(define (improve guess x)
  (average guess (/ x guess)))

(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

(define (new-sqrt x)
  (sqrt-iter 1.0 x))

;old iter improv version 
;(define (new-iter-sqrt x)
;  (define (iterative-improve good-enough? improve)
;    (define (iter-improve guess x)
;      (if (good-enough? guess x)
;         guess
;          (iter-improve (improve guess x) x)))
;    iter-improve)
; ((iterative-improve good-enough? improve)1.0 x))

 (define (iterative-improve good-enough? improve)
    (define (iter-improve guess)
      (if (good-enough? guess)
          guess
          (iter-improve(improve guess))))
   iter-improve)

(define (new-iter-sqrt x)
  (define (improve guess)
    (average guess (/ x guess)))
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  ((iterative-improve good-enough? improve)1.0))

;(new-iter-sqrt 3)

;evaluation:
;lambda (guess)(iter-improve guess) == iter-improve 
    
;1.46 part 2

(define tolerance1 0.00001)
;(define (fixed-point f first-guess)
;  (define (close-enough? v1 v2)
;    (< (abs (- v1 v2))
;       tolerance))
;  (define (try guess)
;    (let ((next (f guess)))
;      (if (close-enough? guess next)
;          next
;          (try next))))
;  (try first-guess))
;
;(define (heron-update x S)
;  (average x (/ S x)))
;(define (heron-sqrt S)
;  (fixed-point1 (lambda (x)(heron-update x S)) 1.0))

(define (new-fixed-point f)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2))
       tolerance))
  (define (iterative-improve good-enough? improve)
    (define (iter-improve guess)
    (if (good-enough? guess (improve guess))
        (improve guess)
        (iter-improve(improve guess))))
    iter-improve)
  ((iterative-improve close-enough? f)1.0))

(define (new-heron-sqrt S)
  (new-fixed-point (lambda(x)(improve x S))))

(new-heron-sqrt 3)