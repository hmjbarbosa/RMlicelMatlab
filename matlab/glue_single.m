function [glued a b] = glue_single(anSignal, anChannel, pcSignal, pcChannel, toplot)

N=ndims(anSignal);
a=nan;
b=nan;
if (N>1)
  [nx ny] = size(anSignal);
  if (ny>1 || N>2)
    error('Only 1-dim to glue!')
  end
end

% Length of data
n=anChannel.ndata;
idx=1:n;

% Resolution (mV) of analog channel)
%resol=anChannel.discr/2^anChannel.bits;
resol=anChannel.discr*1000/2^anChannel.bits;
if exist('toplot','var')
  disp(['resol= ' num2str(resol)]);
end

% Exclude BG region, even if user did not removed it before
bg_an=mean(anSignal(n-500:n));
std_an=std(anSignal(n-500:n));
if (isnan(bg_an)||isnan(std_an))
  bg_an=0; std_an=0;
end
bg_pc=mean(pcSignal(n-500:n));
std_pc=std(pcSignal(n-500:n));
if (isnan(bg_pc)||isnan(std_pc))
  bg_pc=0; std_pc=0;
end
if exist('toplot','var')
  disp(['bg_an=' num2str(bg_an) '  bg_pc=' num2str(bg_pc)]);
  disp(['std_an=' num2str(std_an) '  std_pc=' num2str(std_pc)]);
end

%if (bg_pc+3*std_pc > 10.)
%  glued=anSignal;
%  if exist('toplot','var')
%    disp(['error #0']);
%  end  
%  return
%end

% Create a mask for the region where analog and PC are thought to be
% proportional: below 7MHZ and above 5*resolution
mask=(anSignal>5*resol) & (anSignal>bg_an+5*std_an) & (anSignal~=NaN) & ...
     (pcSignal<45.)     & (pcSignal>bg_pc+5*std_pc) & (pcSignal~=NaN) & ...
     (pcSignal>0.1);

% limits of fit region. result of min() or max() is an array with the
% corresponding values for each column
idxmin=min(idx(mask));
idxmax=max(idx(mask));
if exist('toplot','var')
  {idxmin idxmax idxmax-idxmin}
end

% check if there was something different from NaN
% in this case, the size of max/min vectors should be larger than one
if ~(numel(idxmin) & numel(idxmax))
  if exist('toplot','var')
    disp(['error #1']);
  end  
  glued(1:n)=NaN;
  return;
end
% take only a continuous mask, with no 0s in between
for i=floor((idxmin+idxmax)/2):idxmax
  if mask(i)==0
    mask(i:idxmax)=0;
    idxmax=i-1;
    break;
  end
end
% check if there are enough points
if (idxmax-idxmin<10 || sum(mask)<10)
  glued(1:n)=NaN;
  if exist('toplot','var')
    disp(['error #2']);
  end  
  return;
end

% Do a linear fit between both channels
if exist('toplot','var')
  [cfun]=fit(anSignal(mask),pcSignal(mask),'poly1');
end
[a, b]=fastfit(anSignal(mask),pcSignal(mask));

% glue vectors
%ig=floor((idxmax+idxmin)/2);
ig=idxmin;
% glued(1:ig)=cfun(anSignal(1:ig));
glued(1:ig)=bsxfun(@plus, bsxfun(@times,anSignal(1:ig),a), b);
glued(ig+1:n)=pcSignal(ig+1:n);
glued=glued';

% Plot glue function 
if exist('toplot','var')
%  figure(1); clf; grid on;
%  h=hist(anSignal); set(h,'linecolor','r'); hold on;
%  h=hist(pcSignal); set(h,'linecolor','b'); 

  figure(2); clf
  plot(cfun,'m',anSignal(mask), pcSignal(mask),'o');
  title('Linear fit for glueing');
  xlabel('anSignal (mV)');
  ylabel('pcSignal (MHz)');
  grid on;
  cfun

  % Plot glued and PC
  figure(3)
  semilogy(idx,pcSignal,'r');
  hold on;
  semilogy(idx,glued,'b');
  semilogy(idx(mask),pcSignal(mask),'g');
  semilogy(idx,anSignal,'m');
  legend('Uncorrected PC','Scaled Analog','fit region','analog');
  xlabel('#bins');
  ylabel('PC (MHz)');
  hold off;
  pause;
end

%