%{
Purav Patel 
Project 1: GTP / IMSA Lap Time Simulator
Start Date: 1/28/2026
Finish Date: 5/3/2026
%}

%{
Units used for all measurements of code are as follows
Mass (kg) --> defined as m
Engine Power (kW) --> defined as P
Drag Coefficient --> defined as Cd
Frontal Area (m^2) --> defined as A
Downforce Coefficient --> defined as cL
Tire Friction Coefficient --> defined as mu
Air Density (kg/m^3) --> defined as rho
Track Length (meters)
Gravity (m/s^2) --> defined as g
%}

clc;
clear;
close all;


%% 1. Choosing Vechicle parameters

disp('Select your car configuration:')
disp('1) GTP IMSA')
disp('2) GTP Le Mans')
carchoice = input('Car: ');

disp('Select your track layout:')
disp('1) Daytona (Rolex 24)')
disp('2) Le Mans')
trackchoice = input('Track: ');

disp('Select your aero configuration:')
disp('1) Low Downforce')
disp('2) Med Downforce')
disp('3) High Downforce')
disp('4) Custom Downforce Configuration')
aerochoice = input('Aero: ');

% vechicle and driver parameters and categories

% shared parameters
driver = 0.97;
g = 9.81;
car.rho = 1.225;                                         % air properties
car.Crr = 0.012; 
car.engine = 650; 
car.redline = 9000 * (2*pi / 60); 

car.gears = [3.0, 2.2, 1.7, 1.3, 1.05, 0.9, 0.75]; 
car.final = 3.2; 
car.wheelrad = 0.32; 

car.maxacc = 10; 
car.amaxbrake = 20; 

switch carchoice

    case 1 % GTP IMSA
car.name = 'GTP';
car.m = 1030;                                            % units: kg (regulated minimum with driver)
car.P = 510e3;
car.Cd = 0.85;                                           % drag coefficent
car.A = 1.6;                                             % small frontal area
car.Cl = -3.5;                                            % high downforce
car.mu = 1.7;                                            % racing slicks

    case 2 % GTP Le Mans
car.name = 'GTP Le Mans';
car.m = 1030; 
car.P = 510e3;
car.Cd = .60;
car.A = 1.6; 
car.Cl = -2.2;
car.mu = 1.65;

end

%% 2. Track model definition (testing segment)


% track segment Daytona
function track = buildDaytona()
    track = struct('type', {}, 'length', {}, 'radius', {}, 'angle', {}, 'bank', []);
    
    % Start/Finish Straight
    track(end+1) = struct('type', 'straight', 'length', 1100, 'radius', [], 'angle', [], 'bank', 0);
    
    % T1 (Left into infield)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', pi*0.7, 'bank', 0);
    track(end+1) = struct('type', 'straight', 'length', 150, 'radius', [], 'angle', [], 'bank', 0);
    
    % International Horseshoe (Right)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 35, 'angle', -pi, 'bank', 0);
    track(end+1) = struct('type', 'straight', 'length', 300, 'radius', [], 'angle', [], 'bank', 0);
    
    % West Horseshoe (Right)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 35, 'angle', -pi*0.4, 'bank', 0);
    track(end+1) = struct('type', 'straight', 'length', 260, 'radius', [], 'angle', [], 'bank', 0);
    
    % Exit infield back to oval (Left)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', pi*0.7, 'bank', 0);
    
    % Oval Turns 1 and 2 (Left, banked)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 300, 'angle', pi, 'bank', 31);
    
    % Backstretch
    track(end+1) = struct('type', 'straight', 'length', 1600, 'radius', [], 'angle', [], 'bank', 0);
    
    % Bus Stop Chicane (Left, Right)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 60, 'angle', pi/6, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 60, 'angle', -pi/6, 'bank', 0);
    
    % Oval Turns 3 and 4 (Left, banked)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 300, 'angle', pi, 'bank', 31);
    track(end+1) = struct('type', 'straight', 'length', 500, 'radius', [], 'angle', [], 'bank', []);

end


