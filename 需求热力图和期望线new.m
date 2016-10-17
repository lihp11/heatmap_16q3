%step 1 ********************************��������
%��������ݿ��л�õ��ļ�gz_nonring_20150607_20.txtת��Data
%Data����˵�����У���1 �г̷��鰴ʱ������ı�ţ�1������㣩��
%                    2 �г̷��鰴ʱ�併��ı�ţ�1�����յ㣩��
%                    3 ȥ����tid_�����г̱��
%                    4 �����û�ID
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
%step 4 ������      10 ���x�ı�ţ�����xy����
%step 4 ������      11 ���y�ı�ţ�����xy����
%step 4 ������      12 �յ�x�ı�ţ�����xy����
%step 4 ������      13 �յ�y�ı�ţ�����xy����
%step 8 ������      14 OD�����еı�ţ���㣩������xy����
%step 8 ������      15 OD�����еı�ţ��յ㣩������xy����

Data= dlmread('gz_nonring_20150607_20.txt'); %14251144 records
Trip= [Data(1:2:end,2:end),Data(2:2:end,[5,6,7])];%7125572 records

%step 2 ********************************��������

Trip(Trip(:,1)<11,:)= [];   %����ɼ�����С�ڵ���10���г�, 3761453 records remain
Trip(Trip(:,5)<=0 | Trip(:,6)<=0 | Trip(:,8)<=0 | Trip(:,9)<=0,:)= []; %�����γ����Ч���ݣ� 3495195 records remain
Trip(TimeCalculate(Trip(:,4),Trip(:,7))<60,:)= []; %�������ʱ��С��1���ӵ��������� 3474394 records remain



%step 3 ********************************������γ������

maxx= max([Trip(:,5);Trip(:,8)])+0.01;
minx= min([Trip(:,5);Trip(:,8)])-0.01;
maxy= max([Trip(:,6);Trip(:,9)])+0.01;
miny= min([Trip(:,6);Trip(:,9)])-0.01;
zonegap= 1;                          % ��λΪkm
xgap= zonegap/85.37295;              % �趨���ȼ��,��λǧ��
ygap= zonegap/111.3193;              % �趨γ�ȼ��,��λǧ��
xnum= ceil((maxx-minx)/xgap);        % X����С���ĸ���
ynum= ceil((maxy-miny)/ygap);        % Y����С���ĸ���
[x,y]= meshgrid(minx+xgap/2:xgap:minx+xnum*xgap-xgap/2,...
    miny+ygap/2:ygap:miny+ynum*ygap-ygap/2);               %�õ���С�������ĵ�



%step 4 ********************************Trip��������X,Y�Ķ�Ӧ ����4��

Trip(:,10)= ceil((Trip(:,5)-minx)/xgap);                   %����������
Trip(:,11)= ceil((Trip(:,6)-miny)/ygap);                   %�����������
Trip(:,12)= ceil((Trip(:,8)-minx)/xgap);                   %�յ��������
Trip(:,13)= ceil((Trip(:,9)-miny)/ygap);                   %�յ���������



%step 5 ********************************��������ͼ����

Demand_O= zeros(ynum,xnum);
Demand_D= zeros(ynum,xnum);
for nth_rec = 1:length(Trip)
	if mod(nth_rec,10000)==0
		disp(['Calcling ',num2str(nth_rec),' records!'])
	end
	Demand_O(Trip(nth_rec,10),Trip(nth_rec,11)) = Demand_O(Trip(nth_rec,10),Trip(nth_rec,11))+1;
	Demand_D(Trip(nth_rec,12),Trip(nth_rec,13)) = Demand_O(Trip(nth_rec,12),Trip(nth_rec,13))+1;
end



%step 6 ********************************�򵥻�������ͼ

%�������ͼ
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



%step 7 ********************************ͳ�Ʒ���

%���������յ�ʱ��ֲ�ͳ��
OTime= rem(fix(Trip(:,4)/1e+4),100)+rem(fix(Trip(:,4)/1e+2),100)/60; %ʱ�䵥λ��Сʱ
DTime= rem(fix(Trip(:,7)/1e+4),100)+rem(fix(Trip(:,7)/1e+2),100)/60; %ʱ�䵥λ��Сʱ
edges1 = [0:24];
OTime_hist= histogram(OTime,edges1);
figure
DTime_hist= histogram(DTime,edges1);

%����ʱ���ֲ�ͳ��
ODTime= TimeCalculate(Trip(:,4),Trip(:,7))/60;           %ʱ�䵥λ������
edges2= [0:15:max(ODTime)];
figure
ODTime_hist= histogram(ODTime,edges2);



%step 8 ********************************����������ͼ����

xynum= xnum*ynum;          %�����е�С����Ϊһ��
Trip(:,14)= ynum*(Trip(:,10)-1)+Trip(:,11);              %OD�����б��
Trip(:,15)= ynum*(Trip(:,12)-1)+Trip(:,13);              %OD�����б��
ODmatrix= sparse(xynum,xynum);
for i= 1:size(Trip,1)
    ODmatrix(Trip(i,14),Trip(i,15))= ODmatrix(Trip(i,14),Trip(i,15))+1;  %�ۼ�
end
Desireline= tril(ODmatrix)+tril(ODmatrix')-diag(diag(ODmatrix));
[select_row,select_col]= find(Desireline>10);            %ѡ�������������ߵ���ֵ��Χ
maxOD= max(max(Desireline));                             %�ҳ������ߵ����ֵ
figure                          
for n=1:length(select_row)         
    %���к��иĳ�xy�����е�λ��
    ox=ceil(select_row(n)/ynum);
    oy=select_row(n)-(ox-1)*ynum;
    dx=ceil(select_col(n)/ynum);
    dy=select_col(n)-(dx-1)*ynum;
    hold on
    plot([x(1,ox),x(1,dx)],[y(oy,1),y(dy,1)],'LineWidth',20*Desireline(select_row(n),select_col(n))/maxOD); 
end







    


















