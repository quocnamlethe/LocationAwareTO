clear;
clc;

% Wait bar
hwait = waitbar(0,'Calculating');
tic;

modelParam = ModelParaSet();
modelParam.lambda = 0.01; % Density
modelParam.alpha_norm = 1;
modelParam.win = [-100 100 -100 100];

userModelParam = ModelParaSet();
userModelParam.lambda = 0.1;
userModelParam.alpha_norm = 0;
userModelParam.win = [-50 50 -50 50];

meanError = zeros(2,100);
medianError = zeros(2,100);
estimatedClassAccuracy = zeros(2,100);
realLocationClassAccuracy = zeros(2,100);

for j = 1:100
    accessPoints = UT_LatticeBased('hexUni',modelParam);
    accessPointsOut = ClassifyGrid(accessPoints,modelParam,5,5); % Number of rectangular grids. Can change later to accommadate different grid shapes

    userLocations = UT_LatticeBased('sqUni',userModelParam);
    userLocations = [userLocations zeros(length(userLocations),1)];
    
    estimatedLocations = zeros(length(userLocations),3);
    for ii = 1:length(userLocations)
        estimatedLocations(ii,1:2) = LocationEstimationOfUser(userLocations(ii,1:2),accessPointsOut(:,1:2),j/2);
        estimatedLocations(ii,3) = ClassifyUser(estimatedLocations(ii,1:2),accessPointsOut,5);
        userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
    end

    realUserClass = ClassifyGrid(userLocations,modelParam,5,5);

    classificationAccuracy(1,j) = j/2;
    classificationAccuracy(2,j) = mean((realUserClass(:,3) == estimatedLocations(:,3)));
    realLocationClassAccuracy(1,j) = j/2;
    realLocationClassAccuracy(2,j) = mean((realUserClass(:,3) == userLocations(:,3)));

    DD = pdist2(userLocations(:,1:2),estimatedLocations(:,1:2));

    error = zeros(length(DD),1);

    for k = 1:length(DD)
        error(k) = DD(k,k);
    end

    meanError(1,j) = j/2;
    meanError(2,j) = nanmean(error);
    medianError(1,j) = j/2;
    medianError(2,j) = nanmedian(error);
    
    waitbar(j/100,hwait);
end

figure
subplot(1,2,1);
plot(meanError(1,:),meanError(2,:),'.b');
title('Mean Locatin Error vs Radius Size');
xlabel('Radius Size (m)');
ylabel('Mean Location Error (m)');

subplot(1,2,2);
plot(medianError(1,:),medianError(2,:),'.b');
title('Median Locatin Error vs Radius Size');
xlabel('Radius Size (m)');
ylabel('Median Location Error (m)');

figure
subplot(1,2,1);
plot(classificationAccuracy(1,:),classificationAccuracy(2,:),'.b');
title('Classification Accuracy for Estimated Location of Users vs Radius Size');
xlabel('Radius Size (m)');
ylabel('Classification Accuracy (%)');

subplot(1,2,2);
plot(realLocationClassAccuracy(1,:),realLocationClassAccuracy(2,:),'.b');
title('Classification Accuracy for Real Location of Users vs Radius Size');
xlabel('Radius Size (m)');
ylabel('Classification Accuracy (%)');
axis([0 50 0 1])

runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);