function [mu] = powerit(A,nit)

[m,n] = size(A);
x0 = ones(m,1);

u = x0;
for k=1:nit
  u = A*u;
  mu = norm(u,inf);
  u = u/mu;
end
