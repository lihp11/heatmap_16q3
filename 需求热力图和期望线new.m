%%%%%%%%%%%%%%%%%%%%%��������
TripOD=dlmread('TripOD_04.txt');%13229614���г�
%����г̾��룬��һ���������ݣ����������100km���г̣�
noreason1=find(TripOD(:,9)>100);%15791����¼
TripOD(noreason1,:)=[];%13213823����¼
%�����С��0.5km�ļ�¼
noreason2=find(TripOD(:,9)<0.5);%83202����¼
TripOD(noreason2,:)=[];%ʣ13130621����¼
%ѡ��ʱ���
nowork1=find(TripOD(:,3)>=20150404000000 ...
    &TripOD(:,3)<20150407000000);%��������1012545����¼
nowork2=find(TripOD(:,3)>=20150411000000 ...
    &TripOD(:,3)<20150413000000);%��ĩ765789����¼
nowork3=find(TripOD(:,3)>=20150418000000 ...
    &TripOD(:,3)<20150420000000);%��ĩ783450����¼
nowork4=find(TripOD(:,3)>=20150425000000 ...
    &TripOD(:,3)<20150427000000);%��ĩ800833����¼
work1=find(TripOD(:,3)>=20150401000000 ...
    &TripOD(:,3)<20150404000000);%3�칤����1354363����¼
work2=find(TripOD(:,3)>=20150407000000 ...
    &TripOD(:,3)<20150411000000);%4��������1821598����¼
work3=find(TripOD(:,3)>=20150413000000 ...
    &TripOD(:,3)<20150418000000);%5��������2319125����¼
work4=find(TripOD(:,3)>=20150420000000 ...
    &TripOD(:,3)<20150425000000);%5��������2390584����¼
work5=find(TripOD(:,3)>=20150427000000 ...
    &TripOD(:,3)<20150500000000);%4��������1882342����¼
nowork=[nowork1;nowork2;nowork3;nowork4];
work=[work1;work2;work3;work4;work5];
%������
travelod_wk=[];
travelod_wk=TripOD([work1;work2;work3;work4;work5],[4,5,7,8,3,6]);
travelnode_wk=[travelod_wk(:,1:2);travelod_wk(:,(3:4))];
%%%%%%%%%%%%%%%%%%%%%%%%%%%������γ������
maxlongitude=max(travelnode_wk(:,1));
minlongitude=min(travelnode_wk(:,1));
maxlatitude=max(travelnode_wk(:,2));
minlatitude=min(travelnode_wk(:,2));
M,N]=size(travelnode_wk);
maxy=maxlatitude+0.01;
miny=minlatitude-0.01;
maxx=maxlongitude+0.01;
minx=minlongitude-0.01;
zonegap=1; %��λΪkm
longitudegap=zonegap/85.37295;    %�趨���ȼ��,��λǧ��
latitudegap=zonegap/111.3193;        %�趨γ�ȼ�࣬��λǧ��
xnumber=ceil((maxx-minx)/longitudegap);
ynumber=ceil((maxy-miny)/latitudegap);
[x3,y3]=meshgrid(minx+longitudegap/2:longitudegap:minx+xnumber*longitudegap-longitudegap/2,...
    miny+latitudegap/2:latitudegap:miny+ynumber*latitudegap-latitudegap/2);%������������ͼ�е�һ��������ٰ��
