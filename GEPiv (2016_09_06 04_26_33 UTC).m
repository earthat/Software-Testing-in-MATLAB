function x = GEPiv(A,b)

ptol = 50*eps;
[m,n] = size(A);

nb = n+1;
Ab = [A b];    %  Augmented system

% --- Elimination
for i = 1:n-1                        %  loop over pivot row
  [pivot,p] = max(abs(Ab(i:n,i)));   %  value and index of largest available pivot
  ip = p + i - 1;                    %  p is index in subvector i:n
  if ip~=i                           %  ip is true row index of desired pivot
    Ab([i ip],:) = Ab([ip i],:);     %  perform the swap
  end
  pivot = Ab(i,i);
  if abs(pivot)<ptol,
    error('zero pivot encountered after row exchange');
  end
  for k = i+1:n            %  k = index of next row to be eliminated
    Ab(k,i:nb) = Ab(k,i:nb) - (Ab(k,i)/pivot)*Ab(i,i:nb); 
  end
end

% --- Back substitution
x = zeros(n,1);           %  preallocate memory for and initialize x
x(n) = Ab(n,nb)/Ab(n,n);
for i=n-1:-1:1
  x(i) = (Ab(i,nb) - Ab(i,i+1:n)*x(i+1:n))/Ab(i,i);
end
