clear;
clc;

% Wait bar
hwait = waitbar(0,'Calculating');
tic;

modelParam = ModelParaSet();
modelParam.lambda = 0.1; % Density
modelParam.alpha_norm = 1;
modelParam.win = [-100 100 -100 100];

userModelParam = ModelParaSet();
userModelParam.lambda = 0.1;
userModelParam.alpha_norm = 0;
userModelParam.win = [-50 50 -50 50];

meanError = zeros(1,100);
medianError = zeros(1,100);
estimatedClassAccuracy = zeros(1,100);
realLocationClassAccuracy = zeros(1,100);

for j = 1:100
    modelParam.lambda = 0.001 * j;
    accessPoints = UT_LatticeBased('hexUni',modelParam);
    accessPointsOut = ClassifyGrid(accessPoints,modelParam,10,10); % Number of rectangular grids. Can change later to accommadate different grid shapes

    userLocations = UT_LatticeBased('sqUni',userModelParam);
    userLocations = [userLocations zeros(length(userLocations),1)];
    
    estimatedLocations = zeros(length(userLocations),3);
    for ii = 1:length(userLocations)
        estimatedLocations(ii,1:2) = LocationEstimationOfUser(userLocations(ii,1:2),accessPointsOut(:,1:2),20);
        estimatedLocations(ii,3) = ClassifyUser(estimatedLocations(ii,1:2),accessPointsOut,5);
        userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
    end

    realUserClass = ClassifyGrid(userLocations,modelParam,10,10);

    classificationAccuracy(j) = mean((realUserClass(:,3) == estimatedLocations(:,3)));
    realLocationClassAccuracy(j) = mean((realUserClass(:,3) == userLocations(:,3)));

    DD = pdist2(userLocations(:,1:2),estimatedLocations(:,1:2));

    error = zeros(length(DD),1);

    for k = 1:length(DD)
        error(k) = DD(k,k);
    end

    meanError(j) = nanmean(error);
    medianError(j) = nanmedian(error);
    
    waitbar(j/100,hwait);
end

figure
subplot(2,2,1);
plot(linspace(0.001,0.1,100),meanError,'.b');
title('Mean Locatin Error vs Density of AP');
xlabel('Density of AP (Density per m^2)');
ylabel('Mean Location Error (m)');

subplot(2,2,2);
plot(linspace(0.001,0.1,100),medianError,'.b');
title('Median Locatin Error vs Density of AP');
xlabel('Density of AP (Density per m^2)');
ylabel('Median Location Error (m)');

subplot(2,2,3);
plot(linspace(0.001,0.1,100),classificationAccuracy,'.b');
title('Classification Accuracy for Estimated Location of Users vs Density of AP');
xlabel('Density of AP (Density per m^2)');
ylabel('Classification Accuracy (%)');

subplot(2,2,4);
plot(linspace(0.001,0.1,100),realLocationClassAccuracy,'.b');
title('Classification Accuracy for Real Location of Users vs Density of AP');
xlabel('Density of AP (Density per m^2)');
ylabel('Classification Accuracy (%)');

runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);