% Track Segment Le Mans (Circuit de la Sarthe)
function track = buildLeMans()
    track = struct('type', {}, 'length', {}, 'radius', {}, 'angle', {}, 'bank', []);
    
    % Start/Finish to Dunlop Curve
    track(end+1) = struct('type', 'straight', 'length', 600, 'radius', [], 'angle', [], 'bank', 0);
    
    % Dunlop Curve & Chicane (Right, Left, Right)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 200, 'angle', -pi*0.15, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', pi/4, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', -pi/4, 'bank', 0);
    
    % Run to Tertre Rouge
    track(end+1) = struct('type', 'straight', 'length', 800, 'radius', [], 'angle', [], 'bank', 0);
    
    % Tertre Rouge (Fast Right onto Mulsanne -> Heading is now pointing South)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 80, 'angle', -pi*0.35, 'bank', 0);
    
    % Mulsanne Straight Part 1
    track(end+1) = struct('type', 'straight', 'length', 1600, 'radius', [], 'angle', [], 'bank', 0);
    
    % Chicane 1 (Right-Left-Right, Net 0)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 70, 'angle', -pi/6, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 70, 'angle', pi/3, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 70, 'angle', -pi/6, 'bank', 0);
    
    % Mulsanne Straight Part 2
    track(end+1) = struct('type', 'straight', 'length', 1900, 'radius', [], 'angle', [], 'bank', 0);
    
    % Chicane 2 (Left-Right-Left, Net 0)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 70, 'angle', pi/6, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 70, 'angle', -pi/3, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 70, 'angle', pi/6, 'bank', 0);
    
    % Mulsanne Straight Part 3
    track(end+1) = struct('type', 'straight', 'length', 1500, 'radius', [], 'angle', [], 'bank', 0);
    
    % Mulsanne Corner (Hard Right at the end of the straight)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 40, 'angle', -pi*0.65, 'bank', 0);
    
    % Run to Indianapolis
    track(end+1) = struct('type', 'straight', 'length', 1200, 'radius', [], 'angle', [], 'bank', 0);
    
    % Indianapolis (Fast Right, Hard Left)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 150, 'angle', -pi*0.15, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', pi*0.3, 'bank', 0);
    
    % Short straight to Arnage
    track(end+1) = struct('type', 'straight', 'length', 200, 'radius', [], 'angle', [], 'bank', 0);
    
    % Arnage (Slowest corner on track, Tight Right -> Heading is now pointing North)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 30, 'angle', -pi*0.5, 'bank', 0);
    
    % Run to Porsche Curves
    track(end+1) = struct('type', 'straight', 'length', 1500, 'radius', [], 'angle', [], 'bank', 0);
    
    % Porsche Curves (Sweeping flow R-L-L-R -> Heading points back East to Finish)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 180, 'angle', -pi*0.2, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 150, 'angle', pi*0.2, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 150, 'angle', pi*0.1, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 120, 'angle', -pi*0.6, 'bank', 0);
    
    % Corvette Corner to Ford Chicanes
    track(end+1) = struct('type', 'straight', 'length', 500, 'radius', [], 'angle', [], 'bank', 0);
    
    % Ford Chicanes (Net 0)
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', pi/6, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', -pi/3, 'bank', 0);
    track(end+1) = struct('type', 'corner', 'length', [], 'radius', 50, 'angle', pi/6, 'bank', 0);
    
    % Final sprint to finish
    track(end+1) = struct('type', 'straight', 'length', 300, 'radius', [], 'angle', [], 'bank', 0);
end

if trackchoice == 1
    track = buildDaytona();
    trackname = 'Daytona (Rolex 24)'; 
elseif trackchoice == 2
        track = buildLeMans();
        trackname = 'Le Mans (24 hrs)';
else 
    error('Invalid Selection, Please Try Again: ')
end

%% 3. Aerodynamic Configurations

switch aerochoice 

    case 1 % Low Downforce
        aeroname = 'Low Downforce';
        car.Cd = car.Cd * 0.80;
        car.Cl = car.Cl * 0.65;

    case 2 % Medium Downforce
        aeroname = 'Medium Downforce';

    case 3 % High Downforce
        aeroname = 'High Downforce';
        car.Cd = car.Cd * 1.15;
        car.Cl = car.Cl * 1.35;

    case 4 % Custom Downforce
        aeroname = 'Custom Downforce';
        car.Cd = input('Enter Cd: ');
        car.Cl = input('Enter Cl (negative number): ');

    otherwise 
        error('Invalid Aero Choice, Please Try Again')
