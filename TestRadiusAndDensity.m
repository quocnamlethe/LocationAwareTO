clear;
clc;

% Wait bar
hwait = waitbar(0,'Calculating');
tic;

modelParam = ModelParaSet();
modelParam.lambda = 0.01; % Density
modelParam.alpha_norm = 0;
modelParam.win = [-100 100 -100 100];

userModelParam = ModelParaSet();
userModelParam.lambda = 0.01;
userModelParam.alpha_norm = 0;
userModelParam.win = [-50 50 -50 50];

arraySize = 4000;
meanError = zeros(3,arraySize);
medianError = zeros(3,arraySize);
estimatedClassAccuracy = zeros(3,arraySize);
realLocationClassAccuracy = zeros(3,arraySize);

maxError = 100;
densities = logspace(log10(0.001),log10(0.1),80);
radiuses = logspace(log10(0.1),log10(50),50);

for j = 1:50
    for k = 1:80
        index = 80*(j-1)+k;
        radius = radiuses(j);
        density = densities(k);
        modelParam.lambda = density;
        accessPoints = UT_LatticeBased('hexUni',modelParam);
        accessPointsOut = ClassifyGrid(accessPoints,modelParam,5,5); % Number of rectangular grids. Can change later to accommadate different grid shapes

        userLocations = UT_LatticeBased('sqUni',userModelParam);
        userLocations = [userLocations zeros(length(userLocations),1)];

        estimatedLocations = zeros(length(userLocations),3);
        for ii = 1:length(userLocations)
            estimatedLocations(ii,1:2) = LocationEstimationOfUser(userLocations(ii,1:2),accessPointsOut(:,1:2),radius);
            estimatedLocations(ii,3) = ClassifyUser(estimatedLocations(ii,1:2),accessPointsOut,5);
            userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
        end

        realUserClass = ClassifyGrid(userLocations,modelParam,5,5);

        classificationAccuracy(1,index) = radius;
        classificationAccuracy(2,index) = density;
        classificationAccuracy(3,index) = mean((realUserClass(:,3) == estimatedLocations(:,3)));
        realLocationClassAccuracy(1,index) = radius;
        realLocationClassAccuracy(2,index) = density;
        realLocationClassAccuracy(3,index) = mean((realUserClass(:,3) == userLocations(:,3)));

        DD = pdist2(userLocations(:,1:2),estimatedLocations(:,1:2));

        error = zeros(length(DD),1);

        for l = 1:length(DD)
            error(l) = DD(l,l);
%             if isnan(error(l))
%                 error(l) = maxError;
%             end
        end

        meanError(1,index) = radius;
        meanError(2,index) = density;
        meanError(3,index) = nanmean(error);
        medianError(1,index) = radius;
        medianError(2,index) = density;
        medianError(3,index) = nanmedian(error);
    
    end
    waitbar(index/arraySize,hwait);
end

% figure
% subplot(1,2,1);
% plot3(medianError(1,:),medianError(2,:),medianError(3,:),'.b');

notNanIndex = find(~isnan(medianError(3,:)));
notNanMean = medianError(:,notNanIndex);
% figure
% plot3(notNanMean(1,:),notNanMean(2,:),notNanMean(3,:),'.b');

X = [notNanMean(1,:);notNanMean(2,:)]'\notNanMean(3,:)';

figure('Name','Radius vs Density');
%subplot(1,2,1);
plot3(notNanMean(1,:),notNanMean(2,:),notNanMean(3,:),'.b');
xlabel('Radius (m)');
ylabel('AP Density (per m^2)');
zlabel('Median Error (m)');

%subplot(1,2,2);
figure('Name','Radius vs Density');
scatter(notNanMean(1,:),notNanMean(2,:),10,notNanMean(3,:),'filled')
xlabel('Radius (m)');
ylabel('AP Density (per m^2)');
set(gca,'CLim',[0 25])
colorbar
mymap = [1,0,0;0,0,1;0,1,0;1,0,1];
%colormap(mymap);

figure('Name','AP per Radius Area');
plot(notNanMean(1,:).*notNanMean(1,:).*notNanMean(2,:)*pi,notNanMean(3,:),'.b');
xlabel('AP per Radius');
ylabel('Median Error (m)');

