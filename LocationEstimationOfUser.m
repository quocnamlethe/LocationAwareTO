function [UserEstimatedLocation] = LocationEstimationOfUser(UserRealLocation,accessPoints,Radius,k)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    DD = pdist2(accessPoints,UserRealLocation);
    consideredPoints = find(DD < Radius);
    UserEstimatedLocation = mean(accessPoints(consideredPoints,:));   
end

