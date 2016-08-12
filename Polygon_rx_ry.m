function [rx, ry ] = Polygon_rx_ry(Win)
% Exmple
 % let
 % Win=[-500 500 -500 500]; 
 % [rx, ry ] = Polygon_rx_ry(Win)
 % the result 
 % rx=[-500,500,500,-500,-500]
 % ry=[-500,-500,500,500,-500]
rx = [Win(1) Win(2) Win(2) Win(1) Win(1)]; %   rx = [0 1000 1000 0 0]';
ry = [Win(3) Win(3) Win(4) Win(4) Win(3)]; %   ry = [0 0 1000 1000 0]';
end