end
%% 4. Straight speed 

% inital conditions
v = 0; 
stotal = 0;
ttotal = 0;

shistory = [];
vhistory = [];
thistory = [];

% sector setup 
sectorend = [1 3 5];
sectortimes = zeros(1, length(sectorend));
sectorindex = 1;
sectorstart = 0;

% Discretize Track (Solving for ideal sector first, then time)
ds = 0.5;                                                              % spatial step (m) -> 1-5 m is good
sprofile = [];
Rprofile = [];
bankprofile = [];

%% 5. main track loop

% Straight segments 

for i = 1:length(track)

    if ~isfield(track, 'bank') || isempty(track(i).bank)
        currentbank = 0; 

    else 
        currentbank = track(i).bank;

    end

    if strcmp(track(i).type, 'straight')
        dslocal = ds;
        Nseg = ceil(track(i).length / ds);
        sprofile = [sprofile, dslocal * ones(1, Nseg)];
        Rprofile = [Rprofile, Inf * ones(1, Nseg)];
        bankprofile = [bankprofile, currentbank * ones(1,Nseg)];

    else 
        R = track(i).radius;
        ang = track(i).angle;
        L = R * abs(ang);
        dslocal = ds;
        Nseg = ceil(abs(L)/ds);
        sprofile = [sprofile, dslocal * ones(1,Nseg)];
        Rprofile = [Rprofile, R * ones(1, Nseg)];
        bankprofile = [bankprofile, currentbank * ones(1,Nseg)];
    end
end

N = length(sprofile);

% Corner speed limit

vcornermax = zeros(1,N);

for i = 1:N
    if isfinite(Rprofile(i))
        R = Rprofile(i);
        theta = bankprofile(i) * (pi/180);
       
        num = g * (car.mu * cos(theta) + sin(theta));
        den = cos(theta) - car.mu * sin(theta);

        if den <= 0
            v = Inf; 
        else
            v = sqrt(R * num / den);
        end

if isfinite(v)
        for k = 1:3
            Fdown = 0.5 * car.rho * car.A * abs(car.Cl) * v^2;
            mueff = car.mu * (1 - 0.05 * Fdown / (car.m * g));

            numaero = car.m * g * (mueff * cos(theta) + sin(theta)) + mueff * Fdown;
            denaero = car.m * (cos(theta) - mueff * sin(theta));

            if denaero <= 0
                v = Inf; 
            else 
                v = sqrt(R * numaero / denaero);
            end
        end
end

if isfinite(v) 
    vcornermax(i) = v * driver * (0.95 - 0.05 * (v/100));
else
    vcornermax(i) = Inf; 
end
    else 
        vcornermax(i) = Inf;
    end
end

%% 6. Forward / Backward pass 

% forward pass 
vforward = zeros(1,N);
vforward(1) = 1; 

for i = 1:N-1
    v = vforward(i); 

    Fdrag = 0.5 * car.rho * car.A * car.Cd * v^2;

    Fdown = 0.5 * car.rho * car.A * abs(car.Cl) * v^2;
    Nforce = car.m * g + Fdown; 

    Fdrive = car.P / max(v, 10); 
    Fmax = car.mu * Nforce; 
    Fdrive = min(Fdrive, Fmax);
   
    Froll = car.Crr * car.m * g; 

    a = (Fdrive - Fdrag - Froll) / car.m;

    vtarget = vcornermax(i+1);
    vlimit = vcornermax(i+1);
    vnext = sqrt(max(v^2 + 2 * a * ds, 0));
    vforward(i+1) = min([vnext,vlimit]);

if mod(i,100) == 0
    disp([v, Fdrive, a]);
end

end

% Backward pass 
vbackward = vforward; 
vbackward(end) = vforward(end); 

for i = N-1:-1:1
    vnext = vbackward(i+1);

    v = vbackward(i);

    % Braking Force 
    Fdown = 0.5 * car.rho * car.A * abs(car.Cl) * v^2; 
    Nforce = car.m * g + Fdown; 

    Fbrake = car.mu * Nforce; 

    Fdrag = 0.5 * car.rho * car.A * car.Cd * v^2;
    Froll = car.Crr * car.m * g;

    a = (Fbrake + Fdrag + Froll) / car.m;

    vallowed = sqrt(max(vnext^2 + 2 * a * ds, 0));

    vbackward(i) = min([v, vallowed, vcornermax(i)]); 

