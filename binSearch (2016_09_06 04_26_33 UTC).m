function ia = binSearch(x,xhat)

n = length(x);
if xhat<x(1) | xhat>x(n)
   error(sprintf('Test value of %g is not in range of x',xhat));
end

ia = 1;
ib = n;         %  Initialize lower and upper limits 
while ib-ia>1
  im = fix((ia+ib)/2);   %  Integer value of midpoint
  if x(im) < xhat
    ia = im;             %  Replace lower bracket
  else
    ib = im;             %  Replace upper bracket
  end
end                      %  When while test is true, ia is desired index
