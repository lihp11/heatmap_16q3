%step 1 ********************************��������
%��������ݿ��л�õ��ļ�gz_nonring_20150607_20.txtת��Data
%Data����˵�����У���1 �г̷��鰴ʱ������ı�ţ�1������㣩��
%                    2 �г̷��鰴ʱ�併��ı�ţ�1�����յ㣩��
%                    3 ȥ����tid_�����г̱��
%                    4 �����û� ID
%                    5 ���ݲɼ�ʱ��
%                    6 ƥ���ľ���
%                    7 ƥ����γ��
%Trip����˵�����У���1 �г̷���ɼ�����ͳ��
%                    2 �г̱�ţ�ȫ���֣�
%                    3 �����û�ID
%                    4 �������ʱ��
%                    5 ��㾭��
%                    6 ���γ��
%                    7 �����յ�ʱ��
%                    8 �յ㾭��
%                    9 �յ�γ��
%step 4 ������      10 ���x�ı��
%step 4 ������      11 ���y�ı��
%step 4 ������      12 �յ�x�ı��
%step 4 ������      13 �յ�y�ı��

Data= dlmread('gz_nonring_20150607_20.txt'); %14251144 records
Trip= [Data(1:2:end,2:end),Data(2:2:end,[5,6,7])];%7125572 records

%step 2 ********************************��������
Trip(Trip(:,1)<11,:)= [];   %����ɼ���������10���г�, 3761453 records remain
Trip(Trip(:,5)<=0 | Trip(:,6)<=0 | Trip(:,8)<=0 | Trip(:,9)<=0,:)= []; %�����γ����Ч���ݣ� 3495195 records remain
Trip(TimeCalculate(Trip(:,4),Trip(:,7))<60,:)= []; %�������ʱ��С��1���ӵ��������� 3474394 records remain

%step 3 ********************************������γ������
maxx= max([Trip(:,5);Trip(:,8)])+0.01;
minx= min([Trip(:,5);Trip(:,8)])-0.01;
maxy= max([Trip(:,6);Trip(:,9)])+0.01;
miny= min([Trip(:,6);Trip(:,9)])-0.01;
zonegap= 0.5;                        % ��λΪkm
xgap= zonegap/85.37295;              % �趨���ȼ��,��λǧ��
ygap= zonegap/111.3193;              % �趨γ�ȼ�൥λǧ��
xnum= ceil((maxx-minx)/xgap);        % X����С���ĸ���
ynum= ceil((maxy-miny)/ygap);        % Y����С���ĸ���
[x,y]= meshgrid(minx+xgap/2:xgap:minx+xnum*xgap-xgap/2,...
    miny+ygap/2:ygap:miny+ynum*ygap-ygap/2);          %  �õ���С�������ĵ�

%step 4 ********************************Trip��������X,Y�Ķ�Ӧ ����4��
Trip(:,10)= ceil((Trip(:,5)-minx)/xgap);                   %����������
Trip(:,11)= ceil((Trip(:,6)-miny)/ygap);                   %�����������
Trip(:,12)= ceil((Trip(:,8)-minx)/xgap);                   %�յ��������
Trip(:,13)= ceil((Trip(:,9)-miny)/ygap);                   %�յ���������

%step 5 ********************************��������ͼ����
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

%step 6 ********************************�򵥻�������ͼ
%�������ͼ
figure
    surf(x,y,Demand_O,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','phong');