end

% Final speed profile
vprofile = min(vforward,vbackward); 

%% 8. Lap and sector time computation

% laptime calculation 

laptime = 0; 

for i = 1:N-1
    vavg = (vprofile(i) + vprofile(i+1)) / 2;
    laptime = laptime + ds / max(vavg, 1);
end

timeprofile = zeros(1,N);

for i = 2:N
    vavg = (vprofile(i) + vprofile(i-1)) / 2;
    dt = sprofile(i-1) / max(vavg, 1);
    timeprofile(i) = timeprofile(i-1) + dt; 

end

%% 9. Track map visualization

x = 0; 
y = 0; 
theta = 0;                                                 % heading angle

xtrack = [x];
ytrack = [y];

for i = 1:length(track)

    if strcmp(track(i).type, 'straight')

        L = track(i).length; 
        Nseg = ceil(L/ds);

        for j = 1:Nseg
            x = x + ds * cos(theta);
            y = y + ds * sin(theta); 

            xtrack(end+1) = x; 
            ytrack(end+1) = y;

        end
    else 
        R = track(i).radius; 
        ang = track(i).angle; 
        L = R * abs(ang);
        Nseg = ceil(L / ds);
        dtheta = ang / Nseg; 
      
        for j = 1:Nseg
            theta = theta + dtheta;

            x = x + ds * cos(theta);
            y = y + ds * sin(theta); 

            xtrack(end+1) = x; 
            ytrack(end+1) = y; 

        end
    end
end

%% 10. output

fprintf('\n--- Simulation Results ---\n')
fprintf('Car: %s\n', car.name);
fprintf('track: %s\n', trackname);
fprintf('Aerodynamic Configuration: %s\n', aeroname)
fprintf('Lap time: %.2f s\n', laptime);
fprintf('Max speed: %.2f m/s (%.1f km/h)\n', max(vprofile), max(vprofile)*3.6);
fprintf('Average speed: %.2f m/s\n', sum(sprofile)/laptime);

%% 11. plots  

aprofile = zeros(1,N-1);

for i = 1:N-1
    aprofile(i) = (vprofile(i+1)^2 - vprofile(i)^2) / (2 * ds);
end

%speed vs. distance plot 
scum = [0 cumsum(sprofile(1:end-1))];

figure
plot(scum, vprofile, 'LineWidth', 2)
hold on

brakeidx = aprofile < -1;
plot(scum(brakeidx), vprofile(brakeidx), 'r.', 'Markersize', 8)
ylabel('Speed (m/s)')
title(['Speed Profile - ', car.name])
grid on
legend('Speed', 'Braking zones')

% speed vs. time plot 

minlen = min(length(timeprofile), length(vprofile));   

figure
plot(timeprofile(1:minlen), vprofile(1:minlen), 'LineWidth', 1.5)
xlabel('Time (s)')
ylabel('Velocity (m/s)')
title('Speed vs. Time')
grid on

% distance vs. acceleration plot

scumaccel = scum(1:N-1);
minlen = min(length(scumaccel), length(aprofile)); 

hold on
yline(0, '--k')

figure
plot(scumaccel(1:minlen), aprofile(1:minlen), 'LineWidth', 1.5)
xlabel('Distance (m)')
ylabel('Acceleration (m/s^2)')
title('Acceleration Profile')
grid on

minlen = min([length(xtrack), length(ytrack), length(vprofile)]);

figure 
scatter(xtrack(1:minlen), ytrack(1:minlen), 10, vprofile(1:minlen), 'filled')

hold on

% braking index (zones)
brakeidx = find(aprofile < -2);                                       % convert to numeric indices
brakeidx = brakeidx(brakeidx <= minlen);

scatter(xtrack(brakeidx), ytrack(brakeidx), 25, 'r', 'filled', 'MarkerEdgeColor', 'k')

colorbar
colormap turbo
axis equal

xlabel('X Pos (m)')
ylabel('Y Pos (m)')

title(['Track Map Colored by Speed - ', car.name])
grid on 




