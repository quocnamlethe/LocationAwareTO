function [accessPointsOut] = ClassifyGrid(accessPoints,modelParam,xSize,ySize)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    accessPointsOut = [ accessPoints zeros(length(accessPoints),1)];

    win = modelParam.win;
    xmin = win(1);
    xmax = win(2);
    ymin = win(3);
    ymax = win(4);
    
    xGridSize = (xmax - xmin)/xSize;
    yGridSize = (ymax - ymin)/ySize;
    
    for k = 1:length(accessPoints)
        x = floor((accessPoints(k,1)-xmin)/xGridSize);
        y = floor((accessPoints(k,2)-ymin)/yGridSize);
        accessPointsOut(k,3) = (y * xSize) + x;
    end
    
end

