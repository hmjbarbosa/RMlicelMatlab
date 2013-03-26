%------------------------------------------------------------------------
% M-File:
%    read_sonde_Manaus.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Hesse (heese@tropos.de), IFT, Leipzig, Germany
%
% Description
%
%    Reads temperature and pressure profiles from Wyoming soundings
%    as used by Manaus/Embrapa Lidar. This version is based on
%    original code written by Birgit Hesse, from iFT,
%    Leipzig. Cleaning, debugging, commenting and modification in
%    variable's names done by hbarbosa.
%
% Input
%
%    radiofile - path and filename to data file
%
% Ouput
%
%    pres_snd(nlev_snd, 1) - column with pressure in hPa
%    temp_snd(nlev_snd, 1) - column with temperature in K
%    rho_snd(nlev_snd, 1) - column with density in kg/m3
%    alt_snd(nlev_snd, 1) - column with altitude in m
%
% Usage
%
%    First run: 
%
%        constants.m
%
%    Then execute this script.
%
%------------------------------------------------------------------------
clear sondedata
clear temp_snd pres_snd rho_snd alt_snd nlev_snd

% cannot read as a table because wyoming files have empty space for
% missing data. usually happens at higher altitudes. the reading
% mechanism, in this case, must rely on the constant width of the
% fields. 

disp(['*** read radiosounding data ' radiofile]);

fid=fopen(radiofile,'r'); 
% read the headers
for j=1:7
  eval(['headerline_sonde' num2str(j) '=fgetl(fid);']);
end   
% read sounding data
i=0;
while ~feof(fid);
  sondedata = fgetl(fid);
  if ~isempty(sondedata)
    i=i+1;
    pres_snd(i,1)=str2num(sondedata(1:7));  % P in hPa!
    alt_snd(i,1)=str2num(sondedata(8:14)); % in m 
    temp_snd(i,1)=T0 + str2num(sondedata(15:21)); % T in K
% P = rho*R*T, R=287.05 J/kg/K
% 100 corrects hPa to Pa, hence rho in kg/m3
    rho_snd(i,1)=100*pres_snd(i,1)./temp_snd(i,1)/Rair;
  else
    break    
  end 
end 
fclose(fid);

% number of levels in sounding
nlev_snd=max(size(pres_snd));

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
%
% -------------
figure(4)
xx=xx0+5*wdx; yy=yy0+5*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(temp_snd,alt_snd*1e-3,'Color','r');
hold on
ax1 = gca;
set(ax1,'XColor','r','YColor','k','XAxisLocation','bottom')
ylabel(ax1,'Height / km')
xlabel(ax1,'Temperature / K')
xlimits = get(ax1,'XLim');
ylimits = get(ax1,'YLim');
xinc = (xlimits(2)-xlimits(1))/5;
yinc = (ylimits(2)-ylimits(1))/5;

set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)]);

ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
           'YAxisLocation','right','Color','none',...
           'XColor','b','YColor','k');
xlabel(ax2,'density / kg/m3')
line(rho_snd,alt_snd,'Color','b','Parent',ax2);
grid on
hold off
%
%
disp('End of program: read_sonde_Manaus.m, Vers. 1.0 06/2012')
%