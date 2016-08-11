clear;
clc;

modelParam = ModelParaSet();
modelParam.lambda = 0.01;
modelParam.alpha_norm = 2;
modelParam.win = [-100 100 -100 100];

accessPoints = UT_LatticeBased('hexUni',modelParam);
accessPointsOut = ClassifyGrid(accessPoints,modelParam,5,5);

userModelParam = ModelParaSet();
userModelParam.lambda = 0.1;
userModelParam.alpha_norm = 0;
userModelParam.win = [-50 50 -50 50];

userLocations = UT_LatticeBased('sqUni',userModelParam);
userLocations = [userLocations zeros(length(userLocations),1)];
estimatedLocations = zeros(length(userLocations),3);
for ii = 1:length(userLocations)
    estimatedLocations(ii,1:2) = LocationEstimationOfUser(userLocations(ii,1:2),accessPointsOut(:,1:2),20);
    estimatedLocations(ii,3) = ClassifyUser(estimatedLocations(ii,1:2),accessPointsOut,5);
    userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
end

realUserClass = ClassifyGrid(userLocations,modelParam,5,5);

classError = mean((realUserClass(:,3) == estimatedLocations(:,3)));
userError = mean((realUserClass(:,3) == userLocations(:,3)));

DD = pdist2(userLocations(:,1:2),estimatedLocations(:,1:2));

error = zeros(length(DD),1);

for k = 1:length(DD)
    error(k) = DD(k,k);
end

meanError = nanmean(error);

figure
plot(accessPointsOut(:,1),accessPointsOut(:,2),'.b');

figure
histogram(error);

figure
plot(userLocations(:,1),userLocations(:,2),'.b')
hold on
plot(estimatedLocations(:,1),estimatedLocations(:,2),'.r')
hold off