function [class] = ClassifyUser(estimatedUserLocation,accessPoints,k)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    DD = pdist2(accessPoints(:,1:2),estimatedUserLocation(:,1:2));
    
    classifier = zeros(1,k);
    
    for ii = 1:k
        [minDist,index] = min(DD);
        classifier(ii) = accessPoints(index,3);
    end
    
    class = mode(classifier);

end