z3=ones(size(x3,1),size(x3,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%׼��travelodtime����
travelodtime(:,1:6)=travelod_wk(:,[1,2,5,3,4,6]);
travelodtime(:,[3,6])=fix(rem(travelodtime(:,[3,6]),1e+6)/100);            %��ʱ���ʽ��20141001193521�ĳ�ʱ��ʽ1935
%travelodtime������еİ��ţ�1 O_longtitude  2 O_latitude  3 O_time  4 D_longtitude
%5 D_latitude  6 D_time ��ʽΪ2359����ʾ23��59�� 7 O_longtidudenum  8 O_latitudenum  9 O_timenum
%10 D_longtitudenum  11 D_latitudenum  12 D_timenum  13 O_rownum  14
%D_columnnum
maxtime=2359;  %�趨���ʱ���Ϊ23��59��
mintime=1;     %�趨��Сʱ���Ϊ00��01��
maxz=maxtime+1;
minz=mintime-1;
maxz_c=fix(maxz/100)*60+rem(maxz,100); %ת��ʱ���ʽΪ����
minz_c=fix(minz/100)*60+rem(minz,100); %ת��ʱ���ʽΪ����
timegap=60;    %�趨ʱ����Ϊ60����
znumber=ceil((maxz_c-minz_c)/timegap);
travelodtime(:,7)=ceil((travelodtime(:,1)-minx)/longitudegap);                   %travelodtime �� 7 ����������
travelodtime(:,8)=ceil((travelodtime(:,2)-miny)/latitudegap);                    %travelodtime �� 8 �����������
travelodtime(:,9)=ceil(((fix(travelodtime(:,3)/100)*60+rem(travelodtime(:,3),100))-minz_c)/timegap);           %travelodtime �� 9 ���Z����
travelodtime(travelodtime(:,9)==0,9)=1;
travelodtime(:,10)=ceil((travelodtime(:,4)-minx)/longitudegap);                  %travelodtime ��10 �յ��������
travelodtime(:,11)=ceil((travelodtime(:,5)-miny)/latitudegap);                   %travelodtime ��11 �յ���������
travelodtime(:,12)=ceil(((fix(travelodtime(:,6)/100)*60+rem(travelodtime(:,6),100))-minz_c)/timegap);          %travelodtime ��12 �յ�Z����
travelodtime(travelodtime(:,12)==0,12)=1;
travelodtime(:,13)=ynumber*(travelodtime(:,7)-1)+travelodtime(:,8)+(travelodtime(:,9)-1)*xnumber*ynumber;                %travelodtime �� 13 �������ά�����ߣ�OD�������ж�Ӧ���е�λ��
travelodtime(:,14)=ynumber*(travelodtime(:,10)-1)+travelodtime(:,11)+(travelodtime(:,12)-1)*xnumber*ynumber;             %travelodtime ��14 �յ�����ά�����ߣ�OD�������ж�Ӧ���е�λ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����odddemand˼ά����
%Ҫ��trvalodtime���ҵ�ÿ��O���D�����oddemand�����еĶ�Ӧ��ϵ
%��ÿ��ʱ����ڵ�demand�ֲ������ͼ�㣩����travelodtime������ά����oddemad(x,y,z,type),type=1��ʾO+D,type=2��ʾO
%type=3��ʾD
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
%���oddemand��ά����


%%%%%%%%%%%%%%%%%%%%%%%%%����ͼ
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
%����type=1�������ȵ�ͼ
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

    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�������ߣ����������߾���desireline_two demension
ds=xnumber*ynumber;
desireline=zeros(ds,ds);
travelod_wk(:,7)=ceil((travelod_wk(:,1)-minx)/longitudegap);                   %travelod �� 7 ��������
travelod_wk(:,8)=ceil((travelod_wk(:,2)-miny)/latitudegap);                    %travelod �� 8 ���������
travelod_wk(:,9)=ceil((travelod_wk(:,3)-minx)/longitudegap);                   %travelod �� 9 �յ������
travelod_wk(:,10)=ceil((travelod_wk(:,4)-miny)/latitudegap);                    %travelod �� 10 �յ������
travelod_wk(:,11)=ynumber*(travelod_wk(:,7)-1)+travelod_wk(:,8);                     %travelod �� 11 ����ڶ�ά�����ߣ�OD�������ж�Ӧ���е�λ��
travelod_wk(:,12)=ynumber*(travelod_wk(:,9)-1)+travelod_wk(:,10);                    %travelod ��12 �յ��ڶ�ά�����ߣ�OD�������ж�Ӧ���е�λ��
for i=1:size(travelod_wk,1)
    desireline(travelod_wk(i,11),travelod_wk(i,12))=desireline(travelod_wk(i,11),travelod_wk(i,12))+1;  %�������ߣ�OD��������д����Ӧ��ֵ
end
noindex=find(desireline>10);  %ѡ�������������ߵ���ֵ��Χ
maxdesireline=max(max(desireline)); %�ҳ������ߵ����ֵ���ڻ������ߴ�ϸ��ʱ����õ�
figure                          %��������ͼ
surf(x3,y3,z3*0,C_all,'FaceColor','interp',...
        'EdgeColor','none',...
        'FaceLighting','phong');
    
colormap(definedmap);
colorbar
caxis([100,100000]);


hold on   %��Ӷ�ά����
for j=1:length(noindex)         %���ڶ�ά����
    i=noindex(j);
    hang_desire=i-fix(i/ds)*ds;%��Ϊ���
    lie_desire=ceil(i/ds);    %��Ϊ�յ�
    %���к��иĳ�image�����е�λ��
    ox=ceil(hang_desire/ynumber);
    oy=hang_desire-(ox-1)*ynumber;
    dx=ceil(lie_desire/ynumber);
    dy=lie_desire-(dx-1)*ynumber;
    hold on
plot3([x3(1,ox),x3(1,dx)],[y3(oy,1),y3(dy,1)],[0,0],'LineWidth',20*desireline(i)/maxdesireline); 
end
view(2)


















