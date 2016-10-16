%step 1 ********************************导出数据
%从天津数据库中获得的文件gz_nonring_20150607_20.txt转成Data
%Data数据说明（列）：1 行程分组按时间升序的编号（1代表起点）；
%                    2 行程分组按时间降序的编号（1代表终点）；
%                    3 去除“tid_”的行程编号
%                    4 导航用户 ID
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
%step 4 中增加      10 起点x的编号
%step 4 中增加      11 起点y的编号
%step 4 中增加      12 终点x的编号
%step 4 中增加      13 终点y的编号

Data= dlmread('gz_nonring_20150607_20.txt'); %14251144 records
Trip= [Data(1:2:end,2:end),Data(2:2:end,[5,6,7])];%7125572 records

%step 2 ********************************数据清理
Trip(Trip(:,1)<11,:)= [];   %清除采集数量少于10的行程, 3761453 records remain
Trip(Trip(:,5)<=0 | Trip(:,6)<=0 | Trip(:,8)<=0 | Trip(:,9)<=0,:)= []; %清除经纬度无效数据， 3495195 records remain
Trip(TimeCalculate(Trip(:,4),Trip(:,7))<60,:)= []; %清除导航时间小于1分钟的数据条， 3474394 records remain

%step 3 ********************************建立经纬度网格
maxx= max([Trip(:,5);Trip(:,8)])+0.01;
minx= min([Trip(:,5);Trip(:,8)])-0.01;
maxy= max([Trip(:,6);Trip(:,9)])+0.01;
miny= min([Trip(:,6);Trip(:,9)])-0.01;
zonegap= 0.5;                        % 单位为km
xgap= zonegap/85.37295;              % 设定经度间距,单位千米
ygap= zonegap/111.3193;              % 设定纬度间距单位千米
xnum= ceil((maxx-minx)/xgap);        % X方向小区的个数
ynum= ceil((maxy-miny)/ygap);        % Y方向小区的个数
[x,y]= meshgrid(minx+xgap/2:xgap:minx+xnum*xgap-xgap/2,...
    miny+ygap/2:ygap:miny+ynum*ygap-ygap/2);          %  得到各小区的中心点

%step 4 ********************************Trip中数据在X,Y的对应 增加4列
Trip(:,10)= ceil((Trip(:,5)-minx)/xgap);                   %起点横坐标编号
Trip(:,11)= ceil((Trip(:,6)-miny)/ygap);                   %起点纵坐标编号
Trip(:,12)= ceil((Trip(:,8)-minx)/xgap);                   %终点横坐标编号
Trip(:,13)= ceil((Trip(:,9)-miny)/ygap);                   %终点纵坐标编号

%step 5 ********************************生成热力图矩阵
Demand_O= zeros(ynum,xnum);
Demand_D= zeros(ynum,xnum);
for xi= 1:xnum
    for yi= 1:ynum
        xi
        yi
        Demand_O(yi,xi)= sum(Trip(:,10)==xi & Trip(:,11)==yi);
        Demand_D(yi,xi)= sum(Trip(:,12)==xi & Trip(:,13)==yi);
    end
end

%step 6 ********************************简单画出热力图
%起点热力图
figure
    surf(x,y,Demand_O,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','phong');