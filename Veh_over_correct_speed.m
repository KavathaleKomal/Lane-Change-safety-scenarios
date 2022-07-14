%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Clean workspace and close all
close all
clear all
clc
%% Constraint for parameter
FI=[];
FFHTI=[];
FFTTI=[];
for Fault_dist_inject=1:1:5
    
AVlongdecNO=-2;
AVlongdecEB=-7;
G=0;
v_KMPH=88.5;

d1=151.25;
d2=1;
d3=0.25;
TD=d1+d2+d3;
s=TD-d3;
AVlongaccmax=4;
Dist_travel=1;
Fault_speed_inject=0;
DistCovered=0;
K=0;
dT=0.01;
VV=0;
position_EV=d1;
v_mps=0.2778*v_KMPH;
SignF=-1;

a=-9.81*(v_KMPH^2)/((254*s)-(G/100));

Flag = false;
  while(Flag == false)
    
    v_mps=v_mps+AVlongdecNO*dT;
    if(v_mps<=0)
        v_mps=0;
    else
        v_mps=v_mps;   
    end
        
     
     if(position_EV<=0|| v_mps==0)
        position_EV=0;
    else
        position_EV=position_EV-v_mps*dT;   
     end
    
    if(position_EV<=Fault_dist_inject)
      Flag=true;
    else 
       Flag=false;
    end
    
  end
    initial_position=position_EV;
    Fault_speed_inject=v_mps;
    safe_dist=initial_position+d2;
%% TTC computation
    pos=0;
    Flag=false;
    while(Flag == false)
   
    v_mps=v_mps+AVlongaccmax*dT;
    pos=pos+v_mps*dT;
    dist_ped_EV=safe_dist-pos;
    dist_ped_EV=max(dist_ped_EV,0);
    K=K+1;
    if(dist_ped_EV==0)
        Flag=true; 
        
    else 
        Flag=false;
    end
    end
    FTTI=K*dT;
    
    %% FHTI calculation
    for j = 0.01 : 0.01 : FTTI
    Dist_A=Fault_speed_inject*j+(0.5*AVlongaccmax*j^2);
    VV = sqrt(Fault_speed_inject^2+(2*AVlongaccmax*Dist_A));
    Dist_B = abs((VV*VV)/(2*AVlongdecEB));
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
end
 %% plots 
figure(1);
plot(FI,FFHTI);
grid on
xlabel('Fault Injection Distance')
ylabel('Fault Handling Time Interval in sec');
hold on

f=gcf;
saveas(f,'Veh_over_correct_speed_FHTI.jpg');

figure(2);
plot(FI,FFTTI);
grid on
xlabel('Fault Injection Distance')
ylabel('Time-to-collision in sec');
hold on

f=gcf;
saveas(f,'Veh_over_correct_speed_TTC.jpg');

%% excel write
x_speed=FI';
y_TTC=FFTTI';
z_FHTI=FFHTI';
data={'Fault Injection Distance','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'Veh_over_correct_speed','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'Veh_over_correct_speed','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'Veh_over_correct_speed','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'Veh_over_correct_speed','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('Veh_over_correct_speed_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'Veh_over_correct_speed_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('Veh_over_correct_speed_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'Veh_over_correct_speed_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 