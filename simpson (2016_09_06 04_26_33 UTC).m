function I = simpson(fun,a,b,npanel)

n = 2*npanel + 1;    %  total number of nodes
h = (b-a)/(n-1);     %  stepsize
x = a:h:b;           %  divide the interval
f = feval(fun,x);    %  evaluate integrand

I = (h/3)*( f(1) + 4*sum(f(2:2:n-1)) + 2*sum(f(3:2:n-2)) + f(n) );
%           f(a)         f_even              f_odd         f(b)
