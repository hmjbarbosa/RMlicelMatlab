%% This routine opens the results from klett analysis for the week
% of the paper and make the plots for alfa and beta.
clear all

addpath('../matlab');
addpath('../sc');

load beta_klett_dry_overlapfinal_set2011.mat
jdi=datenum(2011, 8, 30, 0, 0, 0);
jdf=jdi+7;

maxbin=floor(5.01/7.5e-3);
minbin=floor(0.75/7.5e-3);
nslot=ceil((jdf-jdi)*1440+1);
data(1:maxbin,1:nslot)=NaN;
alfa(1:maxbin,1:nslot)=NaN;
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes
zz(1:maxbin)=(1:maxbin)'*7.5/1e3; % vertical in km

[nz, nfile]=size(klett_beta_aero);

for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  if (j<=nslot && j>=1)
    data(1:maxbin,j)=klett_beta_aero(1:maxbin,i)*1e3; % Mm-1
    alfa(1:maxbin,j)=klett_alpha_aero(1:maxbin,i)*1e3; % Mm-1
  end
end
for j=2:nslot-1
  if isnan(data(1,j)) && ~isnan(data(1,j-1)) && ~isnan(data(1,j+1))
    data(:,j)=(data(:,j-1)+data(:,j+1))*0.5;
    alfa(:,j)=(alfa(:,j-1)+alfa(:,j+1))*0.5;
  end
end

% mask shutter closed
for i=1:nslot
  jd(i)=(i-2-0.5)/1440+jdi;
  vec(i,:)=datevec(jd(i));
  if ((vec(i,4)>=11 & vec(i,4)<=14))
    data(:,i)=-100;
    alfa(:,i)=-100;
  end
end

%----------------------
figure(1); clf
set(gcf,'position',[0,300,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[0:0.05:5];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz(minbin:maxbin),data(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(data(minbin:maxbin,:)),...
     [.7 .7 .7],data(minbin:maxbin,:)==-100)
set(gca,'YDir','normal');
set(gca,'YDir','normal');
set(gca,'yticklabel',sprintf('%.1f|',get(gca,'ytick')));
colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;
set(get(bar,'ylabel'),'String','Backscatter (Mm^{-1} sr^{-1})');

datetick('x','mm/dd')
ylabel('Altitude agl (km)')
prettify(gca,bar);
tmp=datevec(jdi);
out=sprintf('faraday_betaklett_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
eval(['!mogrify -trim ' out])

%----------------------
figure(2); clf
set(gcf,'position',[0,300,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[0:2:200];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz(minbin:maxbin),alfa(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(alfa(minbin:maxbin,:)),...
     [.7 .7 .7],alfa(minbin:maxbin,:)==-100)
set(gca,'YDir','normal');
set(gca,'YDir','normal');
set(gca,'yticklabel',sprintf('%.1f|',get(gca,'ytick')));
colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;
set(get(bar,'ylabel'),'String','Extinction (Mm^{-1})');

datetick('x','mm/dd')
ylabel('Altitude agl (km)')
prettify(gca,bar);
tmp=datevec(jdi);
out=sprintf('faraday_alfaklett_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
eval(['!mogrify -trim ' out])

%----------------------
disp(['total count=' num2str(size(data,2))]);
disp(['sun count=' num2str(sum(data(200,:)==-100))]);
disp(['nan count=' num2str(sum(isnan(data(200,:))))]);
disp(['ok count=' num2str(sum(data(200,:)>0))]);
%