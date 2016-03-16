% This code models the rainfall, infiltration, and runoff on a 1D hillslope
% Written by AGT 3/15/2016

clear all
figure(1)
clf

%% initialize

%constants
g = 9.81; %gravity, m/s2
R = 0.001/3600; %rain rate, m/s (1 mm/hr)
I = 0.0005/3600; %infiltration rate, m/s (0.5 mm/hr)
n = 0.05; %surface coefficient ???? look up mannings n on the web

% create distance array
xmax = 100; %m 
dx = 1; %m
x = (dx/2):dx:xmax-(dx/2); %so that the x value is in the middle of each 'box'
N = length(x); %number of 'boxes

% set up time array
P = 1; %input for max time, hours
tmax = 3600*P; %max time, seconds
dt = 0.1; %seconds
t = 0:dt:tmax;

%define bedrock profile
zbmax = 10; %max height, meters
slope = -0.1; %constant slope of bedrock
zb = (slope*x)+zbmax; %bedrock profile
floor = zeros(size(x)); %array of zeros for plotting

Se = slope; %energy slope
ubar = zeros(size(x)); %initial depth average flow velocity, zeros
h = zeros(size(x)); %initial height of water, zero
z = h+zb; %height of water on top of bedrock
hedge = zeros(size(x)); %preallocate array for height of water at edge of boxes

imax = length(t);
nplots = 50;
tplot = tmax/nplots;

%% run

for i = 1:imax
    
    hedge = h(1:N-1) + (diff(h)/2); %this yields the new edge h's, n-1 elements
    ubar = (1/n).*(hedge.^(2/3))*(abs(Se)^(1/2)); %depth average flow velocity, n-1 elements
    q(2:N) = ubar.*hedge; %flux, n elements
    q(1) = 0; %set flux at top=0
    
    dqdx(1:N-1) = diff(q)./dx; %change in flux, n-1 elements
    dqdx(N) = dqdx(N-1); %pads end of dqdx with last value, dqdx is now n elements
    dhdt = -dqdx+R-I; %change in flux + rain - infiltration, n elements
    h = h+(dhdt.*dt); %new water thickness
    h = max(h,0); %so that water height does not become negative
    z = zb+h; %new water surface elevation 
    
    if(rem(t(i),tplot)==0)
        figure(1)      
        subplot(2,1,1)
        X=[x,fliplr(x)];
        H=[h*1000,fliplr(floor)];
        fill(X,H,'b') %fills water
        axis([0 xmax 0 0.5])
        title('Overland flow')
        xlabel('Distance downslope (m)','fontname','arial','fontsize', 14)
        ylabel('Water height (mm)', 'fontname', 'arial', 'fontsize', 14)
        set(gca, 'fontsize', 14, 'fontname', 'arial')
        time=num2str(t(i)/60); %convert time of each plot to 'letters'
        timetext=strcat(time,' minutes'); %add years to the time
        text(10,0.4,timetext,'fontsize',14) %shows time on each plot
        pause(0.1)
        
        subplot(2,1,2)
        X=[x,fliplr(x)];
        Q=[q*1000^2,fliplr(floor)];
        fill(X,Q,'b') %fills water flux
        axis([0 xmax 0 15])
        title('Flux rate')
        xlabel('Distance downslope (m)','fontname','arial','fontsize', 14)
        ylabel('Water flux (mm^2/s)', 'fontname', 'arial', 'fontsize', 14)
        set(gca, 'fontsize', 14, 'fontname', 'arial')
        pause(0.1)
    end
end


