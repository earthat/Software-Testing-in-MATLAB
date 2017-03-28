function out = sphereFnet(A)
for ii=1:length(A)-1
    f(ii)=A(ii)^2-10*cos(2*pi*A(ii));
end
out=10*length(A)+sum(f);

end