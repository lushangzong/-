%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���ߣ�³���� ʱ�䣺2018��12��14�� 
%������ʵ����ͨ�����˻�λ����Ϣ�������˻���˲ʱ�ٶ�
%���ұȽ��˲�ͬ�󵼵Ĳ�������ͬ�뾶����ͬ��ֵ�����Խ����Ӱ��
%��ʵ���˶����ݵ�Ԥ������ɾ�����������ݵĹ���
%��ͬ�����ͨ����ͬ��ע�������ʵ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; %����ڴ�

%�����൱��ʱ����
step=1;
%step=0.5;
%step=0.1;
%step=0.01;

%��ԭʼ���ݽ��в�ֵ����Ϊ�����һ���ο�ֵ
method='spline';  %������ֵ
%method='linear';  %���Բ�ֵ


%����뾶�������������
%r=6371e3;  %ƽ��ֵ
r=6378e3;   %����뾶

%��ȡ���ݣ���ÿһ�����ݶ��뵽������
filename='POS2_data.txt';
a=importdata(filename);
time=a.data(:,1); %ʱ��
latitude=a.data(:,2); %γ��
longitude=a.data(:,3); %����
height=a.data(:,4); %�߶�
v_east=a.data(:,6); %���ٶ�
v_north=a.data(:,7); %���ٶ�
v_up=a.data(:,8);  %�����ٶ�

%��������Ƿ���ȫ�������ĳ������Ϊ�գ����¼����һ�еı�ţ������������ɾ������
num=size(time);
k=zeros(100,1);  %Ԥ�ƿ�ֵ���в������100��
j=1;
%���������ֵ�ͽ���һ�еı�Ŵ�����
for i=1:num
    if isnan(time(i))||isnan(latitude(i))||isnan(longitude(i))||isnan(height(i))...
            ||isnan(v_east(i))||isnan(v_north(i))||isnan(v_up(i))
        k(j)=i;
        j=j+1;
    end
end
%���������ݵĿ�ֵ��ɾȥ
time(k(1:j-1),:)=[];
latitude(k(1:j-1),:)=[];
longitude(k(1:j-1),:)=[];
height(k(1:j-1),:)=[];
v_east(k(1:j-1),:)=[];
v_north(k(1:j-1),:)=[];
v_up(k(1:j-1),:)=[];

%�ٴλ�ȡ���ݴ�С
num=size(time);

%��ʱ��������䣬Ϊ�Ȳ�����
time_inter=(time(1):step:time(num(1)))';

%���ٶȴ�СΪ����������ƽ�����ٿ���
v=(v_east.^2+v_north.^2+v_up.^2).^0.5;

%��ԭʼ���ݽ��в�ֵ��һ���������ݼ������ȵ����⣬��һ����Լ����������Ƚ�
v_inter=interp1(time,v,time_inter,method);
lat_inter=interp1(time,latitude,time_inter,method);
lon_inter=interp1(time,longitude,time_inter,method);
height_inter=interp1(time,height,time_inter,method);

%��ȡ��ֵ������ݴ�С
number=size(lat_inter);
num=number(1);

%����һ������뾶���飬���ڼ���·��
%ÿһ��ֵΪ����뾶���϶�Ӧ�߶�
r_list=height_inter;
for i=1:num
    r_list(i)=r+height_inter(i);
end

%����·��
distance=r_list;
distance(1)=0; %��һ��·��Ϊ0


for i=2:num
    %�ֱ���㾭�ȡ�ά�ȡ��߶ȵľ��룬ʵ��·��Ϊ���ߵ�ƽ�����ٿ���
    %��Ҫ���нǶȺͻ��ȵ�ת��
    dis_lat=(lat_inter(i)-lat_inter(i-1))/360*2*pi*r_list(i);
    dis_lon=(lon_inter(i)-lon_inter(i-1))/360*2*pi*r_list(i)*cos(lat_inter(i)*pi/180);
    dis_height=height_inter(i)-height_inter(i-1);
    distance(i)=distance(i-1)+(dis_lat^2+dis_lon^2+dis_height^2)^0.5;
end

%�������㹫ʽ�����㹫ʽ����㹫ʽ�������󵼵ķ��������ٶ�
v_two=two_point(distance,step);
v_three=three_point(distance,step);
v_five=five_point(distance,step);
v_spline=spline(distance,step,v_inter(1),v_inter(num));

%�ò�ֵ����ٶȼ�ȥ��������Ľ�������бȽ�
error_two=v_inter-v_two;
error_three=v_inter-v_three;
error_five=v_inter-v_five;
error_spline=v_inter-v_spline;

