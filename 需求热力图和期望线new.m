%%%%%%%%%%%%%%%%%%%%%导出数据
TripOD=dlmread('TripOD_04.txt');%13229614个行程
%检查行程距离，进一步清晰数据（清理掉大于100km的行程）
noreason1=find(TripOD(:,9)>100);%15791条记录
TripOD(noreason1,:)=[];%13213823条记录
%清理掉小于0.5km的记录
noreason2=find(TripOD(:,9)<0.5);%83202条记录
TripOD(noreason2,:)=[];%剩13130621条记录
%选择时间段
nowork1=find(TripOD(:,3)>=20150404000000 ...
    &TripOD(:,3)<20150407000000);%清明假期1012545条记录
nowork2=find(TripOD(:,3)>=20150411000000 ...
    &TripOD(:,3)<20150413000000);%周末765789条记录
nowork3=find(TripOD(:,3)>=20150418000000 ...
    &TripOD(:,3)<20150420000000);%周末783450条记录
nowork4=find(TripOD(:,3)>=20150425000000 ...
    &TripOD(:,3)<20150427000000);%周末800833条记录
work1=find(TripOD(:,3)>=20150401000000 ...
    &TripOD(:,3)<20150404000000);%3天工作日1354363条记录
work2=find(TripOD(:,3)>=20150407000000 ...
    &TripOD(:,3)<20150411000000);%4个工作日1821598条记录
work3=find(TripOD(:,3)>=20150413000000 ...
    &TripOD(:,3)<20150418000000);%5个工作日2319125条记录
work4=find(TripOD(:,3)>=20150420000000 ...
    &TripOD(:,3)<20150425000000);%5个工作日2390584条记录
work5=find(TripOD(:,3)>=20150427000000 ...
    &TripOD(:,3)<20150500000000);%4个工作日1882342条记录
nowork=[nowork1;nowork2;nowork3;nowork4];
work=[work1;work2;work3;work4;work5];
%工作日
travelod_wk=[];
travelod_wk=TripOD([work1;work2;work3;work4;work5],[4,5,7,8,3,6]);
travelnode_wk=[travelod_wk(:,1:2);travelod_wk(:,(3:4))];
%%%%%%%%%%%%%%%%%%%%%%%%%%%建立经纬度网格
maxlongitude=max(travelnode_wk(:,1));
minlongitude=min(travelnode_wk(:,1));
maxlatitude=max(travelnode_wk(:,2));
minlatitude=min(travelnode_wk(:,2));
M,N]=size(travelnode_wk);
maxy=maxlatitude+0.01;
miny=minlatitude-0.01;
maxx=maxlongitude+0.01;
minx=minlongitude-0.01;
zonegap=1; %单位为km
longitudegap=zonegap/85.37295;    %设定经度间距,单位千米
latitudegap=zonegap/111.3193;        %设定纬度间距，单位千米
xnumber=ceil((maxx-minx)/longitudegap);
ynumber=ceil((maxy-miny)/latitudegap);
[x3,y3]=meshgrid(minx+longitudegap/2:longitudegap:minx+xnumber*longitudegap-longitudegap/2,...
    miny+latitudegap/2:latitudegap:miny+ynumber*latitudegap-latitudegap/2);%这样画出来的图中第一个矩阵块少半块
