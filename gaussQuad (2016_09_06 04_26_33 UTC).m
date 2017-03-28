function I = gaussQuad(fun,a,b,npanel,nnode,varargin)

[z,wt] = GLNodeWt(nnode);          %  compute the nodes and weights

H = (b-a)/npanel;                    %  Size of each panel
H2 = H/2;                            %  Avoids repeated computation of H/2
x = a:H:b;                           %  Divide the interval
I = 0;                               %  Initialize sum
for i=1:npanel
  xstar = 0.5*(x(i)+x(i+1)) + H2*z;  %  Evaluate 'fun' at these points
  f = feval(fun,xstar,varargin{:});
  I = I + sum(wt.*f);                %  Add contribution of this subinterval
end
I = I*H2;                            %  Factor of H/2 for each subinterval


function [x,w] = GLNodeWt(n)

beta   = (1:n-1)./sqrt(4*(1:n-1).^2 - 1);
J      = diag(beta,-1) + diag(beta,1);    % eig(J) needs J in full storage
[V,D]  = eig(J);
[x,ix] = sort(diag(D));  %  nodes are eigenvalues, which are on diagonal of D
w      = 2*V(1,ix)'.^2;  %  V(1,ix)' is column vector of first row of sorted V 
