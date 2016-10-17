%step 1 ********************************导出数据
%从天津数据库中获得的文件gz_nonring_20150607_20.txt转成Data
%Data数据说明（列）：1 行程分组按时间升序的编号（1代表起点）；
%                    2 行程分组按时间降序的编号（1代表终点）；
%                    3 去除“tid_”的行程编号
%                    4 导航用户ID
%                    5 数据采集时间
%                    6 匹配后的经度
%                    7 匹配后的纬度
%Trip数据说明（列）：1 行程分组采集数量统计
%                    2 行程编号（全数字）
%                    3 导航用户ID
%                    4 导航起点时间
%                    5 起点经度
%                    6 起点纬度
%                    7 导航终点时间
%                    8 终点经度
%                    9 终点纬度
%step 4 中增加      10 起点x的编号（按照xy矩阵）
%step 4 中增加      11 起点y的编号（按照xy矩阵）
%step 4 中增加      12 终点x的编号（按照xy矩阵）
%step 4 中增加      13 终点y的编号（按照xy矩阵）
%step 8 中增加      14 OD矩阵行的编号（起点）（按照xy矩阵）
%step 8 中增加      15 OD矩阵列的编号（终点）（按照xy矩阵）

Data= dlmread('gz_nonring_20150607_20.txt'); %14251144 records
Trip= [Data(1:2:end,2:end),Data(2:2:end,[5,6,7])];%7125572 records

%step 2 ********************************数据清理

Trip(Trip(:,1)<11,:)= [];   %清除采集数量小于等于10的行程, 3761453 records remain
Trip(Trip(:,5)<=0 | Trip(:,6)<=0 | Trip(:,8)<=0 | Trip(:,9)<=0,:)= []; %清除经纬度无效数据， 3495195 records remain
Trip(TimeCalculate(Trip(:,4),Trip(:,7))<60,:)= []; %清除导航时间小于1分钟的数据条， 3474394 records remain



%step 3 ********************************建立经纬度网格

maxx= max([Trip(:,5);Trip(:,8)])+0.01;
minx= min([Trip(:,5);Trip(:,8)])-0.01;
maxy= max([Trip(:,6);Trip(:,9)])+0.01;
miny= min([Trip(:,6);Trip(:,9)])-0.01;
zonegap= 1;                          % 单位为km
xgap= zonegap/85.37295;              % 设定经度间距,单位千米
ygap= zonegap/111.3193;              % 设定纬度间距,单位千米
xnum= ceil((maxx-minx)/xgap);        % X方向小区的个数
ynum= ceil((maxy-miny)/ygap);        % Y方向小区的个数
[x,y]= meshgrid(minx+xgap/2:xgap:minx+xnum*xgap-xgap/2,...
    miny+ygap/2:ygap:miny+ynum*ygap-ygap/2);               %得到各小区的中心点



%step 4 ********************************Trip中数据在X,Y的对应 增加4列

Trip(:,10)= ceil((Trip(:,5)-minx)/xgap);                   %起点横坐标编号
Trip(:,11)= ceil((Trip(:,6)-miny)/ygap);                   %起点纵坐标编号
Trip(:,12)= ceil((Trip(:,8)-minx)/xgap);                   %终点横坐标编号
Trip(:,13)= ceil((Trip(:,9)-miny)/ygap);                   %终点纵坐标编号



%step 5 ********************************生成热力图矩阵

Demand_O= zeros(ynum,xnum);
Demand_D= zeros(ynum,xnum);
for nth_rec = 1:length(Trip)
	if mod(nth_rec,10000)==0
		disp(['Calcling ',num2str(nth_rec),' records!'])
	end
	Demand_O(Trip(nth_rec,10),Trip(nth_rec,11)) = Demand_O(Trip(nth_rec,10),Trip(nth_rec,11))+1;
	Demand_D(Trip(nth_rec,12),Trip(nth_rec,13)) = Demand_O(Trip(nth_rec,12),Trip(nth_rec,13))+1;
end



%step 6 ********************************简单画出热力图

%起点热力图
figure
    surf(x,y,Demand_O,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','phong');
    axis xy;
    colormap(hot)
    colorbar
    cmap= colormap;
    definedmap= flip(cmap);
    colormap(definedmap);
    caxis([0,100000]);
    view(2)
    eval(['title(''type=',num2str(3),''')'])
    
    figure
    surf(x,y,Demand_D,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','phong');



%step 7 ********************************统计分析

%导航起点和终点时间分布统计
OTime= rem(fix(Trip(:,4)/1e+4),100)+rem(fix(Trip(:,4)/1e+2),100)/60; %时间单位：小时
DTime= rem(fix(Trip(:,7)/1e+4),100)+rem(fix(Trip(:,7)/1e+2),100)/60; %时间单位：小时
edges1 = [0:24];
OTime_hist= histogram(OTime,edges1);
figure
DTime_hist= histogram(DTime,edges1);

%导航时长分布统计
ODTime= TimeCalculate(Trip(:,4),Trip(:,7))/60;           %时间单位：分钟
edges2= [0:15:max(ODTime)];
figure
ODTime_hist= histogram(ODTime,edges2);



%step 8 ********************************生成期望线图矩阵

xynum= xnum*ynum;          %将所有的小区列为一行
Trip(:,14)= ynum*(Trip(:,10)-1)+Trip(:,11);              %OD矩阵行编号
Trip(:,15)= ynum*(Trip(:,12)-1)+Trip(:,13);              %OD矩阵列编号
ODmatrix= sparse(xynum,xynum);
for i= 1:size(Trip,1)
    ODmatrix(Trip(i,14),Trip(i,15))= ODmatrix(Trip(i,14),Trip(i,15))+1;  %累加
end
Desireline= tril(ODmatrix)+tril(ODmatrix')-diag(diag(ODmatrix));
[select_row,select_col]= find(Desireline>10);            %选择所画的期望线的数值范围
maxOD= max(max(Desireline));                             %找出期望线的最大值
figure                          
for n=1:length(select_row)         
    %将行和列改成xy矩阵中的位置
    ox=ceil(select_row(n)/ynum);
    oy=select_row(n)-(ox-1)*ynum;
    dx=ceil(select_col(n)/ynum);
    dy=select_col(n)-(dx-1)*ynum;
    hold on
    plot([x(1,ox),x(1,dx)],[y(oy,1),y(dy,1)],'LineWidth',20*Desireline(select_row(n),select_col(n))/maxOD); 
end







    


















