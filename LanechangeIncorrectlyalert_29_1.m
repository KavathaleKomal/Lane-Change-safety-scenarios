%% Clean workspace and close all
clear all
close all
clc
%% Constraint for parameter

KK = 0;
Str_Ang_Rate=[];
x_speed=[];
y_TTC=[];
z_FHTI=[];
for SteerAngRate_EV_Comp = 20 : 10 : 70
    Speed = [];
    TimeDur = [];
    DataTTC = [];
    AAy=[];
    for EgoVehicleSpeed = 40 : 5 : 130
        
        Vx_EV = EgoVehicleSpeed/3.6;
        Dist2Bondary = 0.3;
        TargetVehicleSpeed = 130/3.6;
        Ay_TV = 0;
        %%
        LaneWidth = 3.66;
        TruckWidth = 3.05;
        WheelBase = 5.79;
        SRR = 18;
       
        R2D = 57.3;
        Ay = -Vx_EV^2 * tand(SteerAngRate_EV_Comp/SRR)/WheelBase;
        AyComp = Vx_EV^2 * tand(SteerAngRate_EV_Comp/SRR)/WheelBase;
        % Saturation: If acceleration is more than 1g. Need to saturate
        if abs(AyComp) > 9.81
            AyComp = sign(AyComp)*9.81;
        else
            AyComp = AyComp;
        end
        dT = 0.01;                                      % Sample time
        VelY = 0;
        DistCovered = 0;
        K = 0;
 %% TTC computation
        Flag = false;
        while(Flag == false)
          
            IC2 = Ay - Ay_TV;
            VelY = VelY + dT * IC2;
            DistCovered = DistCovered + dT*VelY;
            K = K + 1;
            if (abs(DistCovered) >= Dist2Bondary)
                Flag = true;
            end
        end
        TTC = K * dT;
        %% Dist covered during response time
        for ijk = TTC : -dT : 0.001
           
        IC = 0;
        VelY = 0;
        DistCovered = 0;
        Flag = false;
        C = 0;
        %% FHTI calculation
        for i = 0 : dT : ijk
            IC2 = Ay - Ay_TV;
            VelY = VelY + dT * IC2;
            DistCovered = DistCovered + dT*VelY;
        end
        DistCovered1 = abs(DistCovered);
 %% 
        Flag = false;
        N = 0;
        Pev_VelY = VelY;
        DistCovered = 0;
        while(Flag == false)
            
            VelY = VelY + dT * AyComp;
            DistCovered = DistCovered + dT*VelY;
            if sign(VelY) ~= sign(Pev_VelY)
                Flag = true;
            end
            N = N + 1;
        end
        
        DistCovered2 = abs(DistCovered);
        TotalDist = DistCovered1 + DistCovered2;
        if abs(TotalDist) < (Dist2Bondary-0.05)
            break;
        end
        end
        Speed = [Speed EgoVehicleSpeed];
        TimeDur = [TimeDur ijk];
        DataTTC = [DataTTC TTC];
        AAy=[AAy Ay];
        
        Str_Ang_Rate=[Str_Ang_Rate SteerAngRate_EV_Comp];
    end
    x_speed=[x_speed Speed]; 
    y_TTC=[y_TTC DataTTC];
    z_FHTI=[z_FHTI TimeDur];
    KK = KK + 1; 
    SSSS(KK,:) = Speed;
    TTTT(KK,:) = TimeDur;
    TTCC(KK,:) = DataTTC;
    AAAY(KK,:)=  AAy;
end
%% Plots
figure(1)
plot(SSSS(1,:),TTTT(1,:),'b');
hold on;
grid on;
plot(SSSS(2,:),TTTT(2,:),'r');
plot(SSSS(3,:),TTTT(3,:),'c');
plot(SSSS(4,:),TTTT(4,:),'m');
plot(SSSS(5,:),TTTT(5,:),'k');
plot(SSSS(6,:),TTTT(6,:),'g');

legend('SteerR 20 (in dg/s)','SteerR 30','SteerR 40','SteerR 50','SteerR 60','SteerR 70','Location','Best');
xlabel('EV Velocity in KMPH');
ylabel('Fault Handling Time Interval in sec');

f=gcf;
saveas(f,'LanechangeIncorrectlyalert_29_1_FHTI.jpg');

figure(2)
plot(SSSS(1,:),TTCC(1,:),'b');
hold on;
grid on;
plot(SSSS(2,:),TTCC(2,:),'r');
plot(SSSS(3,:),TTCC(3,:),'c');
plot(SSSS(4,:),TTCC(4,:),'m');
plot(SSSS(5,:),TTCC(5,:),'k');
plot(SSSS(6,:),TTCC(6,:),'g');

legend('SteerR 20 (in dg/s)','SteerR 30','SteerR 40','SteerR 50','SteerR 60','SteerR 70','Location','Best');
xlabel('EV Velocity in KMPH');
ylabel('Time-to-collision in sec');

f=gcf;
saveas(f,'LanechangeIncorrectlyalert_29_1_TTC.jpg');
%% excel write
Str_Ang_Rate=Str_Ang_Rate';
x_speed=x_speed';
y_TTC=y_TTC';
z_FHTI=z_FHTI';
data={'Str_ang_rate','Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'LanechangeIncorrectlyalert_29_1','A1');
xlswrite('Functional_Safety_Scenarios',Str_Ang_Rate,'LanechangeIncorrectlyalert_29_1','A2');
xlswrite('Functional_Safety_Scenarios',x_speed,'LanechangeIncorrectlyalert_29_1','B2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'LanechangeIncorrectlyalert_29_1','C2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'LanechangeIncorrectlyalert_29_1','D2');


folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('LanechangeIncorrectlyalert_29_1_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'LanechangeIncorrectlyalert_29_1_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('LanechangeIncorrectlyalert_29_1_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'LanechangeIncorrectlyalert_29_1_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 