errors = [1 2.5 5 10];
plottitle = ['Error < 1m','Error < 2.5m','Error < 5m','Error < 10m'];
curve = zeros(4,3);
ii = 1;
figure
for err = errors
    dataPoints = [];
    for j = length(radiuses):-1:1
        tempIndex = find(notNanMean(1,:) == radiuses(j));
        tempVector = notNanMean(:,tempIndex);
        if radiuses(j) > 3
            for k = size(tempVector,2):-1:1
                if (tempVector(3,k) > err * 0.9)
                    if isempty(dataPoints)
                        dataPoints = tempVector(:,k);
                    elseif tempVector(2,k) ~= densities(length(densities))
                        dataPoints = [dataPoints tempVector(:,k)];
                    end
                    break
                end
            end
        end
    end
    f = fit(dataPoints(1,:)',dataPoints(2,:)','rat01');
    subplot(2,2,ii);
    plot(f,dataPoints(1,:)',dataPoints(2,:)');
    title(['Error < ',num2str(err),'m']);
    xlabel('AP per Radius');
    ylabel('Median Error (m)');
    curve(ii,1) = err;
    curve(ii,2) = f.p1;
    curve(ii,3) = f.q1;
    ii = ii + 1;
    hold on
end
hold off

for err = 2.5
    dataPoints = [];
    for j = length(radiuses):-1:1
        tempIndex = find(notNanMean(1,:) == radiuses(j));
        tempVector = notNanMean(:,tempIndex);
        if radiuses(j) > 3
            for k = size(tempVector,2):-1:1
                if (tempVector(3,k) > err * 0.9)
                    if isempty(dataPoints)
                        dataPoints = tempVector(:,k);
                    elseif tempVector(2,k) ~= densities(length(densities))
                        dataPoints = [dataPoints tempVector(:,k)];
                    end
                    break
                end
            end
        end
    end
    f = fit(dataPoints(1,:)',dataPoints(2,:)','rat01');
end

arraySize = 4000;
meanError = zeros(3,arraySize);
medianError = zeros(3,arraySize);
estimatedClassAccuracy = zeros(3,arraySize);
realLocationClassAccuracy = zeros(3,arraySize);

for j = 1:50
    for k = 1:80
        index = 80*(j-1)+k;
        radius = radiuses(j);
        density = densities(k);
        if (f(radius) < density) && (radius > -f.q1)
            modelParam.lambda = density;
            accessPoints = UT_LatticeBased('hexUni',modelParam);
            accessPointsOut = ClassifyGrid(accessPoints,modelParam,5,5); % Number of rectangular grids. Can change later to accommadate different grid shapes

            userLocations = UT_LatticeBased('sqUni',userModelParam);
            userLocations = [userLocations zeros(length(userLocations),1)];

            estimatedLocations = zeros(length(userLocations),3);
            for ii = 1:length(userLocations)
                estimatedLocations(ii,1:2) = LocationEstimationOfUser(userLocations(ii,1:2),accessPointsOut(:,1:2),radius);
                estimatedLocations(ii,3) = ClassifyUser(estimatedLocations(ii,1:2),accessPointsOut,5);
                userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
            end

            realUserClass = ClassifyGrid(userLocations,modelParam,5,5);

            classificationAccuracy(1,index) = radius;
            classificationAccuracy(2,index) = density;
            classificationAccuracy(3,index) = mean((realUserClass(:,3) == estimatedLocations(:,3)));
            realLocationClassAccuracy(1,index) = radius;
            realLocationClassAccuracy(2,index) = density;
            realLocationClassAccuracy(3,index) = mean((realUserClass(:,3) == userLocations(:,3)));

            DD = pdist2(userLocations(:,1:2),estimatedLocations(:,1:2));

            error = zeros(length(DD),1);

            for l = 1:length(DD)
                error(l) = DD(l,l);
            end

            meanError(1,index) = radius;
            meanError(2,index) = density;
            meanError(3,index) = nanmean(error);
            medianError(1,index) = radius;
            medianError(2,index) = density;
            medianError(3,index) = nanmedian(error);
        else
            meanError(1,index) = radius;
            meanError(2,index) = density;
            meanError(3,index) = NaN;
            medianError(1,index) = radius;
            medianError(2,index) = density;
            medianError(3,index) = NaN;
        end
    end
end

notNanIndex = find(~isnan(medianError(3,:)));
notNanMean = medianError(:,notNanIndex);

X = [notNanMean(1,:);notNanMean(2,:)]'\notNanMean(3,:)';

figure('Name','Radius vs Density');
subplot(1,2,1);
plot3(notNanMean(1,:),notNanMean(2,:),notNanMean(3,:),'.b');
xlabel('Radius (m)');
ylabel('Density (per m^2)');
zlabel('Median Error (m)');

subplot(1,2,2);
scatter(notNanMean(1,:),notNanMean(2,:),10,notNanMean(3,:),'filled')
xlabel('Radius (m)');
ylabel('Density (per m^2)');
set(gca,'CLim',[0 5])
colorbar

runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);