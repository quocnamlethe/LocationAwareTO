gridSizes = [];
for j = 1:20
    for k = 1:20
        gridSizes = [gridSizes windowSize/(gridNumbers(j)*gridNumbers(k))];
    end
end

gridSizes = unique(round(gridSizes,4));

accuracy = [0.95 0.90 0.85 0.80];
curve = zeros(4,3);
ii = 1;
figure
for acc = accuracy
    dataPoints = [];
    for j = 1:length(gridSizes)
        tempIndex = find(notNanMean(1,:) == gridSizes(j));
        tempVector = notNanMean(:,tempIndex);
        %if densities(j) > 3
            for k = 1:size(tempVector,2)
                if (tempVector(3,k) > acc)
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
    for j = 1:length(densities)
        tempIndex = find(notNanMean(2,:) == densities(j));
        tempVector = notNanMean(:,tempIndex);
        %if densities(j) > 3
            for k = size(tempVector,2):-1:1
                if (tempVector(3,k) > acc)
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
    curve(ii,1) = acc;
    curve(ii,2) = f.p1;
    curve(ii,3) = f.q1;
    ii = ii + 1;
    hold on
end
hold off