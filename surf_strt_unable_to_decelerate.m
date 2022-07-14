%% Clean workspace and close all
clear all
close all
clc
%% Constraint for parameter

KK=0;
x_FI=[];
y_TTC=[];
z_FHTI=[];
decel=[];

for AVlongaccmax=-0.5:-0.1:-0.8
FI=[];
FFHTI=[];
FFTTI=[];
AA=[];
for Fault_dist_inject=0.1:0.1:0.3
AVlongdecNO=-2;
AVlongdecEB=-7;
G=0;
v_KMPH=88.5;

d1=151.25;
d2=1;
d3=0.25;
TD=d1+d2+d3;
s=TD-d3;
Dist_travel=1;
Fault_speed_inject=0;
DistCovered=0;
K=0;
dT=0.01;
VV=0;
position_EV=d1;
v_mps=0.2778*v_KMPH;
SignF=-1;
Flag = false;
Posi=[];
vmps=[];
i=0;
  while(Flag == false)
    i=i+1;
    v_mps=v_mps+(AVlongdecNO)*dT;
    if(v_mps<=0)
        v_mps=0;
    end
    vmps=[vmps v_mps];
        
     
     if(v_mps<=0)
        position_EV=0;
     else
        position_EV=position_EV-v_mps*dT;   
     end
     Posi=[Posi position_EV];
    
    if(position_EV<=Fault_dist_inject)
      Flag=true;
    else 
       Flag=false;
    end
    
  end
initial_position=Posi(i-1);
Fault_speed_inject=vmps(i-1);
v_mps=Fault_speed_inject;
safe_dist=initial_position+d2;
%% TTC computation
    pos=initial_position;
    Flag=false;
    while(Flag == false)
    v_mps=v_mps+(AVlongaccmax)*dT;
    v_mps=max(v_mps,0);
    if (v_mps>0)
        pos=pos-v_mps*dT;
    else
        pos=0;
    end 
    dist_ped_EV=safe_dist-pos;
    dist_ped_EV=max(dist_ped_EV,0);
    K=K+1;
    if(dist_ped_EV<=0 || pos==0 || v_mps==0)
        Flag=true;     
    else 
        Flag=false;
    end
    end
    FTTI=K*dT;
    
    %% FHTI calculation
    for j = 0.01 : 0.01 : FTTI
    Dist_A=Fault_speed_inject*j+(0.5*-AVlongaccmax*j^2);
    VV = sqrt(Fault_speed_inject^2+(2*-AVlongaccmax*Dist_A));
    Dist_B = VV*j+(0.5*-AVlongdecEB*j^2);
    if sign(((Dist_A + Dist_B) - safe_dist)) ~= sign(SignF)
        break;
    else
        SignF = sign(((Dist_A + Dist_B) - safe_dist));
    end
    end
            FHTI=j; 
            
            FFTTI=[FFTTI FTTI];
            FFHTI=[FFHTI FHTI];
            FI=[FI Fault_dist_inject];
            decel=[decel AVlongaccmax];

end
            x_FI=[x_FI FI];
            y_TTC=[y_TTC FFTTI];
            z_FHTI=[z_FHTI FFHTI];
            KK = KK + 1; 
            SSSS(KK,:) = FI;
            TTTT(KK,:) = FFHTI;
            TTCC(KK,:) = FFTTI;
end

figure(1)
plot(SSSS(1,:),TTTT(1,:),'b');
hold on;
grid on;
plot(SSSS(2,:),TTTT(2,:),'r');
plot(SSSS(3,:),TTTT(3,:),'c');
plot(SSSS(4,:),TTTT(4,:),'m');


legend('decel -0.5(m/s/s)','decel -0.6','decel -0.7','decel -0.8','Location','Best');
xlabel('Fault injection distance');
ylabel('Fault Handling Time Interval in sec');

f=gcf;
saveas(f,'surf_strt_unable_to_decelerate_FHTI.jpg');

figure(2)
plot(SSSS(1,:),TTCC(1,:),'b');
hold on;
grid on;
plot(SSSS(2,:),TTCC(2,:),'r');
plot(SSSS(3,:),TTCC(3,:),'c');
plot(SSSS(4,:),TTCC(4,:),'m');


legend('decel -0.5(m/s/s)','decel -0.6','decel -0.7','decel -0.8','Location','Best');
xlabel('Fault injection distance');
ylabel('Time-to-collision in sec');

f=gcf;
saveas(f,'surf_strt_unable_to_decelerate_TTC.jpg');

%% excel write
decel=decel';
x_FI=x_FI';
y_TTC=y_TTC';
z_FHTI=z_FHTI';
data={'Deceleration in m/s/s -ve','Fault Injection distance','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'surf_strt_unable_to_decelerate','A1');
xlswrite('Functional_Safety_Scenarios',decel,'surf_strt_unable_to_decelerate','A2');
xlswrite('Functional_Safety_Scenarios',x_FI,'surf_strt_unable_to_decelerate','B2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'surf_strt_unable_to_decelerate','C2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'surf_strt_unable_to_decelerate','D2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('surf_strt_unable_to_decelerate_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'surf_strt_unable_to_decelerate_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('surf_strt_unable_to_decelerate_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'surf_strt_unable_to_decelerate_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 
