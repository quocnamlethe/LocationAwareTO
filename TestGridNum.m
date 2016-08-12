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

windowSize = 10000;

gridNumbers = logspace(log10(1.5),log10(10),10);

gridSizes = [];
for j = 1:10
    for k = 1:10
        gridSizes = [gridSizes windowSize/(gridNumbers(j)*gridNumbers(k))];
    end
end

for j = 1:10
    for k = 1:10
        accessPoints = UT_LatticeBased('hexUni',modelParam);
        accessPointsOut = ClassifyGrid(accessPoints,modelParam,gridNumbers(j),gridNumbers(k)); % Number of rectangular grids. Can change later to accommadate different grid shapes

        userLocations = UT_LatticeBased('sqUni',userModelParam);
        userLocations = [userLocations zeros(length(userLocations),1)];

        estimatedLocations = zeros(length(userLocations),3);
        for ii = 1:length(userLocations)
            estimatedLocations(ii,1:2) = LocationEstimationOfUser(userLocations(ii,1:2),accessPointsOut(:,1:2),20);
            estimatedLocations(ii,3) = ClassifyUser(estimatedLocations(ii,1:2),accessPointsOut,5);
            userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
        end

        realUserClass = ClassifyGrid(userLocations,modelParam,gridNumbers(j),gridNumbers(k));

        classificationAccuracy(2,(j-1)*10 + k) = mean((realUserClass(:,3) == estimatedLocations(:,3)));
        classificationAccuracy(1,(j-1)*10 + k) = windowSize/(gridNumbers(j)*gridNumbers(k));
        realLocationClassAccuracy(2,(j-1)*10 + k) = mean((realUserClass(:,3) == userLocations(:,3)));
        realLocationClassAccuracy(1,(j-1)*10 + k) = windowSize/(gridNumbers(j)*gridNumbers(k));

        DD = pdist2(userLocations(:,1:2),estimatedLocations(:,1:2));

        error = zeros(length(DD),1);

        for l = 1:length(DD)
            error(l) = DD(l,l);
        end

        meanError(2,(j-1)*10 + k) = nanmean(error);
        meanError(1,(j-1)*10 + k) = windowSize/(gridNumbers(j)*gridNumbers(k));
        medianError(2,(j-1)*10 + k) = nanmedian(error);
        medianError(1,(j-1)*10 + k) = windowSize/(gridNumbers(j)*gridNumbers(k));

        waitbar((((j-1)*10) + k)/100,hwait);
    end
end

figure
subplot(1,2,1);
plot(meanError(1,:),meanError(2,:),'.b');
title('Mean Locatin Error vs Number of Grids');
xlabel('Grid Size (m^2)');
ylabel('Mean Location Error (m)');

subplot(1,2,2);
plot(medianError(1,:),medianError(2,:),'.b');
title('Median Locatin Error vs Number of Grids');
xlabel('Grid Size (m^2)');
ylabel('Median Location Error (m)');

figure
subplot(1,2,1);
plot(classificationAccuracy(1,:),classificationAccuracy(2,:),'.b');
title('Classification Accuracy for Estimated Location of Users vs Number of Grids');
xlabel('Grid Size (m^2)');
ylabel('Classification Accuracy (%)');
axis([0 4500 0 1]);

subplot(1,2,2);
plot(realLocationClassAccuracy(1,:),realLocationClassAccuracy(2,:),'.b');
title('Classification Accuracy for Real Location of Users vs Number of Grids');
xlabel('Grid Size (m^2)');
ylabel('Classification Accuracy (%)');
axis([0 4500 0 1]);

runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);