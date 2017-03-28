function y = nwtsqrt(x, init)

tol = 1e-10;

y = init;
while abs(y*y - x) > tol
    y = (y + x/y)/2;
end

