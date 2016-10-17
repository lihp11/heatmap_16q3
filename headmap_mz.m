%% export data

Data= dlmread('gz_nonring_20150607_20.txt');
	 % array:(pure od data) rnum=many,c1=nth timestamp from start (1 for origin)
	 % c2=nth timestamp from end (1 for destin),c3=trajectory_id,c4=user_id
	 %c5=time(eg 201501010930),c6=long,c7=lat
Trip= [Data(1:2:end,2:end),Data(2:2:end,[5,6,7])];%7125572 records
	% array:rnum=num of trips,c1=num of gps point in for one trip
	% c2=trajectory_id,c3= user_id,c4=start_time(eg YYYYMMDDHHMMSS),c5=start long
	% c6=start lat,c7=end_time(eg 201501010930),c8=end long,c9=end lat

%% del error data

Trip(Trip(:,1)<11,:)= [];
Trip(Trip(:,5)<=0 | Trip(:,6)<=0 | Trip(:,8)<=0 | Trip(:,9)<=0,:)= [];
Trip(TimeCalculate(Trip(:,4),Trip(:,7))<60,:)= [];

%% setup mesh grid
clc,clear,close all
load('od_rawdata');

% change here!!!
zonegap= 0.5;        % single = cube length(km)
red_alert = 1000;     % single = color upper limit(all num of cars exceeding it will be treated the same)

maxx= max([Trip(:,5);Trip(:,8)])+0.01;	%single = max long in total data
minx= min([Trip(:,5);Trip(:,8)])-0.01;	%single = min long in total data
maxy= max([Trip(:,6);Trip(:,9)])+0.01;	%single = max lat in total data
miny= min([Trip(:,6);Trip(:,9)])-0.01;	%single = min lat in total data
xgap= zonegap/85.37295;              % single = long gap for cubelength
ygap= zonegap/111.3193;              % single = lat gap for cubelength
xnum= ceil((maxx-minx)/xgap);        % single = num of cubes in x
ynum= ceil((maxy-miny)/ygap);        % single = num of cubes in y
[x,y]= meshgrid(minx+xgap/2:xgap:minx+xnum*xgap-xgap/2,miny+ygap/2:ygap:miny+ynum*ygap-ygap/2);
	% x or y:array,rnum=cubes in x,cnum=cube in y,content=long or lat

%% calc od data's cube index
Trip(:,10)= ceil((Trip(:,5)-minx)/xgap);
Trip(:,11)= ceil((Trip(:,6)-miny)/ygap);
Trip(:,12)= ceil((Trip(:,8)-minx)/xgap);
Trip(:,13)= ceil((Trip(:,9)-miny)/ygap);
	% array:rnum=num of trips,c1=num of gps point in for one trip
	% c2=trajectory_id,c3= user_id,c4=start_time(eg 201501010930),c5=start long
	% c6=start lat,c7=end_time(eg 201501010930),c8=end long,c9=end lat
	% c10=x_index of startcube,c11=y_index of startcube
	% c12=x_index of endcube,c13=y_index of endcube

%% calc od matrix

clear('Demand_O','Demand_D');
Demand_O= zeros(ynum,xnum);
Demand_D= zeros(ynum,xnum);

for nth_rec = 1:length(Trip)
	if mod(nth_rec,10000)==0
		disp(['Calcling ',num2str(nth_rec),' Trips!'])
	end
	Demand_O(Trip(nth_rec,10),Trip(nth_rec,11)) = Demand_O(Trip(nth_rec,10),Trip(nth_rec,11))+1;
	% array:rnum= num of cubes in x,cnum=num of cubes in y,content=num of origin point at this cube
	Demand_D(Trip(nth_rec,12),Trip(nth_rec,13)) = Demand_D(Trip(nth_rec,12),Trip(nth_rec,13))+1;
	% array:rnum= num of cubes in x,cnum=num of cubes in y,content=num of destin point at this cube
end

