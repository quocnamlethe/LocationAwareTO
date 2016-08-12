function [ModelParameters] = ModelParaSet()
% ModelParaSet - The model description used to generate the base station
% locations
% 
% Syntax: [ModelParameters] = ModelParaSet()
%
% Outputs:
%   ModelParameter - a structure containing the model parameters for base
%   station location generation
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Additional Info:
%   Model Parameters:
%       win - the study region
%       lambda - the density of the points per 1 m^2
%       alpha_norm - the normalized perterbation distance
%       r_norm - the normalized hard-core distance
%       gama - TODO
%       metric - the CoV metric. Options are: 'CN', 'CV', 'CD', or 'All'
%   Type of models
%       [1] Peterbed lattice models 
%       hexUni        Hexagonal Layout with uniform perterbation 
%       hexGau        Hexagonal Layout with Gaussian perterbation 
%       sqUni         Square layout with uniform perterbation
%       sqGau         Square layout with Gaussian perterbation
%       SSI
%       MHCI
%       MHCII

%------------- BEGIN CODE --------------
    % defaults
    win = [-500 500 -500 500];    % the study region
    lambda = 100*10^-6;           % the density of the points per 1 m^2
    alpha_norm = 0.2;             % Normalized perterbation distance
    r_norm = 0.2;                 % Normalized Hard-core distance
    gama = 1; 
    %======================================================================
    % Metric defaults
    metric = 'All';               % The default CoV metric. Other options: 'CN', 'CV', 'CD', or All. 
    %======================================================================

    ModelParameters=struct( 'win', win, ...
                            'lambda', lambda, ...
                            'alpha_norm', alpha_norm, ...
                            'r_norm',r_norm, ...
                            'gama', gama, ...
                            'metric',metric);
                  
%------------- END OF CODE --------------
end

%  /* Copyright (C) 2016 Faraj Lagum @ Carleton University - All Rights Reserved
%   You may use and modify this code, but not to distribute it.  
%  If You don't have a license to used this code, please write to:
%  faraj.lagum@sce.carleton.ca. */