%����ͼ��
%��һ��ͼ�����Ƽ�����
figure(1); 
subplot(1,2,1);
plot(time_inter,v_inter);
hold on;
plot(time_inter,v_two);
hold on;
plot(time_inter,v_three);
hold on;
plot(time_inter,v_five);
hold on;
plot(time_inter,v_spline);
hold on;
scatter(time,v);
title('������')
xlabel('ʱ��');
ylabel('�ٶ�');
legend('��ֵ���','���㹫ʽ','���㹫ʽ','��㹫ʽ','������');

%�ڶ���ͼ���������
subplot(1,2,2);
plot(time_inter,error_two);
hold on;
plot(time_inter,error_three);
hold on;
plot(time_inter,error_five);
hold on;
plot(time_inter,error_spline);
title('���Ƚ�')
xlabel('ʱ��');
ylabel('���');
legend('���㹫ʽ','���㹫ʽ','��㹫ʽ','������');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���㹫ʽ�������ٶ�
%����·�̵����飬������ͬ��С���ٶ�����
%·�̵�����Ӧ���ǵ���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=two_point(list,step)
%��ȡ�����С
num=size(list);
number=num(1);

result=list;

%�������һ���ٶȣ��������ٶȶ��Ǻ���ļ�ȥǰ���·���ٳ���ʱ����
for i=1:number-1
    result(i)= (list(i+1)-list(i))/step;
end
%���һ���ٶȵ���ǰ����ٶȣ��������㷨��ȱ��
result(number)=result(number-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���㹫ʽ�������ٶ�
%����·�̵����飬������ͬ��С���ٶ�����
%·�̵�����Ӧ���ǵ���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=three_point(list,step)
%��ȡ�����С
num=size(list);
number=num(1);

result=list;

%�������һ���͵�һ�������Ķ�Ҫ���������������������
for i=2:number-1
    result(i)=(list(i+1)-list(i-1))/(2*step);
end

%��һ��������һ����Ҫ�ֿ�����
result(1)=(list(1)*(-3)+list(2)*4-list(3))/(2*step);
result(number)=(list(number-2)-4*list(number-1)+3*list(number))/(2*step);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��㹫ʽ�������ٶ�
%����·�̵����飬������ͬ��С���ٶ�����
%·�̵�����Ӧ���ǵ���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=five_point(list,step)

%��ȡ�����С
num=size(list);
number=num(1);

result=list;

%������������Ϳ�ʼ���������Ķ�Ҫ�������ĸ��������������
for i=3:number-2
    result(i)=(list(i-2)-8*list(i-1)+8*list(i+1)-list(i+2))/(12*step);
end

%��������Ϳ�ʼ������������
result(1)=(-25*list(1)+48*list(2)-36*list(3)+16*list(4)-3*list(5))/(12*step);
result(2)=(-3*list(1)-10*list(2)+18*list(3)-6*list(4)+list(5))/(12*step);
result(number-1)=(-list(number-4)+6*list(number-3)-...
    18*list(number-2)+10*list(number-1)+3*list(number))/(12*step);
result(number)=(3*list(number-4)-16*list(number-3)+...
    36*list(number-2)-48*list(number-1)+25*list(number))/(12*step);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����󵼣������ٶ�
%����·�̵�����ͱ߽������������ٶ�����
%·�̵�����Ӧ���ǵ���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=spline(list,step,v0,vn)

%��ȡ�����С
num=size(list);
number=num(1);

%ϵ������
A=zeros(number-2,number-2);

%����ϵ�����󣬵�һ�к����һ�е�����ֵ���������ѭ������
A(1,1)=4;
A(1,2)=1;
A(number-2,number-3)=1;
A(number-2,number-2)=4;
for i=2:number-3
    A(i,i-1)=1;
    A(i,i)=4;
    A(i,i+1)=1;
end

%���������������ұߵ�ֵ
g=zeros(number-2,1);
%��β����ֵ������ֵ���������ѭ��
g(1)=3*(list(3)-list(1))/step-v0;
g(number-2)=3*(list(number)-list(number-2))/step-vn;
for i=2:number-3
    g(i)=3*(list(i+1)-list(i-1))/step;
end

%�����Է����飬���öԳƾ���ķ���
opts.SYM = true;
tem=linsolve(A,g,opts);
result=list;
result(1)=v0;
result(number)=vn;
result(2:number-1)=tem;
end

