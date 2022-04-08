global MAX
MAX=500;
global normal_num
normal_num=7; % 正常节点数量
c1=2;
c2=8;
count=[3,3,3,2,4,3,3,0,0]; % 邻居节点数
adj_matrix=[0,0,0,1,0,1,0,0,1;  % 邻接矩阵
   0,0,0,1,0,0,1,1,0;
   1,0,0,0,0,0,1,1,0;
   0,0,0,0,0,0,1,0,1;
   1,1,0,1,0,0,0,0,1;
   0,1,1,0,0,0,0,0,1;
   1,0,0,0,0,1,0,1,0;
   0,0,0,0,0,0,0,0,0;
   0,0,0,0,0,0,0,0,0];
arr=zeros(9,MAX+1);
arr(:,1)=[7,3,5,2,8,5,4,c1,c2];
r=zeros(normal_num,9);
q=zeros(normal_num,9);
t=zeros(normal_num,9);
for i=1:normal_num
        for j=1:9
            if adj_matrix(i,j)==1
                q(i,j)=1;
                t(i,j)=1/count(i);
            end
        end
end

for k=1:MAX
    r_sum=[0,0,0,0,0,0,0];
    q_sum=[0,0,0,0,0,0,0];
    t_sum=[0,0,0,0,0,0,0];
    for i=1:normal_num
        for j=1:9
            if adj_matrix(i,j)==1  % j是i的邻居节点
                r(i,j)=reward(arr(i,k), arr(j,k),t(i,j));
                r_sum(i)=r_sum(i)+r(i,j);
            end
        end
        for j=1:9
            if adj_matrix(i,j)==1 
                q(i,j)=qc(q(i,j),r(i,j),r_sum(i));
                q_sum(i)=q_sum(i)+q(i,j);
            end
        end
        for j=1:9
            if adj_matrix(i,j)==1
                t(i,j)=alpha(q(i,j),q_sum(i));
                t_sum(i)=t_sum(i)+t(i,j)*(arr(j,k) - arr(i,k));
            end
        end
    end
    for i=1:normal_num
        arr(i,k+1) = number(arr(i,k), t_sum(i))
    end
    if k<10 || (k>50&&k<70) || (k>125&&k<140)
        temp=unidrnd(normal_num);
        arr(8,k+1)=arr(temp,k)
        arr(9,k+1)=arr(temp,k)
    else
        x=1:0.01:MAX;
        f=@(x)0.1*sin(x/10); % 匿名函数
        arr(8,k+1)=f(k)+8;
        arr(9,k+1)=f(k)+8;
    end
% 恒定错误节点
%     arr(8,k+1)=arr(8,k);
%     arr(9,k+1)=arr(9,k);
% 随机错误节点
%     arr(8,k+1)=randn();
%     arr(9,k+1)=randn();
end

x=1:(MAX+1);
y1=arr(1,:);
y2=arr(2,:);
y3=arr(3,:);
y4=arr(4,:);
y5=arr(5,:);
y6=arr(6,:);
y7=arr(7,:);
y8=arr(8,:);
y9=arr(9,:);
plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,x,y7,x,y8,x,y9)
axis([1 MAX+1,0 9])
xlabel('times')
ylabel('state')
legend('Node1','Node2','Node3','Node4','Node5','Node6','Node7','Node8','Node9')