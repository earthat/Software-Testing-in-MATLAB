function shiftedstairs(x, y, varargin)
    
    new_x = zeros(2*length(x)-1, 1);
    new_y = zeros(2*length(y)-1, 1);
    
    new_x(1:2:length(new_x)) = x;
    new_x(2:2:length(new_x)) = x(1:end-1);
    
    new_y(1:2:length(new_y)) = y;
    new_y(2:2:length(new_y)) = y(2:end);
    
    plot(new_x,new_y, varargin{:})
    
end
