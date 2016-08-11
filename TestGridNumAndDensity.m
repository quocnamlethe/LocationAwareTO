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

windowSize = 10000;
arraySize = 8000;
meanError = zeros(3,arraySize);
medianError = zeros(3,arraySize);
estimatedClassAccuracy = zeros(3,arraySize);
realLocationClassAccuracy = zeros(3,arraySize);
densities = repmat(logspace(log10(0.001),log10(0.1),20),1,2);
gridNumbers = logspace(log10(1.5),log10(10),20);

gridSizes = [];
for j = 1:20
    for k = 1:20
        gridSizes = [gridSizes windowSize/(gridNumbers(j)*gridNumbers(k))];
    end
end

gridSizes = unique(round(gridSizes,4));

userLocations = UT_LatticeBased('sqUni',userModelParam);
userLocations = [userLocations zeros(length(userLocations),1)];

for j = 1:20
    for k = 1:20
        for l = 1:20
            index = 400*(j-1)+20*(k-1)+l;
            gridNum = gridNumbers(j)*gridNumbers(k);
            
            density = densities(l);
            modelParam.lambda = density;
            accessPoints = UT_LatticeBased('hexUni',modelParam);
            
            accessPointsOut = ClassifyGrid(accessPoints,modelParam,gridNumbers(j),gridNumbers(k)); % Number of rectangular grids. Can change later to accommadate different grid shapes
            estimatedLocations = zeros(length(userLocations),3);
            for ii = 1:length(userLocations)
                userLocations(ii,3) = ClassifyUser(userLocations(ii,1:2),accessPointsOut,5);
            end

            realUserClass = ClassifyGrid(userLocations,modelParam,gridNumbers(j),gridNumbers(k));

            realLocationClassAccuracy(1,index) = round(windowSize/gridNum,4);
            realLocationClassAccuracy(2,index) = density;
            realLocationClassAccuracy(3,index) = mean((realUserClass(:,3) == userLocations(:,3)));
        end
    end
    waitbar(index/arraySize,hwait);
end

figure('Name','Grid Number vs Density');
%subplot(1,2,1);
plot3(realLocationClassAccuracy(1,:),realLocationClassAccuracy(2,:),realLocationClassAccuracy(3,:),'.b');
xlabel('Grid Size (m^2)');
ylabel('Density (per m^2)');
zlabel('Classification Accuracy (%)');

notNanIndex = find(~isnan(realLocationClassAccuracy(3,:)));
notNanMean = realLocationClassAccuracy(:,notNanIndex);

X = [notNanMean(1,:);notNanMean(2,:)]'\notNanMean(3,:)';

%subplot(1,2,2);
figure('Name','Grid Number vs Density');
scatter(notNanMean(1,:),notNanMean(2,:),10,notNanMean(3,:),'filled')
xlabel('Grid Size (m^2)');
ylabel('Density (per m^2)');
set(gca,'CLim',[0.5 1])
colorbar
mymap = [1,0,0;0,0,1];
%colormap(mymap);

figure('Name','AP per Grid');
plot(notNanMean(1,:).*notNanMean(2,:),notNanMean(3,:),'.b');
xlabel('AP per Grid');
ylabel('Classification Accuracy (%)');

accuracy = [0.95 0.90 0.85 0.75];
curve = zeros(4,3);
ii = 1;
figure
for acc = accuracy
    dataPoints = [];
    for j = length(gridSizes):-1:1
        tempIndex = find(notNanMean(1,:) == gridSizes(j));
        tempVector = notNanMean(:,tempIndex);
        %if densities(j) > 3
            for k = size(tempVector,2):-1:1
                if (tempVector(3,k) < acc)
                    if isempty(dataPoints)
                        dataPoints = tempVector(:,k);
                    else%if tempVector(1,k) ~= gridSizes(length(gridSizes))
                        dataPoints = [dataPoints tempVector(:,k)];
                    end
                    break
                end
            end
        %end
    end
    for j = length(densities):-1:1
        tempIndex = find(notNanMean(2,:) == densities(j));
        tempVector = notNanMean(:,tempIndex);
        %if densities(j) > 3
            for k = 1:size(tempVector,2)
                if (tempVector(3,k) < acc)
                    if isempty(dataPoints)
                        dataPoints = tempVector(:,k);
                    else%if tempVector(1,k) ~= gridSizes(length(gridSizes))
                        dataPoints = [dataPoints tempVector(:,k)];
                    end
                    break
                end
            end
        %end
    end
    dataPoints = unique(dataPoints','rows')';
    f = fit(dataPoints(1,:)',dataPoints(2,:)','rat01');
    subplot(2,2,ii);
    plot(f,dataPoints(1,:)',dataPoints(2,:)');
    title(['Accuracy > ',num2str(acc)]);
    xlabel('Grid Size (m^2)');
    ylabel('Density (per m^2)');
    axis([0 4500 0 0.1]);
    ii = ii + 1;
    hold on
end
hold off

runTime = toc;
fprintf('Runtime: %f\n',runTime);
close(hwait);