%% plot heatmap
figure
    surf(x,y,Demand_O,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
colormap('parula')

index_rowstart = ceil(600/1804*size(Demand_O,1));
	% single = index of beijing x starting for Demand mat
index_rowend = ceil(1000/1804*size(Demand_O,1));
	% single = index of beijing x ending for Demand mat
index_colstart = ceil(400/1793*size(Demand_O,2));
	% single = index of beijing y starting for Demand mat
index_colend = ceil(700/1793*size(Demand_O,2));
	% single = index of beijing y ending for Demand mat

close all;
figure('Name','origin_headtmap');
imagesc(Demand_O(index_rowstart:index_rowend,index_colstart:index_colend));
colormap('jet');
caxis([0,red_alert])
colorbar;
figure('Name','dest_headtmap');
imagesc(Demand_D(index_rowstart:index_rowend,index_colstart:index_colend));
colormap('jet');
caxis([0,red_alert])
colorbar;

%% gps od time statistic
otime= rem(fix(Trip(:,4)/1e+4),100)+rem(fix(Trip(:,4)/1e+2),100)/60;
	% vector:num=num of trips,content=start_hours in a day 
dtime= rem(fix(Trip(:,7)/1e+4),100)+rem(fix(Trip(:,7)/1e+2),100)/60;
	% vector:num=num of trips,content=end_hours in a day 

figure('name','otime_distribution')
histogram(otime,0.5:23.5,'FaceColor',[0,0.5,0.5])
title('otime_distribution','fontname','等线','fontsize',15,'fontweight','bold','interpreter','none')
set(gca,'xlim',[0,24],'xtick',0:24)
xlabel('hour of day','fontname','等线','fontsize',12,'fontweight','bold')
ylabel('counts','fontname','等线','fontsize',12,'fontweight','bold')

figure('name','dtime_distribution')
histogram(dtime,0.5:23.5,'FaceColor',[0,0.5,0.5])
title('dtime_distribution','fontname','等线','fontsize',15,'fontweight','bold','interpreter','none')
set(gca,'xlim',[0,24],'xtick',0:24)
xlabel('hour of day','fontname','等线','fontsize',12,'fontweight','bold')
ylabel('counts','fontname','等线','fontsize',12,'fontweight','bold')

%% gps continue time statistic
continue_time = (dtime-otime)*60;
figure('name','continue_time_distribution')
histogram(continue_time,0:10:200,'FaceColor',[0,0.5,0.5])
title('continue_time_distribution','fontname','等线','fontsize',15,'fontweight','bold','interpreter','none')
set(gca,'xlim',[0,200])
xlabel('trip time(min)','fontname','等线','fontsize',12,'fontweight','bold')
ylabel('counts','fontname','等线','fontsize',12,'fontweight','bold')


%% get desireline graph
num_cube = xnum*ynum;	% single=num of total cubes
x_center = minx+xgap/2:xgap:minx+xnum*xgap-xgap/2;
y_center = miny+ygap/2:ygap:miny+ynum*ygap-ygap/2;
% up2:vector:num=num of cubes in x or y,content=long or lat
od_table = sparse(num_cube,num_cube);
% array:rnum=cnum=num of total cubes,content=num of traffic

nth_ocube = ynum*(Trip(:,10)-1)+Trip(:,11);
nth_dcube = ynum*(Trip(:,12)-1)+Trip(:,13);
% up2:vector:num=num of total cubes,content=long or lat

% array:rnum=cnum=num_cube

for nth_trip = 1:length(Trip)
	if mod(nth_trip,10000)==0
		disp(['Calcling ',num2str(nth_trip),' Trips!'])
	end
	od_table(nth_ocube(nth_trip),nth_dcube(nth_trip)) = od_table(nth_ocube(nth_trip),nth_dcube(nth_trip))+1;
end

od_total = tril(od_table)+tril(od_table')-diag(diag(od_table));
% array:rnum=cnum=num of total cubes,content=num of interact traffic
[od_row,od_col] = find(od_total>100);
% od_row:vector,num=row index (nth_cube) satisfy interact traffic>100
% od_col:vector,num=col index (nth_cube) satisfy interact traffic>100
od_max = max(max(od_total));	%single = max od

figure('Name','desireline');
for nth_line = 1:length(od_row)
	if mod(nth_line,1000)==0
		disp(['Calcling ',num2str(nth_line),' Trips!'])
	end
	nth_start_xcube = ceil(od_row(nth_line)/ynum);
	% single = nth cube in x for the start point
	nth_start_ycube = mod(od_row(nth_line),ynum);
	nth_end_xcube = ceil(od_col(nth_line)/ynum);
	nth_end_ycube = mod(od_col(nth_line),ynum);

	plot([x_center(nth_start_xcube),x_center(nth_end_xcube)],...
		 [y_center(nth_start_ycube),y_center(nth_end_ycube)],...
		 'linewidth',20*od_total(od_row(nth_line),od_col(nth_line))/od_max,...
         'color','r');
	hold on;
end
axis equal;
title('desireline','fontname','等线','fontsize',15,'fontweight','bold','interpreter','none')
xlabel('longtitude','fontname','等线','fontsize',12,'fontweight','bold')
ylabel('latitude','fontname','等线','fontsize',12,'fontweight','bold')


