
%This function updates the velocity and position of agents.
function [X,V]=move(X,a,V,LB,UB)

%movement.
[N,dim]=size(X);
for ii=1:N
    temp(ii,:)=LB+(UB-LB).*rand(1,dim);
end
    
V=rand(N,dim).*V+a; %eq. 11.
X=X+V; %eq. 12.