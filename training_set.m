global MAX % 步长
MAX=300;
global num;
num=7; % 总节点数
global test_num;
test_num=1000; % 每一个拓扑实验次数
global delta
delta=0.15;
global group_num
group_num=21;
global topo_num
topo_num=50;
file_topo=zeros(topo_num*10,10);
index_=zeros(topo_num,num);

for ftest=1:topo_num
    flag=1; % 存放该组是第几组
    suc_num=zeros(1,group_num); % 成功次数
    suc_rate=zeros(1,group_num); % 成功概率
    arrMAX=zeros(group_num,num);
    
    % 随机生成拓扑（邻接矩阵）
    adj_matrix=zeros(10,10); 
    count=zeros(1,num);
    for i=1:num
        for j=1:num
            adj_matrix(i,j)=randsrc(1,1,[0 1;0.6 0.4]); % 节点之间有一定概率相连
        end
    end
    for i=1:num
        for j=1:num
            if i==j
                adj_matrix(i,j)=0;
                adj_matrix(j,i)=0;
            end
            if adj_matrix(i,j)==1
                adj_matrix(j,i)=1;
             end
        end
    end
    %输出拓扑图
%     adj_matrix(:,:)
    % 开始实验
    % 任意两节点被攻陷
    for ni=1:num
        for nj=(ni+1):num % 避免被重复攻陷，被攻陷的是不同的两个节点
            % 计算每个节点与其他点的连接数
            for i=1:num
                for j=1:num
                    if adj_matrix(i,j)==1
                        count(i)=count(i)+1;
                    end
                end
            end
            % 两个错误节点之间可以默认为不相连
            if adj_matrix(ni,nj)==1
                count(ni)=count(ni)-1;
                count(nj)=count(nj)-1;
            end

            % 每组实验1000次
            for test=1:test_num

                % 初始值随机赋值
                arr=zeros(num,MAX+1);
                for i=1:num
                    arr(i,1)=15*rand(); 
                end

                % 准备工作
                r=zeros(num,num);
                q=zeros(num,num);
                t=zeros(num,num);
                for i=1:num
                    for j=1:num
                        if adj_matrix(i,j)==1
                            q(i,j)=1;
                            t(i,j)=1/count(i);
                        end
                    end
                end

                % q-consensus
                for k=1:MAX
                    r_sum=zeros(1,num);
                    q_sum=zeros(1,num);
                    t_sum=zeros(1,num);

                    for i=1:num
                        for j=1:num
                            if adj_matrix(i,j)==1 
                                r(i,j)=reward(arr(i,k), arr(j,k),t(i,j));
                                r_sum(i)=r_sum(i)+r(i,j);
                            end
                        end
                        for j=1:num
                            if adj_matrix(i,j)==1
                                q(i,j)=qc(q(i,j),r(i,j),r_sum(i));
                                q_sum(i)=q_sum(i)+q(i,j);
                            end
                        end
                        for j=1:num
                            if adj_matrix(i,j)==1
                                t(i,j)=alpha(q(i,j),q_sum(i));
                                t_sum(i)=t_sum(i)+t(i,j)*(arr(j,k) - arr(i,k));
                            end 
                        end
                    end

                    % 根据q-consensus更新正常节点
                    for i=1:num
                        if (i~=ni)&&(i~=nj)
                            arr(i,k+1) = number(arr(i,k), t_sum(i));
                        end
                    end

                    % 根据q-attack更新攻陷的错误节点
                    sumni=0; % ni错误节点的邻接节点的和
                    sumnj=0; % nj错误节点的邻接节点的和
                    for i=1:num
                        if (adj_matrix(ni,i)==1)&&(i~=nj)
                            sumni=sumni+arr(i,k);
                        end
                        if (adj_matrix(nj,i)==1)&&(i~=ni)
                            sumnj=sumnj+arr(i,k);
                        end
                    end
                    arr(ni,k+1)=sumni/count(ni)+delta;
                    arr(nj,k+1)=sumnj/count(nj)-delta;
                end

                % 判断本次实验是否成功，成功存入成功数suc_num中
                [A,index]=sort(arr(:,MAX+1),'ascend');
                % arr(:,MAX+1);
                min=A(1);
                max=A(num);
                if A(1)==arr(ni,MAX+1)||A(1)==arr(nj,MAX+1)
                    if A(2)==arr(ni,MAX+1)||A(2)==arr(nj,MAX+1)
                        min=A(3);
                    else
                        min=A(2);
                    end
                end
                if A(num)==arr(ni,MAX+1)||A(num)==arr(nj,MAX+1)
                    if A(num-1)==arr(ni,MAX+1)||A(num-1)==arr(nj,MAX+1)
                        max=A(num-2);
                    else
                        max=A(num-2);
                    end
                end
                % min
                % max
                if(max-min>0.2)
                    suc_num(flag)=suc_num(flag)+1;
                end
                for i=1:num
                    arrMAX(flag,i)=arr(i,MAX+1);
                end
            end
            flag=flag+1;
        end
    end

    for i=1:group_num
        suc_rate(i)=suc_num(i)/test_num;
    end

    % 计算下标
    for i=1:group_num
        count=1;
        if(suc_rate(i)>0.5)
            for j=1:num
                for k=(j+1):num
                    if count~=i
                        count=count+1;
                    else
                        index_(ftest,j)=1;
                        index_(ftest,k)=1;
                    end
                end
            end
        end
    end
    file_topo((ftest*10-9):ftest*10,:)=adj_matrix(:,:);
end    
% suc_rate_index;
fileID1=fopen('C:\\Users\\ASUS\\Desktop\\topology.txt','wt');
for i=1:topo_num*10
    for j=1:10
        fprintf(fileID1,'%d ',file_topo(i,j));  
    end
    fprintf(fileID1,'\n');
end
fclose(fileID1);
fileID2=fopen('C:\\Users\\ASUS\\Desktop\\best_nodes.txt','wt');
for i=1:topo_num
    for j=1:num
        fprintf(fileID2,'%d ',index_(i,j));
    end
    fprintf(fileID2,'\n');
end
fclose(fileID2);