z3=ones(size(x3,1),size(x3,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%准备travelodtime矩阵
travelodtime(:,1:6)=travelod_wk(:,[1,2,5,3,4,6]);
travelodtime(:,[3,6])=fix(rem(travelodtime(:,[3,6]),1e+6)/100);            %将时间格式由20141001193521改成时分式1935
%travelodtime矩阵的列的安排：1 O_longtitude  2 O_latitude  3 O_time  4 D_longtitude
%5 D_latitude  6 D_time 格式为2359，表示23点59分 7 O_longtidudenum  8 O_latitudenum  9 O_timenum
%10 D_longtitudenum  11 D_latitudenum  12 D_timenum  13 O_rownum  14
%D_columnnum
maxtime=2359;  %设定最大时间点为23点59分
mintime=1;     %设定最小时间点为00点01分
maxz=maxtime+1;
minz=mintime-1;
maxz_c=fix(maxz/100)*60+rem(maxz,100); %转化时间格式为分钟
minz_c=fix(minz/100)*60+rem(minz,100); %转化时间格式为分钟
timegap=60;    %设定时间间隔为60分钟
znumber=ceil((maxz_c-minz_c)/timegap);
travelodtime(:,7)=ceil((travelodtime(:,1)-minx)/longitudegap);                   %travelodtime 中 7 起点横坐标编号
travelodtime(:,8)=ceil((travelodtime(:,2)-miny)/latitudegap);                    %travelodtime 中 8 起点纵坐标编号
travelodtime(:,9)=ceil(((fix(travelodtime(:,3)/100)*60+rem(travelodtime(:,3),100))-minz_c)/timegap);           %travelodtime 中 9 起点Z坐标
travelodtime(travelodtime(:,9)==0,9)=1;
travelodtime(:,10)=ceil((travelodtime(:,4)-minx)/longitudegap);                  %travelodtime 中10 终点横坐标编号
travelodtime(:,11)=ceil((travelodtime(:,5)-miny)/latitudegap);                   %travelodtime 中11 终点纵坐标编号
travelodtime(:,12)=ceil(((fix(travelodtime(:,6)/100)*60+rem(travelodtime(:,6),100))-minz_c)/timegap);          %travelodtime 中12 终点Z坐标
travelodtime(travelodtime(:,12)==0,12)=1;
travelodtime(:,13)=ynumber*(travelodtime(:,7)-1)+travelodtime(:,8)+(travelodtime(:,9)-1)*xnumber*ynumber;                %travelodtime 中 13 起点在三维期望线（OD）矩阵中对应的行的位置
travelodtime(:,14)=ynumber*(travelodtime(:,10)-1)+travelodtime(:,11)+(travelodtime(:,12)-1)*xnumber*ynumber;             %travelodtime 中14 终点在三维期望线（OD）矩阵中对应的列的位置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%建立odddemand思维矩阵
%要在trvalodtime中找到每个O点和D点的在oddemand矩阵中的对应关系
%画每个时间段内的demand分布情况（图层）依据travelodtime导出四维矩阵oddemad(x,y,z,type),type=1表示O+D,type=2表示O
%type=3表示D
oddemand=zeros(xnumber,ynumber,znumber,3);
numod=size(travelodtime,1);
for i=1:numod
    oxi=travelodtime(i,7);
    oyi=travelodtime(i,8);
    ozi=travelodtime(i,9);
    if ozi==0
        ozi=1;
    end
    dxi=travelodtime(i,10);
    dyi=travelodtime(i,11);
    dzi=travelodtime(i,12);
    if dzi==0
        dzi=1;
    end    
    oddemand(oxi,oyi,ozi,2)=oddemand(oxi,oyi,ozi,2)+1;
    oddemand(dxi,dyi,dzi,3)=oddemand(dxi,dyi,dzi,3)+1;
end
for i=1:znumber
    oddemand(:,:,i,1)=oddemand(:,:,i,2)+oddemand(:,:,i,3);
end
%完成oddemand四维矩阵


%%%%%%%%%%%%%%%%%%%%%%%%%热力图
type=1;
C1_all=zeros(size(x3,1),size(x3,2));
for  i=1:znumber
    C1_all=C1_all+oddemand(:,:,i,type)';
end
type=2;
C2_all=zeros(size(x3,1),size(x3,2));
for  i=1:znumber
    C2_all=C2_all+oddemand(:,:,i,type)';
end
type=3;
C3_all=zeros(size(x3,1),size(x3,2));
for  i=1:znumber
    C3_all=C3_all+oddemand(:,:,i,type)';
end
%画出type=1的需求热点图
CC=C1_all;
figure
    surf(x3,y3,z3*0,CC,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','phong');
    axis xy;
    colormap(hot)
    colorbar
    cmap=colormap;
    definedmap=flip(cmap);
    colormap(definedmap);
    caxis([0,100000]);
    view(2)
    eval(['title(''type=',num2str(3),''')'])

    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%画期望线，建立期望线矩阵desireline_two demension
ds=xnumber*ynumber;
desireline=zeros(ds,ds);
travelod_wk(:,7)=ceil((travelod_wk(:,1)-minx)/longitudegap);                   %travelod 中 7 起点横坐标
travelod_wk(:,8)=ceil((travelod_wk(:,2)-miny)/latitudegap);                    %travelod 中 8 起点纵坐标
travelod_wk(:,9)=ceil((travelod_wk(:,3)-minx)/longitudegap);                   %travelod 中 9 终点横坐标
travelod_wk(:,10)=ceil((travelod_wk(:,4)-miny)/latitudegap);                    %travelod 中 10 终点横坐标
travelod_wk(:,11)=ynumber*(travelod_wk(:,7)-1)+travelod_wk(:,8);                     %travelod 中 11 起点在二维期望线（OD）矩阵中对应的行的位置
travelod_wk(:,12)=ynumber*(travelod_wk(:,9)-1)+travelod_wk(:,10);                    %travelod 中12 终点在二维期望线（OD）矩阵中对应的列的位置
for i=1:size(travelod_wk,1)
    desireline(travelod_wk(i,11),travelod_wk(i,12))=desireline(travelod_wk(i,11),travelod_wk(i,12))+1;  %在期望线（OD）矩阵中写入相应的值
end
noindex=find(desireline>10);  %选择所画的期望线的数值范围
maxdesireline=max(max(desireline)); %找出期望线的最大值，在画期望线粗细的时候会用到
figure                          %画出热力图
surf(x3,y3,z3*0,C_all,'FaceColor','interp',...
        'EdgeColor','none',...
        'FaceLighting','phong');
    
colormap(definedmap);
colorbar
caxis([100,100000]);


hold on   %添加二维望线
for j=1:length(noindex)         %画期二维望线
    i=noindex(j);
    hang_desire=i-fix(i/ds)*ds;%行为起点
    lie_desire=ceil(i/ds);    %列为终点
    %将行和列改成image矩阵中的位置
    ox=ceil(hang_desire/ynumber);
    oy=hang_desire-(ox-1)*ynumber;
    dx=ceil(lie_desire/ynumber);
    dy=lie_desire-(dx-1)*ynumber;
    hold on
plot3([x3(1,ox),x3(1,dx)],[y3(oy,1),y3(dy,1)],[0,0],'LineWidth',20*desireline(i)/maxdesireline); 
end
view(2)


















